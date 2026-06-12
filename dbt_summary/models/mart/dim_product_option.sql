WITH dim_product_option__source AS (

    SELECT *
    FROM {{ ref('stg_summary_cart_products_option') }}

),

dim_product_option__get_distinct AS (

    SELECT DISTINCT
        option_id,
        option_label

    FROM dim_product_option__source

),

dim_product_option__add_default_values AS (

    SELECT
        option_id,

        COALESCE(
            option_label,
            'Unknown'
        ) AS option_label

    FROM dim_product_option__get_distinct

),

dim_product_option__gen_key AS (

    SELECT
        FARM_FINGERPRINT(option_id) AS option_key,
        option_id,
        option_label

    FROM dim_product_option__add_default_values

)

SELECT *
FROM dim_product_option__gen_key