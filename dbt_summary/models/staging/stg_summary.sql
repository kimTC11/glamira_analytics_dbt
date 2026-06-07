{{ config(materialized='view') }}

select
    _id,
    order_id,
    cast(product_id as string) as product_id,
    safe_cast(price as numeric) as price,
    is_paypal,
    currency,
    email_address,
    user_id_db,
    ip,
    device_id,
    cat_id,
    collect_id,
    collection,
    timestamp_millis(time_stamp) as order_timestamp,
    cart_products,
    option

from {{ source('glamira_src', 'summary_clean') }}