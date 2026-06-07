{{ config(materialized='view') }}

select

    ip as ip_address,

    nullif(country_code, '-') as country_code,
    nullif(country_name, '-') as country_name,
    nullif(region_name, '-') as region_name,
    nullif(city_name, '-') as city_name

from {{ source('glamira_src', 'ip_locations') }}