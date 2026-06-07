{% snapshot scd_customer %}

{{
    config(
        target_schema='snapshots',
        unique_key='user_id_db',
        strategy='timestamp',
        updated_at='order_timestamp'
    )
}}

with source as (

    select *
    from {{ ref('stg_summary') }}
    where user_id_db is not null

)

select
    user_id_db,
    email_address,
    device_id,
    is_paypal,
    order_timestamp

from source

{% endsnapshot %}