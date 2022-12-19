{{ config(enabled=var('ad_reporting__amazon_ads_enabled', True)) }}

with report as (
    select *
    from {{ var('targeting_keyword_report') }}
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

ad_groups as (
    select *
    from {{ var('ad_group_history') }}
    where is_most_recent_record = True
), 

keywords as (
    select *
    from {{ var('keyword_history') }}
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
        ad_groups.ad_group_name,
        ad_groups.ad_group_id,
        keywords.keyword_id,
        keywords.keyword_text,
        keywords.serving_status,
        keywords.state,
        report.keyword_bid,
        report.keyword_type,
        report.match_type,
        sum(report.cost) as cost,
        sum(report.clicks) as clicks,
        sum(report.impressions) as impressions 

        {{ fivetran_utils.persist_pass_through_columns(pass_through_variable='amazon_ads__ad_group_stats_passthrough_metrics', transform='sum') }}

    from report

    left join keywords
        on keywords.keyword_id = report.keyword_id
    left join ad_groups
        on ad_groups.ad_group_id = report.ad_group_id
    left join campaigns
        on campaigns.campaign_id = report.campaign_id
    left join portfolios
        on portfolios.portfolio_id = campaigns.portfolio_id
    left join account_info
        on account_info.profile_id = campaigns.profile_id

    {{ dbt_utils.group_by(18) }}
)

select *
from fields