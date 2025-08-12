{{ config(enabled=var('ad_reporting__amazon_ads_enabled', True)) }}

with base as (

    select * 
    from {{ ref('stg_amazon_ads__keyword_history_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_amazon_ads__keyword_history_tmp')),
                staging_columns=get_keyword_history_columns()
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
        cast(id as {{ dbt.type_string() }}) as keyword_id,
        cast(ad_group_id as {{ dbt.type_string() }}) as ad_group_id,
        bid,
        cast(campaign_id as {{ dbt.type_string() }}) as campaign_id,
        creation_date,
        keyword_text,
        last_updated_date,
        match_type,
        native_language_keyword,
        serving_status,
        state,
        native_language_locale,
        row_number() over (partition by source_relation, id order by last_updated_date desc) = 1 as is_most_recent_record
    from fields
)

select *
from final
