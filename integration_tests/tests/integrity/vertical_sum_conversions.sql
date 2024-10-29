{{ config(
    tags="fivetran_validations",
    enabled=var('fivetran_validation_tests_enabled', false)
) }}

with account_source as (

    select 
        sum(purchases_30_d) as total_purchases_30_d,
        sum(sales_30_d) as total_sales_30_d
    from {{ source('amazon_ads', 'campaign_level_report') }}
),

account_model as (

    select 
        sum(purchases_30_d) as total_purchases_30_d,
        sum(sales_30_d) as total_sales_30_d
    from {{ ref('amazon_ads__account_report') }}
),

portfolio_source as (

    select 
        sum(purchases_30_d) as total_purchases_30_d,
        sum(sales_30_d) as total_sales_30_d
    from {{ source('amazon_ads', 'campaign_level_report') }}
),

portfolio_model as (

    select 
        sum(purchases_30_d) as total_purchases_30_d,
        sum(sales_30_d) as total_sales_30_d
    from {{ ref('amazon_ads__portfolio_report') }}
),

campaign_source as (

    select 
        sum(purchases_30_d) as total_purchases_30_d,
        sum(sales_30_d) as total_sales_30_d
    from {{ source('amazon_ads', 'campaign_level_report') }}
),

campaign_model as (

    select 
        sum(purchases_30_d) as total_purchases_30_d,
        sum(sales_30_d) as total_sales_30_d
    from {{ ref('amazon_ads__campaign_report') }}
)

{# Comment out below when running on seed data #}
{# 
, ad_source as (

    select 
        sum(purchases_30_d) as total_purchases_30_d,
        sum(sales_30_d) as total_sales_30_d
    from {{ source('amazon_ads', 'advertised_product_report') }}
),

ad_model as (

    select 
        sum(purchases_30_d) as total_purchases_30_d,
        sum(sales_30_d) as total_sales_30_d
    from {{ ref('amazon_ads__ad_report') }}
),

ad_group_source as (

    select 
        sum(purchases_30_d) as total_purchases_30_d,
        sum(sales_30_d) as total_sales_30_d
    from {{ source('amazon_ads', 'ad_group_level_report') }}
),

ad_group_model as (

    select 
        sum(purchases_30_d) as total_purchases_30_d,
        sum(sales_30_d) as total_sales_30_d
    from {{ ref('amazon_ads__ad_group_report') }}
), 

search_source as (

    select 
        sum(purchases_30_d) as total_purchases_30_d,
        sum(sales_30_d) as total_sales_30_d
    from {{ source('amazon_ads', 'search_term_ad_keyword_report') }} as ad_performance
),

search_model as (

    select 
        sum(purchases_30_d) as total_purchases_30_d,
        sum(sales_30_d) as total_sales_30_d
    from {{ ref('amazon_ads__search_report') }}
),

keyword_source as (

    select 
        sum(purchases_30_d) as total_purchases_30_d,
        sum(sales_30_d) as total_sales_30_d
    from {{ source('amazon_ads', 'targeting_keyword_report') }}
),

keyword_model as (

    select 
        sum(coalesce(purchases_30_d, 0)) as total_purchases_30_d,
        sum(coalesce(sales_30_d, 0)) as total_sales_30_d
    from {{ ref('amazon_ads__keyword_report') }}
)

select 
    'ads' as comparison
from ad_model 
join ad_source on true
where abs(ad_model.total_sales_30_d - ad_source.total_sales_30_d) >= .01
    or abs(ad_model.total_purchases_30_d - ad_source.total_purchases_30_d) >= .01

union all  

select 
    'ad groups' as comparison
from ad_group_model 
join ad_group_source on true
where abs(ad_group_model.total_sales_30_d - ad_group_source.total_sales_30_d) >= .01
    or abs(ad_group_model.total_purchases_30_d - ad_group_source.total_purchases_30_d) >= .01

union all 

select 
    'keywords' as comparison
from keyword_model 
join keyword_source on true
where abs(keyword_model.total_sales_30_d - keyword_source.total_sales_30_d) >= .01
    or abs(keyword_model.total_purchases_30_d - keyword_source.total_purchases_30_d) >= .01

union all 

select 
    'search' as comparison
from search_model 
join search_source on true
where abs(search_model.total_sales_30_d - search_source.total_sales_30_d) >= .01
    or abs(search_model.total_purchases_30_d - search_source.total_purchases_30_d) >= .01 
    
union all
    #}


select 
    'accounts' as comparison
from account_model 
join account_source on true
where abs(account_model.total_sales_30_d - account_source.total_sales_30_d) >= .01
    or abs(account_model.total_purchases_30_d - account_source.total_purchases_30_d) >= .01

union all 

select 
    'portfolios' as comparison
from portfolio_model 
join portfolio_source on true
where abs(portfolio_model.total_sales_30_d - portfolio_source.total_sales_30_d) >= .01
    or abs(portfolio_model.total_purchases_30_d - portfolio_source.total_purchases_30_d) >= .01

union all 

select 
    'campaigns' as comparison
from campaign_model 
join campaign_source on true
where abs(campaign_model.total_sales_30_d - campaign_source.total_sales_30_d) >= .01
    or abs(campaign_model.total_purchases_30_d - campaign_source.total_purchases_30_d) >= .01

