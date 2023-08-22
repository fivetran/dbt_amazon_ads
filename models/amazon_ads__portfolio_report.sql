ADD source_relation WHERE NEEDED + CHECK JOINS AND WINDOW FUNCTIONS! (Delete this line when done.)

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
        on campaigns.portfolio_id = portfolios.portfolio_id
        and portfolio_id.source_relation = portfolio_id.source_relation
    left join account_info
        on account_info.profile_id = campaigns.profile_id
        and profile_id.source_relation = profile_id.source_relation
    left join report
        on report.campaign_id = campaigns.campaign_id
        and campaign_id.source_relation = campaign_id.source_relation

    {{ dbt_utils.group_by(15) }}
)

select *
from fields