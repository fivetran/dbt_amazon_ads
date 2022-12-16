{{ config(enabled=var('ad_reporting__amazon_ads_enabled', True)) }}

with report as (
    select *
    from {{ var('advertised_product_report') }}
), 

portfolios as (
    select
    {% if var('amazon_ads__portfolio_history_enabled', True) %}
        *
        from {{ var('portfolio_history') }}
        where is_most_recent_record = True
    {% else %}
        null as portfolio_name,
        null as portfolio_id
    {% endif %}
), 

campaigns as (
    select *
    from {{ var('campaign_history') }}
    where is_most_recent_record = True
),

ad_groups as (
    select *
    from {{ var('ad_group_history') }}
    where is_most_recent_record = True
), 

ads as (
    select *
    from {{ var('product_ad_history') }}
    where is_most_recent_record = True
),

fields as (
    select
        report.date_day,
        portfolios.portfolio_name,
        portfolios.portfolio_id,
        campaigns.campaign_name,
        campaigns.campaign_id,
        ad_groups.ad_group_name,
        ad_groups.ad_group_id,
        ads.ad_id,
        ads.serving_status,
        ads.state,
        report.advertised_asin,
        report.advertised_sku,
        report.campaign_budget_amount,
        report.campaign_budget_currency_code,
        report.campaign_budget_type,
        sum(report.cost) as cost,
        sum(report.clicks) as clicks,
        sum(report.impressions) as impressions 

        {{ fivetran_utils.persist_pass_through_columns(pass_through_variable='amazon_ads__advertised_product_passthrough_metrics', transform='sum') }}

    from report
    
    left join ads
        on report.ad_id = ads.ad_id
    left join ad_groups
        on report.ad_group_id = ad_groups.ad_group_id
    left join campaigns
        on report.campaign_id = campaigns.campaign_id
    left join portfolios
        on campaigns.portfolio_id = portfolios.portfolio_id

    {{ dbt_utils.group_by(15) }}
)

select *
from fields