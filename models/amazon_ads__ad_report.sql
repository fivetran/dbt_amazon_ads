{{ config(enabled=var('ad_reporting__amazon_ads_enabled', True)) }}

with report as (
    select *
    from {{ var('advertised_product_report') }}
), 

{% if var('amazon_ads__portfolio_history_enabled', True) %}
portfolios as (
    select *
    from {{ var('portfolio_history') }}
    where is_most_recent_record = True
), 
{% endif %}

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

        {% if var('amazon_ads__portfolio_history_enabled', True) %}
        portfolio.portfolio_name,
        portfolio.portfolio_id,
        {% endif %}

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
        report.cost,
        report.clicks,
        report.impressions

        {{ fivetran_utils.persist_pass_through_columns(pass_through_variable='amazon_ads__advertised_product_passthrough_metrics') }}

    from report
    
    left join ads
        on report.ad_id = ads.ad_id
    left join ad_groups
        on report.ad_group_id = ad_groups.ad_group_id
    left join campaigns
        on report.campaign_id = campaigns.campaign_id

    {% if var('amazon_ads__portfolio_history_enabled', True) %}
        left join portfolios
            on campaigns.portfolio_id = portfolios.portfolio_id
    {% endif %}
)

select *
from fields