DROP TABLE IF EXISTS staging_listings_performance CASCADE;
CREATE TABLE staging_listings_performance (
    listing_id             BIGINT,
    season                 VARCHAR(20),
    date_of_scraping       DATE,
    price                  DECIMAL(10, 2),
    total_reviews          INT,
    rating_score           DECIMAL(5, 2),
    beds_number            DECIMAL(3, 1),
    bedrooms_number        DECIMAL(3, 1),
    max_allowed_guests     DECIMAL(3, 1),
    bathrooms_number       DECIMAL(3, 1),
    reviews_per_month      DECIMAL(5, 2),
    value_for_money_score  DECIMAL(5, 2),
    cleanliness_score      DECIMAL(5, 2),
    location_score         DECIMAL(5, 2),
    city                   VARCHAR(100),
    neighbourhood          VARCHAR(100),
    host_id                BIGINT,
    load_timestamp         TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    error_flag             BOOLEAN DEFAULT FALSE,  -- Flag for error handling
    error_reason           TEXT                    -- Capture error description
);
