-- Remake ddl for all columns
-- Fact Table: listings_performance_fact
DROP TABLE IF EXISTS listings_performance_fact CASCADE;
CREATE TABLE listings_performance_fact (
    listing_id             BIGINT,
    season                 VARCHAR(20),
    date_of_scraping       DATE,
    price                  DECIMAL(10, 2),
    total_reviews          INT,
    rating_score           DECIMAL(5, 2),
    value_for_money_score  DECIMAL(5, 2),
    cleanliness_score      DECIMAL(5, 2),
    location_score         DECIMAL(5, 2),
    reviews_per_month      DECIMAL(5, 2),
    host_id                BIGINT,
    city                   VARCHAR(100),
    neighbourhood          VARCHAR(100),
    date_added             TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (listing_id, season, date_of_scraping)
);

-- Dimension Table: listings_dim
DROP TABLE IF EXISTS listings_dim CASCADE;
CREATE TABLE listings_dim (
    listing_id             BIGINT PRIMARY KEY,
    property_type          VARCHAR(100),
    beds_number            DECIMAL(3, 1),
    bedrooms_number        DECIMAL(3, 1),
    bathrooms_number       DECIMAL(3, 1),
    max_allowed_guests     INT,
    date_added             TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Dimension Table: host_dim
DROP TABLE IF EXISTS host_dim CASCADE;
CREATE TABLE host_dim (
    host_id                 BIGINT PRIMARY KEY,
    host_since              DATE,
    host_is_superhost       BOOLEAN,
    host_number_of_listings INT,
    date_added              TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Dimension Table: location_dim
DROP TABLE IF EXISTS location_dim CASCADE;
CREATE TABLE location_dim (
    city                    VARCHAR(100),
    neighbourhood           VARCHAR(100),
    coordinates             VARCHAR(100),  -- Adjusted for coordinates from CSV
    date_added              TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (city, neighbourhood)
);

-- Dimension Table: time_dim
DROP TABLE IF EXISTS time_dim CASCADE;
CREATE TABLE time_dim (
    date_of_scraping        DATE PRIMARY KEY,
    season                  VARCHAR(20),
    date_added              TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Additional Dimension Table for Review Scores
DROP TABLE IF EXISTS review_scores_dim CASCADE;
CREATE TABLE review_scores_dim (
    listing_id             BIGINT PRIMARY KEY,
    accuracy_score         DECIMAL(5, 2),
    checkin_score          DECIMAL(5, 2),
    communication_score    DECIMAL(5, 2),
    date_added             TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Foreign Key Constraints
ALTER TABLE listings_performance_fact
ADD CONSTRAINT fk_listing
FOREIGN KEY (listing_id) REFERENCES listings_dim(listing_id);

ALTER TABLE listings_performance_fact
ADD CONSTRAINT fk_host
FOREIGN KEY (host_id) REFERENCES host_dim(host_id);

ALTER TABLE listings_performance_fact
ADD CONSTRAINT fk_location
FOREIGN KEY (city, neighbourhood) REFERENCES location_dim(city, neighbourhood);

ALTER TABLE listings_performance_fact
ADD CONSTRAINT fk_time
FOREIGN KEY (date_of_scraping) REFERENCES time_dim(date_of_scraping);

ALTER TABLE review_scores_dim
ADD CONSTRAINT fk_review_listing
FOREIGN KEY (listing_id) REFERENCES listings_dim(listing_id);

DROP TABLE IF EXISTS airbnb_staging CASCADE;
CREATE TABLE airbnb_staging (
    listing_id              BIGINT,
    last_year_reviews       INT,
    host_since              DATE,
    host_is_superhost       BOOLEAN,
    host_number_of_listings INT,
    neighbourhood           VARCHAR(100),
    beds_number             DECIMAL(3, 1),
    bedrooms_number         DECIMAL(3, 1),
    property_type           VARCHAR(100),
    max_allowed_guests      INT,
    price                   DECIMAL(10, 2),
    total_reviews           INT,
    rating_score            DECIMAL(5, 2),
    accuracy_score          DECIMAL(5, 2),
    cleanliness_score       DECIMAL(5, 2),
    checkin_score           DECIMAL(5, 2),
    communication_score     DECIMAL(5, 2),
    location_score          DECIMAL(5, 2),
    value_for_money_score   DECIMAL(5, 2),
    reviews_per_month       DECIMAL(5, 2),
    city                    VARCHAR(100),
    season                  VARCHAR(20),
    bathrooms_number        DECIMAL(3, 1),
    bathrooms_type          VARCHAR(50),
    coordinates             VARCHAR(50),
    date_of_scraping        DATE,
    load_timestamp          TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS staging_listings_performance CASCADE;