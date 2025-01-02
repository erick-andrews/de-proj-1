#!/bin/bash

set -e  # Exit on error

DB_NAME="dev_airbnb"
DB_USER="eandrews"
CSV_PATH=$1  # Pass CSV path as an argument
STAGING_TABLE="listings.airbnb_staging(listing_id, last_year_reviews, host_since, host_is_superhost, host_number_of_listings, neighbourhood, beds_number, bedrooms_number, property_type, max_allowed_guests, price, total_reviews, rating_score, accuracy_score, cleanliness_score, checkin_score, communication_score, location_score, value_for_money_score, reviews_per_month, city, season, bathrooms_number, bathrooms_type, coordinates, date_of_scraping)"

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
