WITH stg_sales_order_detail__source AS (

    SELECT *
    FROM {{ source('glamira_src', 'summary_clean') }}

),

stg_sales_order_detail__success_checkout AS (

    SELECT *
    FROM stg_sales_order_detail__source
    WHERE collection = 'checkout_success'

),

stg_sales_order_detail__rename AS (

    SELECT
        order_id,
        product_id,
        is_paypal,
        email_address,
        user_id_db,
        ip AS ip_address,
        device_id,
        cat_id AS category_id,
        collect_id AS collection_id,
        collection,
        time_stamp
    FROM stg_sales_order_detail__success_checkout

),

stg_sales_order_detail__cast_type AS (

    SELECT
        CAST(order_id AS STRING) AS order_id,
        CAST(product_id AS STRING) AS product_id,
        CAST(is_paypal AS BOOL) AS is_paypal,
        CAST(email_address AS STRING) AS email_address,
        CAST(user_id_db AS STRING) AS user_id_db,
        CAST(ip_address AS STRING) AS ip_address,
        CAST(device_id AS STRING) AS device_id,
        CAST(category_id AS STRING) AS category_id,
        CAST(collection_id AS STRING) AS collection_id,
        CAST(collection AS STRING) AS collection,
        TIMESTAMP_MILLIS(time_stamp) AS order_timestamp
    FROM stg_sales_order_detail__rename

)

SELECT *
FROM stg_sales_order_detail__cast_type