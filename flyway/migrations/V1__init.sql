-- Fact Table: listings_performance_fact
CREATE TABLE listings_performance_fact (
    listing_id             BIGINT,
    season                 VARCHAR(20),
    date_of_scraping       DATE,
    price                  DECIMAL(10, 2),
    total_reviews          INT,
    rating_score           DECIMAL(5, 2),
    beds_number            INT,
    bedrooms_number        INT,
    max_allowed_guests     INT,
    bathrooms_number       DECIMAL(3, 1),
    reviews_per_month      DECIMAL(5, 2),
    value_for_money_score  DECIMAL(5, 2),
    cleanliness_score      DECIMAL(5, 2),
    location_score         DECIMAL(5, 2),
    city                   VARCHAR(100),  -- Denormalized from location_dim
    neighbourhood          VARCHAR(100),  -- Denormalized
    host_id                BIGINT,        -- Links to host_dim
    date_added             TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (listing_id, season, date_of_scraping)
);

-- Dimension Table: listings_dim
CREATE TABLE listings_dim (
    listing_id       BIGINT PRIMARY KEY,
    property_type    VARCHAR(100),
    beds_number      INT,
    bedrooms_number  INT,
    bathrooms_number DECIMAL(3, 1),
    max_allowed_guests INT,
    date_added       TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Dimension Table: host_dim
CREATE TABLE host_dim (
    host_id                 BIGINT PRIMARY KEY,
    host_since              DATE,
    host_is_superhost       BOOLEAN,
    host_number_of_listings INT,
    date_added              TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Dimension Table: location_dim
CREATE TABLE location_dim (
    city           VARCHAR(100),
    neighbourhood  VARCHAR(100),
    coordinates    TEXT,  -- Supports spatial queries
    date_added     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (city, neighbourhood)
);

-- Dimension Table: time_dim
CREATE TABLE time_dim (
    date_of_scraping DATE PRIMARY KEY,
    season           VARCHAR(20),
    date_added       TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Foreign Key Constraints for Integrity
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
