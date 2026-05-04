{{ config(enabled=var('ad_reporting__amazon_ads_enabled', True)) }}

{% set stg_tmp_relation = ref('stg_amazon_ads__advertised_product_report_tmp') %}

with base as (

    select *
    from {{ stg_tmp_relation }}
),

fields as (

select
    {{ amazon_ads.standardize_column_names(
        tmp_relation=stg_tmp_relation,
        table_name='advertised_product_report',
        base_columns=get_advertised_product_report_columns())
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
        cast(ad_id as {{ dbt.type_string() }}) as ad_id,
        cast(ad_group_id as {{ dbt.type_string() }}) as ad_group_id,
        advertised_asin,
        advertised_sku,
        campaign_budget_amount,
        campaign_budget_currency_code,
        campaign_budget_type,
        cast(campaign_id as {{ dbt.type_string() }}) as campaign_id,
        clicks,
        cost,
        date as date_day,
        impressions,
        purchases_30_d,
        sales_30_d

        {{ amazon_ads_fill_pass_through_columns(pass_through_fields=var('amazon_ads__advertised_product_passthrough_metrics'), except=['purchases_30_d', 'sales_30_d']) }}

    from fields
)

select *
from final
