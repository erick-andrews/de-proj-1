import boto3
import os
import requests
import pandas as pd
import io
from functions import *
from constants import *

def main():
    # Extract to dataframe in memory - machine should be able to handle
    df = extract_to_spark_dataframe()
    # Make minor transformations for bronze layer
    df = transform(df)
    # Convert to Parquet in memory and upload to S3
    save_to_iceberg_table(df = df, 
                          bucket_name = "ip-explorer", 
                          object_key="bronze/", 
                          aws_access_key_id = os.getenv("AWS_ACCESS_KEY_ID"), 
                          aws_secret_access_key = os.getenv("AWS_SECRET_ACCESS_KEY"), 
                          region_name = region_name)

if __name__ == "__main__":
    # Call main
    try:
        main()
    except ValueError as e:
        print(f"Error: {e}")
