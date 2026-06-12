WITH
    dim_location__source AS (
        SELECT
            *
        FROM {{ ref('stg_ip_locations') }}
    ),

    dim_location__get_distinct as (
        SELECT DISTINCT
            location_key,
            country_code,
            country_name,
            region_name,
            city_name
        FROM dim_location__source
    ),

    dim_location__add_default_values AS (
        SELECT
            location_key,
            country_code,
            country_name,
            region_name,
            city_name
        FROM dim_location__get_distinct
        WHERE NOT (
            country_code = '-'
            AND country_name = '-'
            AND region_name = '-'
            AND city_name = '-'
        )    
        UNION ALL

        SELECT
            CAST(-1 AS INT64) AS location_key,
            'UNKNOWN' AS country_code,
            'UNKNOWN' AS country_name,
            'UNKNOWN' AS region_name,
            'UNKNOWN' AS city_name
    )

    SELECT *
    FROM dim_location__add_default_values