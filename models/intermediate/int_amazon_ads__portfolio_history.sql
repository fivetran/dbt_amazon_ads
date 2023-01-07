{{ config(enabled=var('ad_reporting__amazon_ads_enabled', True)) }}

{# This intermediate model creates a dummy portfolio table if the user does not use portfolios. 
If they are using them, the normal portfolio_history will be used. #}

with portfolios as (
    select
    {% if var('amazon_ads__portfolio_history_enabled', True) %}
        *
        from {{ var('portfolio_history') }}
        where is_most_recent_record = True
    {% else %}
        {# uses the columns macro from the source package to populate column names #}
        {%- set columns = amazon_ads_source.get_portfolio_history_columns() -%}
        {% for column in columns %}
            {# set null for each column #}
            {%- if column['name'] == 'id' -%}
                cast(null as {{ dbt_utils.type_bigint() }}) as portfolio_id
            {%- elif column['name'] == 'name' -%}
                null as portfolio_name
            {%- else -%}
                null as {{column['name']}}
            {%- endif -%}
            {# add comma if not the last column #}
            {%- if column != columns|last -%}
                , 
            {%- endif -%}
        {% endfor %}
    {% endif %}
)

select * 
from portfolios