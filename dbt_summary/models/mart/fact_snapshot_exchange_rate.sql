WITH fact_snapshot_exchange_rate__date AS (

    SELECT *
    FROM {{ ref('dim_date') }}

),

fact_snapshot_exchange_rate__rates AS (

    SELECT *
    FROM {{ ref('exchange_rates') }}

),

fact_snapshot_exchange_rate__currency AS (

    SELECT *
    FROM {{ ref('dim_currency') }}

),

fact_snapshot_exchange_rate__join_currency AS (

    SELECT

        d.date_key,

        c.currency_key,

        r.currency_code,

        r.usd_rate

    FROM fact_snapshot_exchange_rate__date d

    CROSS JOIN fact_snapshot_exchange_rate__rates r

    LEFT JOIN fact_snapshot_exchange_rate__currency c
        ON r.currency_code = c.currency_code

),

fact_snapshot_exchange_rate__generate_key AS (

    SELECT

        FARM_FINGERPRINT(
            CONCAT(
                CAST(date_key AS STRING),
                '|',
                CAST(currency_key AS STRING)
            )
        ) AS exchange_rate_snapshot_key,

        date_key,

        currency_key,

        usd_rate AS exchange_rate,

        CURRENT_TIMESTAMP() AS created_at

    FROM fact_snapshot_exchange_rate__join_currency

)

SELECT *
FROM fact_snapshot_exchange_rate__generate_key