{{
    config(
        materialized='incremental',
        incremental_strategy='merge',
        unique_key='sales_order_detail_key',
        on_schema_change='sync_all_columns'
    )
}}

{# Steps:
-- 1. Get source data
-- 2. Join order header and order line
-- 3. Remove duplicates
-- 4. Lookup dimensions
-- 5. Generate fact key
#}

WITH fact_sales_order_detail__sales_order AS (

    SELECT *
    FROM {{ ref('stg_sales_order_detail') }}

    {% if is_incremental() %}
        {# WHERE DATE(order_timestamp)
            >= DATE_ADD(CURRENT_DATE(), INTERVAL -3 DAY) #}
    {% endif %}

),

fact_sales_order_detail__cart_products AS (

    SELECT *
    FROM {{ ref('stg_summary_cart_products') }}

),

fact_sales_order_detail__join_source AS (

    SELECT

        so.order_id,
        so.user_id_db,
        so.email_address,
        so.device_id,
        so.ip_address,
        so.is_paypal,
        so.order_timestamp,

        cp.product_id,
        cp.currency_code,
        cp.quantity,
        cp.unit_price

    FROM fact_sales_order_detail__sales_order so

    INNER JOIN fact_sales_order_detail__cart_products cp
        ON so.order_id = cp.order_id

),

fact_sales_order_detail__remove_duplicate AS (

    SELECT *
    FROM (

        SELECT

            *,

            ROW_NUMBER() OVER (
                PARTITION BY order_id, product_id
                ORDER BY
                    order_timestamp DESC,
                    quantity DESC,
                    unit_price DESC
            ) AS row_num

        FROM fact_sales_order_detail__join_source

    )

    WHERE row_num = 1

),

fact_sales_order_detail__lookup_product AS (

    SELECT

        f.*,

        dp.product_key

    FROM fact_sales_order_detail__remove_duplicate f

    LEFT JOIN {{ ref('dim_product') }} dp
        ON f.product_id = dp.product_id

),

fact_sales_order_detail__lookup_currency AS (

    SELECT

        f.*,

        dc.currency_key

    FROM fact_sales_order_detail__lookup_product f

    LEFT JOIN {{ ref('dim_currency') }} dc
        ON f.currency_code = dc.currency_code

),

fact_sales_order_detail__lookup_date AS (

    SELECT

        f.*,

        dd.date_key

    FROM fact_sales_order_detail__lookup_currency f

    LEFT JOIN {{ ref('dim_date') }} dd
        ON DATE(f.order_timestamp) = dd.full_date

),

fact_sales_order_detail__lookup_customer AS (

    SELECT

        f.*,

        dc.customer_key

    FROM fact_sales_order_detail__lookup_date f

    LEFT JOIN {{ ref('dim_customer') }} dc
        ON f.user_id_db = dc.user_id_db
        AND f.order_timestamp >= dc.effective_start_datetime
        AND (
            f.order_timestamp < dc.effective_end_datetime
            {# OR dc.effective_end_datetime IS NULL #}
        )

),

fact_sales_order_detail__lookup_location AS (

    SELECT

        f.*,

        COALESCE(dl.location_key, -1) AS location_key

    FROM fact_sales_order_detail__lookup_customer f

    LEFT JOIN {{ ref('dim_location') }} dl
        ON f.ip_address = dl.ip_address

),

fact_sales_order_detail__final AS (

    SELECT

        FARM_FINGERPRINT(
            CONCAT(
                COALESCE(order_id, ''),
                '|',
                COALESCE(product_id, '')
            )
        ) AS sales_order_detail_key,

        COALESCE(customer_key, -1) AS customer_key,

        COALESCE(product_key, -1) AS product_key,

        COALESCE(date_key, -1) AS date_key,

        COALESCE(location_key, -1) AS location_key,

        COALESCE(currency_key, -1) AS currency_key,

        COALESCE(ip_address, 'UNKNOWN') AS ip_address,

        order_id,

        quantity AS order_quantity,

        unit_price,

        is_paypal,

        FALSE AS is_recommendation,

        order_timestamp,

        CURRENT_TIMESTAMP() AS created_at,

        CURRENT_TIMESTAMP() AS updated_at

    FROM fact_sales_order_detail__lookup_location

)

SELECT *
FROM fact_sales_order_detail__final