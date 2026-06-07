{{ config(materialized='view') }}

with summary as (

    select *
    from {{ ref('stg_summary') }}

)

select
    s._id,
    s.order_id,

    cast(cp.product_id as string) as product_id,

    op.option_id,
    op.option_label,
    op.value_id,
    op.value_label

from summary s
cross join unnest(s.cart_products) cp
cross join unnest(cp.option) op