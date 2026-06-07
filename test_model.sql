{# CREATE TABLE dim_customer (

    -- Primary Key / Surrogate Key
    customer_key BIGINT PRIMARY KEY AUTO_INCREMENT,

    -- Business Keys
    customer_id VARCHAR(255),
    user_id_db VARCHAR(255),

    -- Descriptive Attributes
    email_hash VARCHAR(255),

    -- Flags
    is_registered_customer BOOLEAN,

    -- Audit Columns
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    -- Constraints
    UNIQUE KEY uk_customer_id (customer_id),
    INDEX idx_user_id_db (user_id_db)

); #}


CREATE TABLE dim_customer (

    -- Surrogate Key (SCD2 version identifier)
    customer_key BIGINT,

    -- Business Key
    customer_id VARCHAR(255) NOT NULL,

    -- Optional Secondary Business Identifier
    user_id_db VARCHAR(255),

    -- Descriptive Attributes
    email_hash VARCHAR(255),

    -- Flags
    is_registered_customer BOOLEAN,

    -- SCD Type 2 Columns
    effective_start_datetime DATETIME NOT NULL,
    effective_end_datetime DATETIME NOT NULL,

    is_current BOOLEAN NOT NULL DEFAULT TRUE,

    version_number INT NOT NULL DEFAULT 1,

    -- Change Detection Hash
    attribute_hash VARCHAR(64),

    -- ETL Audit Columns
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    -- Constraints
    INDEX idx_customer_id (customer_id),
    INDEX idx_user_id_db (user_id_db),
    INDEX idx_is_current (is_current),

    UNIQUE KEY uk_customer_version (
        customer_id,
        effective_start_datetime
    )

);

CREATE TABLE dim_product (

    -- Primary Key / Surrogate Key
    product_key BIGINT PRIMARY KEY AUTO_INCREMENT,

    -- Business Keys
    product_id VARCHAR(255),
    sku VARCHAR(255),

    -- Descriptive Attributes
    product_name VARCHAR(500),
    product_type VARCHAR(255),
    collection_name VARCHAR(255),
    category_id VARCHAR(255),
    gender VARCHAR(100),

    -- Audit Columns
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    -- Constraints
    UNIQUE KEY uk_product_id (product_id),
    INDEX idx_sku (sku),
    INDEX idx_category_id (category_id)

);

CREATE TABLE dim_date (

    -- Primary Key
    date_key BIGINT PRIMARY KEY,

    -- Date Attributes
    full_date DATE,

    day_of_month INT,
    month_number INT,
    month_name VARCHAR(50),

    quarter_number INT,
    year_number INT,

    weekday_name VARCHAR(50),

    is_weekend BOOLEAN,

    -- Period Start Dates

    month_start_date DATE,
    quarter_start_date DATE,
    year_start_date DATE
);

CREATE TABLE dim_location (

    -- Primary Key / Surrogate Key
    location_key BIGINT PRIMARY KEY AUTO_INCREMENT,

    -- Descriptive Attributes
    country_code VARCHAR(10),
    country_name VARCHAR(255),
    region_name VARCHAR(255),
    city_name VARCHAR(255),

    -- Audit Columns
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    -- Constraints
    UNIQUE KEY uk_location (
        country_code,
        country_name,
        region_name,
        city_name
    )

);


CREATE TABLE dim_currency (

    -- Primary Key / Surrogate Key
    currency_key BIGINT PRIMARY KEY AUTO_INCREMENT,

    -- Business Keys
    currency_code VARCHAR(10),

    -- Descriptive Attributes
    currency_name VARCHAR(100),
    currency_symbol VARCHAR(20),

    -- Audit Columns
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    -- Constraints
    UNIQUE KEY uk_currency_code (currency_code)

);

CREATE TABLE dim_traffic_source (

    -- Primary Key / Surrogate Key
    traffic_key BIGINT PRIMARY KEY AUTO_INCREMENT,

    -- Descriptive Attributes
    utm_source VARCHAR(255),
    utm_medium VARCHAR(255),
    referrer_url TEXT,
    search_keyword VARCHAR(255),

    -- Audit Columns
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP

);

CREATE TABLE dim_device (

    -- Primary Key / Surrogate Key
    device_key BIGINT PRIMARY KEY AUTO_INCREMENT,

    -- Descriptive Attributes
    user_agent TEXT,
    resolution VARCHAR(50),
    device_type VARCHAR(100),
    browser_name VARCHAR(100),
    operating_system VARCHAR(100),

    -- Audit Columns
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP

);

CREATE TABLE fact_sales_order_detail (

    -- Primary Key / Surrogate Key
    sales_order_detail_key BIGINT PRIMARY KEY AUTO_INCREMENT,

    -- Foreign Keys
    customer_key BIGINT,
    product_key BIGINT,
    date_key BIGINT,
    location_key BIGINT,
    traffic_key BIGINT,
    device_key BIGINT,
    currency_key BIGINT,

    -- Degenerate Dimensions
    order_id VARCHAR(255),
    ip_address VARCHAR(255),

    -- Measures
    order_quantity INT,

    unit_price DECIMAL(18,2),
    gross_amount DECIMAL(18,2),
    discount_amount DECIMAL(18,2),
    net_sales_amount DECIMAL(18,2),

    -- Flags / Indicators
    is_paypal BOOLEAN,
    is_recommendation BOOLEAN,

    -- Technical / Audit Columns
    order_timestamp DATETIME,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    -- Constraints
    CONSTRAINT fk_sales_customer
        FOREIGN KEY (customer_key)
        REFERENCES dim_customer(customer_key),

    CONSTRAINT fk_sales_product
        FOREIGN KEY (product_key)
        REFERENCES dim_product(product_key),

    CONSTRAINT fk_sales_date
        FOREIGN KEY (date_key)
        REFERENCES dim_date(date_key),

    CONSTRAINT fk_sales_location
        FOREIGN KEY (location_key)
        REFERENCES dim_location(location_key),

    CONSTRAINT fk_sales_traffic
        FOREIGN KEY (traffic_key)
        REFERENCES dim_traffic_source(traffic_key),

    CONSTRAINT fk_sales_device
        FOREIGN KEY (device_key)
        REFERENCES dim_device(device_key),

    CONSTRAINT fk_sales_currency
        FOREIGN KEY (currency_key)
        REFERENCES dim_currency(currency_key),

    INDEX idx_order_id (order_id),
    INDEX idx_order_timestamp (order_timestamp),
    INDEX idx_customer_key (customer_key),
    INDEX idx_product_key (product_key)

);

CREATE TABLE fact_snapshot_exchange_rate (

    -- Primary Key / Surrogate Key
    exchange_rate_snapshot_key BIGINT PRIMARY KEY AUTO_INCREMENT,

    -- Foreign Keys
    date_key BIGINT,
    base_currency_key BIGINT,
    target_currency_key BIGINT,

    -- Measures
    exchange_rate DECIMAL(18,6),

    -- Technical / Audit Columns
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,

    -- Constraints
    CONSTRAINT fk_exchange_date
        FOREIGN KEY (date_key)
        REFERENCES dim_date(date_key),

    CONSTRAINT fk_exchange_base_currency
        FOREIGN KEY (base_currency_key)
        REFERENCES dim_currency(currency_key),

    CONSTRAINT fk_exchange_target_currency
        FOREIGN KEY (target_currency_key)
        REFERENCES dim_currency(currency_key),

    UNIQUE KEY uk_exchange_rate (
        date_key,
        base_currency_key,
        target_currency_key
    ),

    INDEX idx_snapshot_timestamp (date_key)

);

{# Raw Data

    ↓

Staging

    ↓

Intermediate/Core

    ↓

Dimensions & Facts

    ↓

Data Mart #}