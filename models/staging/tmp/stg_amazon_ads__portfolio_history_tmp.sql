{{ config(enabled=fivetran_utils.enabled_vars(['ad_reporting__amazon_ads_enabled','amazon_ads__portfolio_history_enabled'])) }}

{{
    fivetran_utils.union_data(
        table_identifier='portfolio_history', 
        database_variable='amazon_ads_database', 
        schema_variable='amazon_ads_schema', 
        default_database=target.database,
        default_schema='amazon_ads',
        default_variable='portfolio_history',
        union_schema_variable='amazon_ads_union_schemas',
        union_database_variable='amazon_ads_union_databases'
    )
}}