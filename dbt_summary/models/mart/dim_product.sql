{{ config(materialized='table') }}

select

    {{ dbt_utils.generate_surrogate_key([
        'product_id'
    ]) }} as product_key,

    product_id,

    sku,

    product_name,

    product_type,

    collection_name,

    category_id,

    gender,

    current_timestamp() as created_at,

    current_timestamp() as updated_at

from {{ ref('int_products_attributes') }}