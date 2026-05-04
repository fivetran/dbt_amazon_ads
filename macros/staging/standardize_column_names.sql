{% macro standardize_column_names(tmp_relation, table_name, base_columns, package_name='amazon_ads') %}
    {#-
    Standardizes column names from source tables with mixed naming conventions.

    This macro handles both column name standardization (coalescing custom names to
    standard names) and missing column filling (creating NULLs for expected columns
    that don't exist in the source).

    Args:
        tmp_relation: The source relation (typically from tmp staging model)
        table_name: The base table name for custom name lookups
        base_columns: List of expected column objects with 'name' and 'datatype'
        package_name: Package name for variable lookup (default: 'amazon_ads')

    Returns:
        SQL select statement with standardized column names.

    Example output:
        select
            coalesce("campaignBiddingStrategy", "campaign_bidding_strategy") as campaign_bidding_strategy,
            "ad_group_id" as ad_group_id,
            cast(null as integer) as missing_column
        from tmp_relation
    -#}
    {{ return(adapter.dispatch('standardize_column_names', 'amazon_ads')(tmp_relation, table_name, base_columns, package_name)) }}
{% endmacro %}

{% macro default__standardize_column_names(tmp_relation, table_name, base_columns, package_name) %}

{# Step 1: Inspect the source relation to see what columns actually exist #}
{%- set actual_columns = adapter.get_columns_in_relation(tmp_relation) %}
{%- set actual_column_names = actual_columns | map(attribute='name') | list %}

{# Step 2: Get custom name mappings for this table if custom names are enabled #}
{%- set custom_mappings = amazon_ads.resolve_column_names(table_name, base_columns, package_name) if var(package_name ~ '_using_custom_names', false) else {} %}

{# Step 3: Process each expected column to generate standardized select statements #}
{%- for column in base_columns %}
    {%- set standard_name = column.name %}
    {%- set column_datatype = column.datatype %}
    {%- set column_alias = column.alias if column.alias else standard_name %}

    {%- if standard_name in custom_mappings -%}
        {# Step 3a: Column has custom mappings - check which variants actually exist #}
        {%- set available_variants = [] -%}
        {%- for variant in custom_mappings[standard_name] if variant|lower in actual_column_names|map('lower') -%}
            {%- do available_variants.append(variant) -%}
        {%- endfor -%}

        {%- if available_variants|length > 1 -%}
            coalesce({{ available_variants | join(', ') }})
        {%- elif available_variants|length == 1 -%}
            {{ available_variants[0] }}
        {%- else -%}
            cast(null as {{ column_datatype }})
        {%- endif %}

    {%- else -%}
        {# Step 3b: Column has no custom mappings - check if standard name exists #}
        {%- if standard_name in actual_column_names -%}
            {{ standard_name }}
        {%- else -%}
            cast(null as {{ column_datatype }})
        {%- endif %}
    {% endif %}

    as {{ column_alias }}{{ ',' if not loop.last }}

{% endfor %}

{% endmacro %}