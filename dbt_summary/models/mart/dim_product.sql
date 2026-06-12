WITH dim_product__source AS (

    SELECT *
    FROM {{ ref('stg_crawl_products') }}

)

SELECT
    product_key,
    product_id,
    sku,
    product_name,
    product_type,
    crawl_collection,
    gender
FROM dim_product__source