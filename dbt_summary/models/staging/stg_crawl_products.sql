{{ config(materialized='view') }}

select

    cast(product_id as string) as  product_id,
    sku,
    name as product_name,
    product_type,
    fall_back,
    collection as crawl_collection,
    gender,
    priceCurrency as crawl_price_currency

from {{ source('glamira_src', 'react_batch_real') }}