import boto3
import os
import requests
import pandas as pd
import io
import pyarrow as pa
import pyarrow.parquet as pq
from pyspark.sql import SparkSession
from pyspark.sql.functions import col, expr, udf
from pyspark.sql.types import StringType
from constants import *

def extract_to_spark_dataframe():
    """
    Extracts data from a URL into a Spark DataFrame.

    Returns:
        pyspark.sql.DataFrame: The extracted data as a Spark DataFrame.
    """
    # Grab token from K8s Secrets.
    token = os.getenv("TOKEN", "No Token Found")
    database_code = 'PX11LITECSV'
    dataname = 'px11'
    # Construct the URL for data pull
    url = f"https://www.ip2location.com/download/?token={token}&file={database_code}"

    try:
        # Send GET request to download the file
        response = requests.get(url, stream=True)
        response.raise_for_status()  # Raise an error for bad responses

        # Read the response content into a Pandas DataFrame (assuming CSV format)
        data = io.BytesIO(response.content)  # Read the content into memory
        pandas_df = pd.read_csv(data)  # Adjust to appropriate reader (CSV, JSON, etc.)

        print("Download and conversion to Pandas DataFrame successful!")

        # Convert Pandas DataFrame to Spark DataFrame
        spark = SparkSession.builder.appName("ExtractToSparkDF").getOrCreate()
        spark_df = spark.createDataFrame(pandas_df)

        print("Conversion to Spark DataFrame successful!")
        return spark_df

    except requests.exceptions.RequestException as e:
        print(f"Download failed: {e}")
        return None

def execute_sql_from_file_with_spark(sql_file_path, catalog_name, warehouse_location):
    """
    Executes a SQL file to create an Iceberg table using Apache Spark.

    Args:
        sql_file_path (str): Path to the SQL file containing the table creation statement.
        catalog_name (str): The Iceberg catalog name in Spark.
        warehouse_location (str): The S3 warehouse location for Iceberg tables.
    """
    # Initialize Spark session with Iceberg configurations
    spark = SparkSession.builder \
        .appName("IcebergTableCreation") \
        .config(f"spark.sql.catalog.{catalog_name}", "org.apache.iceberg.spark.SparkCatalog") \
        .config(f"spark.sql.catalog.{catalog_name}.type", "hive") \
        .config(f"spark.sql.catalog.{catalog_name}.warehouse", warehouse_location) \
        .getOrCreate()

    # Read SQL from file
    with open(sql_file_path, 'r') as f:
        sql = f.read()

    # Execute SQL
    spark.sql(sql)
    print("Table creation executed successfully.")

def transform(spark_df, rename_dict):
    """
    Transforms a Spark DataFrame:
    - Converts IP numbers to addresses.
    - Renames columns to lowercase per rename_dict.
    - Creates low and high IP address columns.
    - Drops the 'proxytype' column.
    
    Args:
        spark_df (pyspark.sql.DataFrame): The input Spark DataFrame.
        rename_dict (dict): A dictionary mapping old column names to new column names.
    
    Returns:
        pyspark.sql.DataFrame: The transformed Spark DataFrame.
    """
    # Define a UDF to convert IP numbers to addresses
    @udf(StringType())
    def ip_number_to_address(ip_number):
        return f"{(ip_number >> 24) & 255}.{(ip_number >> 16) & 255}.{(ip_number >> 8) & 255}.{ip_number & 255}" if ip_number is not None else None

    # Rename columns using the rename_dict
    for old_col, new_col in rename_dict.items():
        spark_df = spark_df.withColumnRenamed(old_col, new_col)

    # Add 'ip_low' and 'ip_high' columns by applying the UDF
    spark_df = spark_df.withColumn('ip_low', ip_number_to_address(col('ip_num_low')))
    spark_df = spark_df.withColumn('ip_high', ip_number_to_address(col('ip_num_high')))

    # Drop the 'proxytype' column
    if 'proxytype' in spark_df.columns:
        spark_df = spark_df.drop('proxytype')

    return spark_df


def save_to_iceberg_table(df, table_name, catalog_name, bucket_name, object_key, aws_access_key_id=None, aws_secret_access_key=None, region_name=None):
    """
    Saves a Pandas DataFrame as a Parquet file to an S3 bucket.

    Args:
        df (pd.DataFrame): The DataFrame to save.
        table_name (str): The Iceberg table name in AWS Glue.
        catalog_name (str): The AWS Glue catalog name for Iceberg.
        bucket_name (str): The name of the S3 bucket.
        object_key (str): The S3 object key (path within the bucket).
        aws_access_key_id (str): AWS access key ID (optional, uses environment variables if not provided).
        aws_secret_access_key (str): AWS secret access key (optional, uses environment variables if not provided).
        region_name (str): AWS region name (optional, uses default if not provided).
    """
    try:
        # Step 1: Initialize Spark Session with Iceberg Support
        spark = SparkSession.builder \
            .appName("IcebergWriter") \
            .config("spark.sql.catalog." + catalog_name, "org.apache.iceberg.spark.SparkCatalog") \
            .config("spark.sql.catalog." + catalog_name + ".type", "hive") \
            .config("spark.sql.catalog." + catalog_name + ".warehouse", f"s3://{bucket_name}/") \
            .config("spark.hadoop.fs.s3a.access.key", aws_access_key_id) \
            .config("spark.hadoop.fs.s3a.secret.key", aws_secret_access_key) \
            .config("spark.sql.catalog." + catalog_name + ".uri", f"glue://{region_name}") \
            .getOrCreate()

        # Step 2: Convert Pandas DataFrame to Spark DataFrame
        spark_df = spark.createDataFrame(df)

        # Step 3: Write Data to Iceberg Table
        spark_df.writeTo(f"{catalog_name}.{table_name}") \
            .append()  # Use "overwrite" if you want to replace data instead

    except Exception as e:
        print(f"Failed to save to Iceberg table: {e}")

    finally:
        # Stop the Spark session
        if 'spark' in locals():
            spark.stop()