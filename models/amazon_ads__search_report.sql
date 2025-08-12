{{ config(enabled=var('ad_reporting__amazon_ads_enabled', True)) }}

with report as (
    select *
    from {{ ref('stg_amazon_ads__search_term_ad_keyword_report') }}
), 

account_info as (
    select *
    from {{ ref('stg_amazon_ads__profile') }}
    where _fivetran_deleted = False
),

portfolios as (
    select *
    from {{ ref('int_amazon_ads__portfolio_history') }}
), 

campaigns as (
    select *
    from {{ ref('stg_amazon_ads__campaign_history') }}
    where is_most_recent_record = True
),

ad_groups as (
    select *
    from {{ ref('stg_amazon_ads__ad_group_history') }}
    where is_most_recent_record = True
), 

keywords as (
    select *
    from {{ ref('stg_amazon_ads__keyword_history') }}
    where is_most_recent_record = True
), 

fields as (
    select
        report.source_relation,
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
        sum(report.impressions) as impressions,
        sum(report.purchases_30_d) as purchases_30_d,
        sum(report.sales_30_d) as sales_30_d

        {{ amazon_ads_persist_pass_through_columns(pass_through_variable='amazon_ads__search_term_ad_keyword_passthrough_metrics', identifier='report', transform='sum', coalesce_with=0, exclude_fields=['purchases_30_d','sales_30_d']) }} 

    from report

    left join keywords
        on keywords.keyword_id = report.keyword_id
        and keywords.source_relation = report.source_relation
    left join ad_groups
        on ad_groups.ad_group_id = report.ad_group_id
        and ad_groups.source_relation = report.source_relation
    left join campaigns
        on campaigns.campaign_id = report.campaign_id
        and campaigns.source_relation = report.source_relation
    left join portfolios
        on portfolios.portfolio_id = campaigns.portfolio_id
        and portfolios.source_relation = campaigns.source_relation
    left join account_info
        on account_info.profile_id = campaigns.profile_id
        and account_info.source_relation = campaigns.source_relation

    {{ dbt_utils.group_by(19) }}
)

select *
from fields