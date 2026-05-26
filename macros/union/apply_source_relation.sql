{% macro apply_source_relation() -%}

{{ adapter.dispatch('apply_source_relation', 'amazon_ads') () }}

{%- endmacro %}

{% macro default__apply_source_relation() -%}

{% if var('amazon_ads_sources', []) != [] %}
, _dbt_source_relation as source_relation
{% elif var('union_schemas', []) != [] or var('union_databases', []) != [] %}
{{ fivetran_utils.source_relation() }}
{% else %}
, '{{ var("amazon_ads_database", target.database) }}' || '.'|| '{{ var("amazon_ads_schema", "amazon_ads") }}' as source_relation
{% endif %}

{%- endmacro %}