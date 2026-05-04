{% macro resolve_column_names(_fivetran_table_name, columns, package_name='amazon_ads') %}
    {#-
    Resolves custom column name mappings for a given table across all configured schemas.

    This macro creates a complete mapping of standard column names to their possible variants
    (both custom names and standard names) for use in column standardization.

    Args:
        _fivetran_table_name: The base table name (e.g., 'ad_group_level_report')
        columns: List of column objects with 'name' and 'datatype' attributes
        package_name: Package name for variable lookup (default: 'amazon_ads')

    Returns:
        Dict mapping standard names to lists of possible column names.

    Example output for campaign_bidding_strategy with custom mapping:
        {
            "campaign_bidding_strategy": ["campaignBiddingStrategy", "campaign_bidding_strategy"],
            "ad_group_id": ["ad_group_id"],
            "clicks": ["clicks"]
        }
    -#}
    {{ return(adapter.dispatch('resolve_column_names', 'amazon_ads')(_fivetran_table_name, columns, package_name)) }}
{% endmacro %}

{% macro default__resolve_column_names(_fivetran_table_name, columns, package_name) %}

{% if var(package_name ~ '_using_custom_names', false) %}
    {# Step 1: Get the custom column name configuration from variables #}
    {% set custom_column_names = var(package_name ~ '_custom_column_names', {}) %}
    {% set column_name_mappings = {} %}

    {# Step 2: Process each expected column to build complete name mappings #}
    {% for column in columns %}
        {% set standard_name = column.name %}
        {% set custom_names = [] %}

        {# Step 3: Look through all schemas for custom names for this standard field #}
        {% for schema_name, custom_cols_for_schema in custom_column_names.items() %}
            {% set custom_name = custom_cols_for_schema.get(_fivetran_table_name, {}).get(standard_name, false) %}
            {% do custom_names.append(custom_name) if custom_name and custom_name not in custom_names %}
        {% endfor %}

        {# Step 4: Create complete name list (custom names first, then standard as fallback) #}
        {% set all_names = custom_names + [standard_name] if custom_names else [standard_name] %}
        {% do column_name_mappings.update({standard_name: all_names}) %}
    {% endfor %}

    {{ return(column_name_mappings) }}
{% else %}
    {# Custom names not enabled - return empty dict #}
    {{ return({}) }}
{% endif %}

{% endmacro %}