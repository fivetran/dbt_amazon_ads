{{ config(enabled=fivetran_utils.enabled_vars(['ad_reporting__amazon_ads_enabled','amazon_ads__portfolio_history_enabled'])) }}

{% if var('amazon_ads_union_schemas', []) | length > 0 or var('amazon_ads_union_databases', []) | length > 0 %}

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

{% else %}

{{
    fivetran_utils.union_connections(
        connection_dictionary='amazon_ads_sources',
        single_source_name='amazon_ads',
        single_table_name='portfolio_history'
    )
}}

{% endif %}