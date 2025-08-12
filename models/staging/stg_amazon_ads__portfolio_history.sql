{{ config(enabled=fivetran_utils.enabled_vars(['ad_reporting__amazon_ads_enabled','amazon_ads__portfolio_history_enabled'])) }}

with base as (

    select * 
    from {{ ref('stg_amazon_ads__portfolio_history_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_amazon_ads__portfolio_history_tmp')),
                staging_columns=get_portfolio_history_columns()
            )
        }}
    
        {{ fivetran_utils.source_relation(
            union_schema_variable='amazon_ads_union_schemas', 
            union_database_variable='amazon_ads_union_databases') 
        }}

    from base
),

final as (

    select
        source_relation, 
        cast(id as {{ dbt.type_string() }}) as portfolio_id,
        budget_amount,
        budget_currency_code,
        budget_end_date,
        budget_policy,
        budget_start_date,
        creation_date,
        in_budget,
        last_updated_date,
        name as portfolio_name,
        cast(profile_id as {{ dbt.type_string() }}) as profile_id,
        serving_status,
        state,
        row_number() over (partition by source_relation, id order by last_updated_date desc) = 1 as is_most_recent_record
    from fields
)

select *
from final
