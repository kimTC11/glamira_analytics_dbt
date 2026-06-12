{# Steps:
-- 1. Generate date spine
-- 2. Generate date attributes
#}

WITH dim_date__generate_dates AS (

    SELECT
        date_day

    FROM UNNEST(
        GENERATE_DATE_ARRAY(
            DATE('2016-01-01'),
            DATE('2022-12-31')
        )
    ) AS date_day

),

dim_date__generate_attributes AS (

    SELECT

        CAST(
            FORMAT_DATE(
                '%Y%m%d',
                date_day
            ) AS INT64
        ) AS date_key,

        date_day AS full_date,

        EXTRACT(YEAR FROM date_day) AS year_number,

        EXTRACT(QUARTER FROM date_day) AS quarter_number,

        EXTRACT(MONTH FROM date_day) AS month_number,

        FORMAT_DATE('%B', date_day) AS month_name,

        EXTRACT(DAY FROM date_day) AS day_of_month,

        EXTRACT(DAYOFYEAR FROM date_day) AS day_of_year,

        EXTRACT(WEEK FROM date_day) AS week_number,

        FORMAT_DATE('%A', date_day) AS weekday_name,

        CASE
            WHEN EXTRACT(DAYOFWEEK FROM date_day) IN (1, 7)
                THEN TRUE
            ELSE FALSE
        END AS is_weekend,

        CURRENT_TIMESTAMP() AS created_at,

        CURRENT_TIMESTAMP() AS updated_at

    FROM dim_date__generate_dates

)

SELECT *
FROM dim_date__generate_attributes