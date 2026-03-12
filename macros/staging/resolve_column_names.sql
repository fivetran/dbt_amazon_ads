{% macro resolve_column_names(_fivetran_table_name, _fivetran_columns) %}
    {{ return(adapter.dispatch('resolve_column_names', 'amazon_ads')(_fivetran_table_name, _fivetran_columns)) }}
{% endmacro %}

{% macro default__resolve_column_names(_fivetran_table_name, _fivetran_columns) %}

{% set resolved_column_names = _fivetran_columns %}

{% if var('amazon_ads_using_custom_names', false) %}
    {% set resolved_column_names = [] %}
    {% set custom_column_names = var('amazon_ads_custom_column_names', {}) %}

    {% for column in _fivetran_columns %}
        {% set column_name = column.name %}
        {# Use the custom name if it exists, otherwise use the original column name #}
        {% set resolved_name = custom_column_names.get(_fivetran_table_name, {}).get(column_name, column_name) %}
        {% set updated_column = dict(column, name=resolved_name, alias=column_name) %}
        {% do resolved_column_names.append(updated_column) %}
    {% endfor %}
{% endif %}

{{ return(resolved_column_names) }}

{% endmacro %}