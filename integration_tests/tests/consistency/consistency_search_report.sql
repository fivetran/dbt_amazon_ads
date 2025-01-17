{{ config(
    tags="fivetran_validations",
    enabled=var('fivetran_validation_tests_enabled', false)
) }}

with prod as (
    select
        search_term,
        keyword_id,
        sum(clicks) as clicks, 
        sum(impressions) as impressions,
        sum(cost) as cost
        {# sum(purchases_30_d) as total_purchases_30_d,
        sum(sales_30_d) as total_sales_30_d #}
    from {{ target.schema }}_amazon_ads_prod.amazon_ads__search_report
    group by 1,2
),

dev as (
    select
        search_term,
        keyword_id,
        sum(clicks) as clicks, 
        sum(impressions) as impressions,
        sum(cost) as cost
        {# sum(purchases_30_d) as total_purchases_30_d,
        sum(sales_30_d) as total_sales_30_d #}
    from {{ target.schema }}_amazon_ads_dev.amazon_ads__search_report
    group by 1,2
),

final as (
    select 
        prod.search_term,
        prod.keyword_id,
        prod.clicks as prod_clicks,
        dev.clicks as dev_clicks,
        prod.impressions as prod_impressions,
        dev.impressions as dev_impressions,
        prod.cost as prod_cost,
        dev.cost as dev_cost
        {# prod.purchases_30_d as prod_purchases_30_d,
        dev.purchases_30_d as dev_purchases_30_d,
        prod.sales_30_d as prod_sales_30_d,
        dev.sales_30_d as dev_sales_30_d #}
    from prod
    full outer join dev 
        on dev.search_term = prod.search_term
        and dev.keyword_id = prod.keyword_id

)

select *
from final
where
    abs(prod_clicks - dev_clicks) >= .01
    or abs(prod_impressions - dev_impressions) >= .01
    or abs(prod_cost - dev_cost) >= .01
    {# or abs(prod_purchases_30_d - dev_purchases_30_d) >= .01
    or abs(prod_sales_30_d - dev_sales_30_d) >= .01 #}