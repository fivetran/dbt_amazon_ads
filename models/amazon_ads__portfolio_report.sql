{{ config(enabled=fivetran_utils.enabled_vars(['ad_reporting__amazon_ads_enabled','amazon_ads__portfolio_history_enabled'])) }}

with report as (
    select *
    --use campaign report since portfolio report not provided
    from {{ var('campaign_level_report') }}
), 

account_info as (
    select *
    from {{ var('profile') }}
    where _fivetran_deleted = False
),

portfolios as (
    select *
    from {{ var('portfolio_history') }}
    where is_most_recent_record = True
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
        portfolios.budget_amount,
        portfolios.budget_currency_code,
        portfolios.budget_start_date,
        portfolios.budget_end_date,
        portfolios.budget_policy,
        portfolios.in_budget,
        portfolios.serving_status,
        portfolios.state,
        sum(report.cost) as cost,
        sum(report.clicks) as clicks,
        sum(report.impressions) as impressions 

        --use campaign report since portfolio report not provided
        {{ fivetran_utils.persist_pass_through_columns(pass_through_variable='amazon_ads__campaign_passthrough_metrics', transform='sum') }}

    from portfolios

    left join campaigns
        on cast(campaigns.portfolio_id as {{ dbt.type_string() }}) = cast(portfolios.portfolio_id as {{ dbt.type_string() }})
    left join account_info
        on cast(account_info.profile_id as {{ dbt.type_string() }}) = cast(campaigns.profile_id as {{ dbt.type_string() }})
    left join report
        on cast(report.campaign_id as {{ dbt.type_string() }}) = cast(campaigns.campaign_id as {{ dbt.type_string() }})

    {{ dbt_utils.group_by(15) }}
)

select *
from fields