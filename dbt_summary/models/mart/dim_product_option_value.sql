WITH dim_product_option_value__source AS (

    SELECT *
    FROM {{ ref('stg_summary_cart_products_option') }}

),

dim_product_option_value__get_distinct AS (

    SELECT DISTINCT
        value_id,
        value_label

    FROM dim_product_option_value__source

),

dim_product_option_value__add_default_values AS (

    SELECT
        value_id,

        COALESCE(
            value_label,
            'Unknown'
        ) AS value_label

    FROM dim_product_option_value__get_distinct

),

dim_product_option_value__gen_key AS (

    SELECT
        FARM_FINGERPRINT(value_id) AS option_value_key,
        value_id,
        value_label

    FROM dim_product_option_value__add_default_values

)

SELECT *
FROM dim_product_option_value__gen_key