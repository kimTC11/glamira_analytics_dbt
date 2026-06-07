{{ config(materialized='table') }}

select

    -- SURROGATE KEY
    {{ dbt_utils.generate_surrogate_key([
        'user_id_db',
        'dbt_valid_from'
    ]) }} as customer_key,

    user_id_db,
    email_address,
    device_id,
    is_paypal,

    dbt_valid_from as effective_start_datetime,
    dbt_valid_to as effective_end_datetime,

    case
        when dbt_valid_to is null then true
        else false
    end as is_current,

    row_number() over (
        partition by user_id_db
        order by dbt_valid_from
    ) as version_number,

    current_timestamp() as created_at,
    current_timestamp() as updated_at

from {{ ref('scd_customer') }}