{{ config(materialized='view') }}

with summary as (

    select *
    from {{ ref('stg_summary') }}

)

select
    _id,
    order_id,

    cast(cp.product_id as string) as product_id,

    cp.amount,
    cp.currency,

    safe_cast(cp.price as numeric) as unit_price,

    cp.option as options

from summary
cross join unnest(cart_products) cp