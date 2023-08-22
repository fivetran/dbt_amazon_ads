ADD source_relation WHERE NEEDED + CHECK JOINS AND WINDOW FUNCTIONS! (Delete this line when done.)

{{ config(enabled=var('ad_reporting__amazon_ads_enabled', True)) }}

with report as (
    select *
    from {{ var('search_term_ad_keyword_report') }}
), 

account_info as (
    select *
    from {{ var('profile') }}
    where _fivetran_deleted = False
),

portfolios as (
    select *
    from {{ ref('int_amazon_ads__portfolio_history') }}
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
        report.campaign_id,
        ad_groups.ad_group_name,
        report.ad_group_id,
        report.keyword_id,
        keywords.keyword_text,
        keywords.match_type,
        keywords.serving_status,
        keywords.state,
        report.search_term,
        report.targeting,
        sum(report.cost) as cost,
        sum(report.clicks) as clicks,
        sum(report.impressions) as impressions 

        {{ fivetran_utils.persist_pass_through_columns(pass_through_variable='amazon_ads__search_term_ad_keyword_passthrough_metrics', transform='sum') }}

    from report

    left join keywords
        on keywords.keyword_id = report.keyword_id
        and keyword_id.source_relation = keyword_id.source_relation
    left join ad_groups
        on ad_groups.ad_group_id = report.ad_group_id
        and ad_group_id.source_relation = ad_group_id.source_relation
    left join campaigns
        on campaigns.campaign_id = report.campaign_id
        and campaign_id.source_relation = campaign_id.source_relation
    left join portfolios
        on portfolios.portfolio_id = campaigns.portfolio_id
        and portfolio_id.source_relation = portfolio_id.source_relation
    left join account_info
        on account_info.profile_id = campaigns.profile_id
        and profile_id.source_relation = profile_id.source_relation

    {{ dbt_utils.group_by(18) }}
)

select *
from fields