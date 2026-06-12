with source as (

    select *

    from {{ source('reference', 'currency_mapping') }}

),

currencies as (

    select distinct

        iso_code as currency_code,

        currency_name,

        raw_currency

    from source

    where iso_code is not null
        and confidence > 0.0

)

select

    {{ dbt_utils.generate_surrogate_key(['currency_code']) }}

        as currency_key,

    currency_code,

    currency_name,

    raw_currency as currency_before,

    current_datetime() as created_at,

    current_datetime() as updated_at

from currencies