{{ config(enabled=var('ad_reporting__amazon_ads_enabled', True)) }}

{% set stg_tmp_relation = ref('stg_amazon_ads__ad_group_history_tmp') %}

with base as (

    select *
    from {{ stg_tmp_relation }}
),

fields as (

select
    {{ amazon_ads.standardize_column_names(
        tmp_relation=stg_tmp_relation,
        table_name='ad_group_history',
        base_columns=get_ad_group_history_columns())
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
        cast(id as {{ dbt.type_string() }}) as ad_group_id,
        cast(campaign_id as {{ dbt.type_string() }}) as campaign_id,
        creation_date,
        default_bid,
        last_updated_date,
        name as ad_group_name,
        serving_status,
        state,
        row_number() over (partition by source_relation, id order by last_updated_date desc) = 1 as is_most_recent_record
    from fields
)

select *
from final
