{{ config(enabled=var('ad_reporting__amazon_ads_enabled', True)) }}

with report as (
    select *
    from {{ var('ad_group_level_report') }}
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
        report.ad_group_id,
        ad_groups.serving_status,
        ad_groups.state,
        ad_groups.default_bid,
        report.campaign_bidding_strategy,
        sum(report.cost) as cost,
        sum(report.clicks) as clicks,
        sum(report.impressions) as impressions 

        {{ fivetran_utils.persist_pass_through_columns(pass_through_variable='amazon_ads__ad_group_passthrough_metrics', transform='sum') }}

    from report

    left join ad_groups
        on cast(ad_groups.ad_group_id as {{ dbt.type_string() }}) = cast(report.ad_group_id as {{ dbt.type_string() }})
    left join campaigns
        on cast(campaigns.campaign_id as {{ dbt.type_string() }}) = cast(ad_groups.campaign_id as {{ dbt.type_string() }})
    left join portfolios
        on cast(portfolios.portfolio_id as {{ dbt.type_string() }}) = cast(campaigns.portfolio_id as {{ dbt.type_string() }})
    left join account_info
        on cast(account_info.profile_id as {{ dbt.type_string() }}) = cast(campaigns.profile_id as {{ dbt.type_string() }})

    {{ dbt_utils.group_by(15) }}
)

select *
from fields