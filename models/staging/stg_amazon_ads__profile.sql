{{ config(enabled=var('ad_reporting__amazon_ads_enabled', True)) }}

with base as (

    select * 
    from {{ ref('stg_amazon_ads__profile_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_amazon_ads__profile_tmp')),
                staging_columns=get_profile_columns()
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
        cast(id as {{ dbt.type_string() }}) as profile_id,
        cast(account_id as {{ dbt.type_string() }}) as account_id,
        account_marketplace_string_id,
        account_name,
        account_sub_type,
        account_type,
        account_valid_payment_method,
        country_code,
        currency_code,
        daily_budget,
        timezone,
        _fivetran_deleted
    from fields
)

select *
from final
