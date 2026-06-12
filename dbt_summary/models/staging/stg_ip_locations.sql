



{# 3 steps:
-- 1, getting data from raw source
-- 2, suitable name changing
-- 3, type_casting each fields carefully
-- 4, generating surrogate key #}

WITH stg_dim_location__source AS (
    select * 
from {{ source('glamira_src', 'ip_locations') }}),

stg_dim_location__rename AS (
    SELECT
        ip as ip_address,
        country_code as country_code,
        country_name as country_name,
        region_name as region_name,
        city_name as city_name

FROM stg_dim_location__source
),

stg_dim_location__cast_type AS(
    SELECT 
        CAST(ip_address AS STRING) AS ip_address,
        CAST(country_code AS STRING) AS country_code,
        CAST(country_name AS STRING) AS country_name,
        CAST(region_name AS STRING) AS region_name,
        CAST(city_name AS STRING) AS city_name
    FROM stg_dim_location__rename
),

stg_dim_location__gen_key AS (
    SELECT
        ip_address,
        country_code,
        country_name,
        region_name,
        city_name,
        {{ dbt_utils.generate_surrogate_key([
            'country_code',
            'region_name',
            'city_name'
        ]) }} AS location_key
    FROM stg_dim_location__cast_type
)

select
    *
from stg_dim_location__gen_key
