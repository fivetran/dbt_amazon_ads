{{ config(enabled=var('ad_reporting__amazon_ads_enabled', True)) }}

with report as (
    select *
    from {{ var('campaign_level_report') }}
), 

account_info as (
    select *
    from {{ var('profile') }}
    where _fivetran_deleted = False
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

fields as (
    select
        report.date_day,
        account_info.account_name,
        account_info.account_id,
        account_info.country_code,
        account_info.profile_id,
        portfolios.portfolio_name,
        portfolios.portfolio_id,
        campaigns.campaign_name,
        campaigns.campaign_id,
        sum(report.cost) as cost,
        sum(report.clicks) as clicks,
        sum(report.impressions) as impressions 

        {{ fivetran_utils.persist_pass_through_columns(pass_through_variable='amazon_ads__ad_group_stats_passthrough_metrics', transform='sum') }}

    from report

    left join campaigns
        on campaigns.campaign_id = report.campaign_id
    left join portfolios
        on portfolios.portfolio_id = campaigns.portfolio_id
    left join account_info
        on account_info.profile_id = campaigns.profile_id

    {{ dbt_utils.group_by(9) }}
)

select *
from fields