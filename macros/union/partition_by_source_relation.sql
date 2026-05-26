{%- macro partition_by_source_relation(has_other_partitions='yes', alias=None) -%}

{{ adapter.dispatch('partition_by_source_relation', 'amazon_ads') (has_other_partitions, alias) }}

{%- endmacro %}

{% macro default__partition_by_source_relation(has_other_partitions='yes', alias=None) -%}
    {% set prefix = '' if alias is none else alias ~ '.' %}

    {# Prioritizes amazon_ads_sources -> union_schemas -> union_databases -> [] #}
    {% set union_variable = var('amazon_ads_sources', var('amazon_ads_union_schemas', var('amazon_ads_union_databases', []))) %}

    {%- if has_other_partitions == 'no' -%}
        {{ 'partition by ' ~ prefix ~ 'source_relation' if union_variable|length > 1 }}
    {%- else -%}
        {{ ', ' ~ prefix ~ 'source_relation' if union_variable|length > 1 }}
    {%- endif -%}
{%- endmacro -%}
