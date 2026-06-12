{{ config(materialized='view') }}

WITH customer_source AS (

    SELECT
        user_id_db,
        email_address,
        device_id,
        is_paypal,
        order_timestamp

    FROM {{ ref('stg_summary') }}

    WHERE user_id_db IS NOT NULL

),

latest_customer AS (

    SELECT *

    FROM customer_source

    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY user_id_db
        ORDER BY order_timestamp DESC
    ) = 1

)

SELECT
    user_id_db,
    email_address,
    device_id,
    is_paypal
FROM latest_customer