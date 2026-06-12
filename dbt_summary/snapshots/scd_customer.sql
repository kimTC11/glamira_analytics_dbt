{# {% snapshot scd_customer %}

{{
    config(
        target_schema='snapshots',
        unique_key='user_id_db',
        strategy='check',
        check_cols=[
            'email_address',
            'device_id',
            'is_paypal'
        ]
    )
}}

WITH scd_customer__source AS (

    SELECT *
    FROM {{ ref('stg_summary') }}

),

scd_customer__filter_valid_customer AS (

    SELECT
        user_id_db,
        email_address,
        device_id,
        is_paypal

    FROM scd_customer__source

    WHERE user_id_db IS NOT NULL

),

scd_customer__get_distinct AS (

    SELECT DISTINCT
        user_id_db,
        email_address,
        device_id,
        is_paypal

    FROM scd_customer__filter_valid_customer

)

SELECT *
FROM scd_customer__get_distinct

{% endsnapshot %} #}


{% snapshot scd_customer %}

{{
    config(
        target_schema='snapshots',
        unique_key='user_id_db',

        strategy='check',

        check_cols=[
            'email_address',
            'device_id',
            'is_paypal'
        ]
    )
}}

SELECT *
FROM {{ ref('int_customer_current') }}

{% endsnapshot %}