{{ config(
    tags="fivetran_validations",
    enabled=var('fivetran_validation_tests_enabled', false)
) }}

with ad_report as (

    select 
        sum(purchases_30_d) as total_purchases_30_d,
        sum(sales_30_d) as total_sales_30_d
    from {{ ref('amazon_ads__ad_report') }}
),

account_report as (

    select 
        sum(purchases_30_d) as total_purchases_30_d,
        sum(sales_30_d) as total_sales_30_d
    from {{ ref('amazon_ads__account_report') }}
),

ad_group_report as (

    select 
        sum(purchases_30_d) as total_purchases_30_d,
        sum(sales_30_d) as total_sales_30_d
    from {{ ref('amazon_ads__ad_group_report') }}
),

campaign_report as (

    select 
        sum(purchases_30_d) as total_purchases_30_d,
        sum(sales_30_d) as total_sales_30_d
    from {{ ref('amazon_ads__campaign_report') }}
),

keyword_report as (

    select 
        sum(purchases_30_d) as total_purchases_30_d,
        sum(sales_30_d) as total_sales_30_d
    from {{ ref('amazon_ads__keyword_report') }}
),

portfolio_report as (

    select 
        sum(purchases_30_d) as total_purchases_30_d,
        sum(sales_30_d) as total_sales_30_d
    from {{ ref('amazon_ads__portfolio_report') }}
),

search_report as (

    select 
        sum(purchases_30_d) as total_purchases_30_d,
        sum(sales_30_d) as total_sales_30_d
    from {{ ref('amazon_ads__search_report') }}
)

select 
    'ad vs account' as comparison
from ad_report 
join account_report on true
where ad_report.total_purchases_30_d != account_report.total_purchases_30_d
    or ad_report.total_sales_30_d != account_report.total_sales_30_d

union all 

select 
    'campaign vs ad group' as comparison
from campaign_report 
join ad_group_report on true
where campaign_report.total_purchases_30_d != ad_group_report.total_purchases_30_d
    or campaign_report.total_sales_30_d != ad_group_report.total_sales_30_d

union all 

select 
    'portfolio vs campaign' as comparison
from portfolio_report 
join campaign_report on true
where portfolio_report.total_purchases_30_d != campaign_report.total_purchases_30_d
    or portfolio_report.total_sales_30_d != campaign_report.total_sales_30_d


union all 

select 
    'campaign vs keyword' as comparison
from campaign_report 
join keyword_report on true
where campaign_report.total_purchases_30_d != keyword_report.total_purchases_30_d
    or campaign_report.total_sales_30_d != keyword_report.total_sales_30_d
union all 

select 
    'search_term vs keyword' as comparison
from search_report 
join keyword_report on true
where search_report.total_purchases_30_d != keyword_report.total_purchases_30_d
    or search_report.total_sales_30_d != keyword_report.total_sales_30_d