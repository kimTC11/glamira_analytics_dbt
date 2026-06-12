{# Steps:
-- 1. Get data from source
-- 2. Unnest cart_products
-- 3. Unnest options
-- 4. Cast data types
#}

WITH stg_summary_cart_products_option__source AS (

    SELECT *
    FROM {{ source('glamira_src', 'summary_clean') }}
    WHERE collection = "checkout_success"
),



stg_summary_cart_products_option__unnest_cart_products AS (

    SELECT
        _id,
        order_id,
        cp

    FROM stg_summary_cart_products_option__source
    CROSS JOIN UNNEST(cart_products) AS cp

),

stg_summary_cart_products_option__unnest_options AS (

    SELECT
        _id,
        order_id,
        cp,
        op

    FROM stg_summary_cart_products_option__unnest_cart_products
    CROSS JOIN UNNEST(cp.option) AS op

),

stg_summary_cart_products_option__cast_type AS (

    SELECT
        CAST(_id AS STRING) AS source_id,
        CAST(order_id AS STRING) AS order_id,

        CAST(cp.product_id AS STRING) AS product_id,

        CAST(op.option_id AS STRING) AS option_id,
        NULLIF(TRIM(CAST(op.option_label AS STRING)), '') AS option_label,

        CAST(op.value_id AS STRING) AS value_id,
        NULLIF(TRIM(CAST(op.value_label AS STRING)), '') AS value_label

    FROM stg_summary_cart_products_option__unnest_options

)

SELECT *
FROM stg_summary_cart_products_option__cast_type