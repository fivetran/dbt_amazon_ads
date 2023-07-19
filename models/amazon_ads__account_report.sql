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
        report.date_day,
        account_info.account_name,
        account_info.account_id,
        account_info.country_code,
        account_info.profile_id,
        sum(report.cost) as cost,
        sum(report.clicks) as clicks,
        sum(report.impressions) as impressions 

        --use campaign report since portfolio report not provided
        {{ fivetran_utils.persist_pass_through_columns(pass_through_variable='amazon_ads__campaign_passthrough_metrics', transform='sum') }}

    from report

    left join campaigns
        on cast(campaigns.campaign_id as {{ dbt.type_string() }}) = cast(report.campaign_id as {{ dbt.type_string() }})
    left join account_info
        on cast(account_info.profile_id as {{ dbt.type_string() }}) = cast(campaigns.profile_id as {{ dbt.type_string() }})
    

    {{ dbt_utils.group_by(5) }}
)

select *
from fields