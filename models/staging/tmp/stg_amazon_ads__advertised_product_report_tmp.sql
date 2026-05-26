{{ config(enabled=var('ad_reporting__amazon_ads_enabled', True)) }}

{% if var('amazon_ads_sources',[]) != [] %}

{{
    amazon_ads.amazon_ads_union_connections(
        connection_dictionary='amazon_ads_sources',
        single_source_name='amazon_ads',
        single_table_name='advertised_product_report'
    )
}}

{% else %}

{{
    fivetran_utils.union_data(
        table_identifier='advertised_product_report',
        database_variable='amazon_ads_database',
        schema_variable='amazon_ads_schema',
        default_database=target.database,
        default_schema='amazon_ads',
        default_variable='advertised_product_report',
        union_schema_variable='amazon_ads_union_schemas',
        union_database_variable='amazon_ads_union_databases'
    )
}}

{% endif %}