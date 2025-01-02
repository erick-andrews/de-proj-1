#!/bin/bash

set -e  # Exit on error

DB_NAME="dev_airbnb"
DB_USER="eandrews"
CSV_PATH=$1  # Pass CSV path as an argument
STAGING_TABLE="staging_listings_performance"

if [ -z "$CSV_PATH" ]; then
  echo "Usage: $0 <path_to_csv>"
  exit 1
fi

echo "Loading CSV data into $STAGING_TABLE..."

# Copy CSV into Staging Table
psql -h 127.0.0.1 -p 5433 -U $DB_USER -d $DB_NAME -c "\COPY $STAGING_TABLE FROM '$CSV_PATH' DELIMITER ',' CSV HEADER;"

# Run ETL Process (SQL file with transformations)
# psql -h 127.0.0.1 -p 5433 -U $DB_USER -d $DB_NAME -f etl_process.sql

echo "Data load complete. Staging table processed."
