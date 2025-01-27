CREATE TABLE glue_catalog_name.database_name.table_name (
    ip_num_low INT,
    ip_num_high INT,
    country_code STRING,
    country_name STRING, 
    region STRING,
    city STRING,
    isp STRING,
    domain STRING,
    usage_type STRING,
    asn STRING,
    company STRING,
    threat_level INT,
    threat_type STRING,
    provider STRING,
    ip_low STRING,
    ip_high STRING,
    ip_difference INT,
    updated_at TIMESTAMP
)
USING iceberg
PARTITIONED BY (updated_at)
LOCATION 's3://<ip_explorer>/';
