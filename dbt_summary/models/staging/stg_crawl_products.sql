WITH stg_dim_product__source AS (

    SELECT *
    FROM {{ source('glamira_src', 'react_batch_real') }}

),

stg_dim_product__rename AS (

    SELECT
        product_id,
        sku,
        name AS product_name,
        product_type,
        fall_back,
        collection AS crawl_collection,
        gender,
        priceCurrency AS currency_code
    FROM stg_dim_product__source

),

stg_dim_product__cast_type AS (

    SELECT
        CAST(product_id AS STRING) AS product_id,
        NULLIF(TRIM(CAST(sku AS STRING)), '') AS sku,
        NULLIF(TRIM(CAST(product_name AS STRING)), '') AS product_name,
        NULLIF(TRIM(CAST(product_type AS STRING)), '') AS product_type,
        NULLIF(TRIM(CAST(fall_back AS STRING)), '') AS fall_back,
        NULLIF(TRIM(CAST(crawl_collection AS STRING)), '') AS crawl_collection,
        NULLIF(TRIM(CAST(gender AS STRING)), '') AS gender,
        NULLIF(TRIM(CAST(currency_code AS STRING)), '') AS currency_code
    FROM stg_dim_product__rename

),

stg_dim_product__gen_key AS (

    SELECT
        FARM_FINGERPRINT(product_id) AS product_key,
        product_id,
        sku,
        product_name,
        product_type,
        fall_back,
        crawl_collection,
        gender,
        currency_code
    FROM stg_dim_product__cast_type

)

SELECT *
FROM stg_dim_product__gen_key