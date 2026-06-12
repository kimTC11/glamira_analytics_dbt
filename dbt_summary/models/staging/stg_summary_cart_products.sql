{# Steps:
-- 1. Get data from source
-- 2. Unnest cart_products
-- 3. Cast data types
#}

WITH stg_summary_cart_products__source_checkout_success AS (

    SELECT *
    FROM {{ source('glamira_src', 'summary_clean') }}
    WHERE collection = "checkout_success"
),

stg_summary_cart_products__unnest AS (

    SELECT
        _id,
        order_id,
        cp
    FROM stg_summary_cart_products__source_checkout_success
    CROSS JOIN UNNEST(cart_products) AS cp

),

stg_summary_cart_products__cast_type AS (

    SELECT
        CAST(_id AS STRING) AS source_id,
        CAST(order_id AS STRING) AS order_id,
        CAST(cp.product_id AS STRING) AS product_id,
        SAFE_CAST(cp.amount AS INT64) AS quantity,
        CAST(cp.currency AS STRING) AS raw_currency_code,
        SAFE_CAST(cp.price AS NUMERIC) AS unit_price
    FROM stg_summary_cart_products__unnest

)

SELECT *
FROM stg_summary_cart_products__cast_type