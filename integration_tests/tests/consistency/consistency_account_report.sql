{{ config(
    tags="fivetran_validations",
    enabled=var('fivetran_validation_tests_enabled', false)
) }}

with prod as (
    select
        account_id,
        sum(clicks) as clicks, 
        sum(impressions) as impressions,
        sum(cost) as cost
    from {{ target.schema }}_amazon_ads_prod.amazon_ads__account_report
    group by 1
),

dev as (
    select
        account_id,
        sum(clicks) as clicks, 
        sum(impressions) as impressions,
        sum(cost) as cost
    from {{ target.schema }}_amazon_ads_dev.amazon_ads__account_report
    group by 1
),

final as (
    select 
        prod.account_id,
        prod.clicks as prod_clicks,
        dev.clicks as dev_clicks,
        prod.impressions as prod_impressions,
        dev.impressions as dev_impressions,
        prod.cost as prod_cost,
        dev.cost as dev_cost
    from prod
    full outer join dev 
        on dev.account_id = prod.account_id
)

select *
from final
where
    abs(prod_clicks - dev_clicks) >= .01
    or abs(prod_impressions - dev_impressions) >= .01
    or abs(prod_cost - dev_cost) >= .01