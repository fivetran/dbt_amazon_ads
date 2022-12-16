{{ config(enabled=var('ad_reporting__amazon_ads_enabled', True)) }}

with report as (
    select *
    --use campaign report since portfolio report not provided
    from {{ var('campaign_level_report') }}
), 

portfolios as (
    select
    {% if var('amazon_ads__portfolio_history_enabled', True) %}
        *
        from {{ var('portfolio_history') }}
        where is_most_recent_record = True
    {% else %}
        null as portfolio_name,
        null as portfolio_id,
        null as budget_amount,
        null as budget_currency_code,
        null as budget_start_date,
        null as budget_end_date,
        null as budget_policy,
        null as in_budget,
        null as serving_status,
        null as state
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
        {% if var('amazon_ads__portfolio_history_enabled', True) %}
        portfolios.portfolio_name,
        {% else %}
        "all campaigns" as portfolio_name,
        {% endif %}
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
        {{ fivetran_utils.persist_pass_through_columns(pass_through_variable='amazon_ads__campaign_stats_passthrough_metrics', transform='sum') }}

    from report

    left join campaigns
        on report.campaign_id = campaigns.campaign_id
    left join portfolios
        on campaigns.portfolio_id = portfolios.portfolio_id

    {{ dbt_utils.group_by(11) }}
)

select *
from fields