{{ config(materialized='view') }}

with order_products as (

    select distinct
        cast(product_id as string) as product_id,
        cast(cat_id as string) as category_id,
        collection as collection_name

    from {{ ref('stg_summary') }}

),

crawl_products as (

    select *
    from {{ ref('stg_crawl_products') }}

)

select
    cp.product_id,
    cp.sku,
    cp.product_name,
    cp.product_type,
    op.collection_name,
    cp.crawl_collection,
    op.category_id,
    cp.gender,
    cp.crawl_price_currency

from crawl_products cp
left join order_products op
    on cp.product_id = op.product_id