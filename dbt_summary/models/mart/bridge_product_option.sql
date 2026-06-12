WITH bridge_product_option__source AS (

    SELECT *
    FROM {{ ref('stg_summary_cart_products_option') }}

),

bridge_product_option__get_distinct AS (

    SELECT DISTINCT
        product_id,
        option_id,
        value_id

    FROM bridge_product_option__source

),

bridge_product_option__gen_keys AS (

    SELECT
        FARM_FINGERPRINT(product_id) AS product_key,
        FARM_FINGERPRINT(option_id) AS option_key,
        FARM_FINGERPRINT(value_id) AS option_value_key

    FROM bridge_product_option__get_distinct

)

SELECT *
FROM bridge_product_option__gen_keys