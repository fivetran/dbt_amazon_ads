{{ config(enabled=var('ad_reporting__amazon_ads_enabled', True)) }}

with report as (
    select *
    --use campaign report since account report not provided
    from {{ var('campaign_level_report') }}
), 

account_info as (
    select *
    from {{ var('profile') }}
    where _fivetran_deleted = False
),

campaigns as (
    select *
    from {{ var('campaign_history') }}
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
        sum(report.cost) as cost,
        sum(report.clicks) as clicks,
        sum(report.impressions) as impressions,
        sum(report.purchases_30_d) as purchases_30_d,
        sum(report.sales_30_d) as sales_30_d

        {{ amazon_ads_persist_pass_through_columns(pass_through_variable='amazon_ads__campaign_passthrough_metrics', identifier='report', transform='sum', coalesce_with=0, exclude_fields=['purchases_30_d','sales_30_d']) }}

    from report

    left join campaigns
        on campaigns.campaign_id = report.campaign_id
        and campaigns.source_relation = report.source_relation
    left join account_info
        on account_info.profile_id = campaigns.profile_id
        and account_info.source_relation = campaigns.source_relation
    

    {{ dbt_utils.group_by(6) }}
)

select *
from fields