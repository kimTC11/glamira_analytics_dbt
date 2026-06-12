
WITH customer_source AS (

    SELECT *
    FROM {{ ref('scd_customer') }}

),

rename_columns AS (

    SELECT

        user_id_db,
        email_address,
        device_id,
        is_paypal,

        dbt_valid_from AS effective_start_datetime,

        COALESCE(
            dbt_valid_to,
            TIMESTAMP('9999-12-31')
        ) AS effective_end_datetime

    FROM customer_source

),

add_flags AS (

    SELECT

        *,

        effective_end_datetime =
        TIMESTAMP('9999-12-31')

        AS is_current

    FROM rename_columns

),

add_version AS (

    SELECT

        *,

        ROW_NUMBER() OVER (
            PARTITION BY user_id_db
            ORDER BY effective_start_datetime
        ) AS version_number

    FROM add_flags

),

generate_key AS (

    SELECT

        {{ dbt_utils.generate_surrogate_key([
            'user_id_db',
            'effective_start_datetime'
        ]) }} AS customer_key,

        *

    FROM add_version

)

SELECT *
FROM generate_key   

{# WITH dim_customer__source AS (

    SELECT *
    FROM {{ ref('scd_customer') }}

),

dim_customer__rename_columns AS (

    SELECT

        user_id_db,
        email_address,
        device_id,
        is_paypal,

        dbt_valid_from AS effective_start_datetime,
        dbt_valid_to AS effective_end_datetime

    FROM dim_customer__source

),

dim_customer__add_current_flag AS (

    SELECT

        *,

        CASE
            WHEN effective_end_datetime IS NULL
                THEN TRUE
            ELSE FALSE
        END AS is_current

    FROM dim_customer__rename_columns

),

dim_customer__add_version_number AS (

    SELECT

        *,

        ROW_NUMBER() OVER (
            PARTITION BY user_id_db
            ORDER BY effective_start_datetime
        ) AS version_number

    FROM dim_customer__add_current_flag

),

dim_customer__generate_key AS (

    SELECT

        {{ dbt_utils.generate_surrogate_key([
            'user_id_db',
            'effective_start_datetime'
        ]) }} AS customer_key,

        user_id_db,
        email_address,
        device_id,
        is_paypal,

        effective_start_datetime,
        effective_end_datetime,

        is_current,
        version_number,

        CURRENT_TIMESTAMP() AS created_at,
        CURRENT_TIMESTAMP() AS updated_at

    FROM dim_customer__add_version_number

)

SELECT *
FROM dim_customer__generate_key


{# How to join with fact table
LEFT JOIN dim_customer dc
    ON so.user_id_db = dc.user_id_db
    AND so.order_timestamp >= dc.effective_start_datetime
    AND (
        so.order_timestamp < dc.effective_end_datetime
        OR dc.effective_end_datetime IS NULL
    ) #}

