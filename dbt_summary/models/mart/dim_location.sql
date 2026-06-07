{{ config(materialized='table') }}

select distinct

    {{ dbt_utils.generate_surrogate_key([
        'country_code',
        'country_name',
        'region_name',
        'city_name'
    ]) }} as location_key,

    country_code,
    country_name,
    region_name,
    city_name,

    current_datetime() as created_at,
    current_datetime() as updated_at

from {{ ref('stg_ip_locations') }}