{{ config(enabled=var('ad_reporting__amazon_ads_enabled', True)) }}

{{
    fivetran_utils.union_data(
        table_identifier='campaign_history',
        database_variable='amazon_ads_database',
        schema_variable='amazon_ads_schema',
        default_database=target.database,
        default_schema='amazon_ads',
        default_variable='campaign_history',
        union_schema_variable='amazon_ads_union_schemas',
        union_database_variable='amazon_ads_union_databases'
    ) if var('amazon_ads_union_schemas', None) or var('amazon_ads_union_databases', None)

    else fivetran_utils.union_connections(
        connection_dictionary='amazon_ads_sources',
        single_source_name='amazon_ads',
        single_table_name='campaign_history'
    )
}}