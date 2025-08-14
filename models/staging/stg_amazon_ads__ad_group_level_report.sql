{{ config(enabled=var('ad_reporting__amazon_ads_enabled', True)) }}
with base as (

    select * 
    from {{ ref('stg_amazon_ads__ad_group_level_report_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_amazon_ads__ad_group_level_report_tmp')),
                staging_columns=get_ad_group_level_report_columns()
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
        cast(ad_group_id as {{ dbt.type_string() }}) as ad_group_id,
        campaign_bidding_strategy,
        clicks,
        cost,
        date as date_day,
        impressions,
        purchases_30_d,
        sales_30_d
        
        {{ amazon_ads_fill_pass_through_columns(pass_through_fields=var('amazon_ads__ad_group_passthrough_metrics'), except=['purchases_30_d', 'sales_30_d']) }}

    from fields
)

select *
from final
