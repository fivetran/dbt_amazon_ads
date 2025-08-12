{{ config(enabled=var('ad_reporting__amazon_ads_enabled', True)) }}

{{
    fivetran_utils.union_data(
        table_identifier='targeting_keyword_report', 
        database_variable='amazon_ads_database', 
        schema_variable='amazon_ads_schema', 
        default_database=target.database,
        default_schema='amazon_ads',
        default_variable='targeting_keyword_report',
        union_schema_variable='amazon_ads_union_schemas',
        union_database_variable='amazon_ads_union_databases'
    )
}}