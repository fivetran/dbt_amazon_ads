{#-
    POC-only local override of fivetran_utils.default__union_connections.

    Because this project (integration_tests) is the root project, dbt's default
    dispatch search order checks here for `default__union_connections` before
    falling back to the fivetran_utils package - no `dispatch:` config needed.

    This file is otherwise an unmodified copy of fivetran_utils' installed
    default__union_connections (v0.4.13). Since the macro doesn't exist on
    main, a PR diff will show this whole file as added - look for the three
    "POC CHANGE" comments below for what's actually different: identifier
    resolution consults `amazon_ads_custom_names.<schema>.<table>.__identifier__`
    first, falling back to the existing flat `<source>_<table>_identifier`
    var so this is backwards compatible with packages that don't set the new var.
-#}

{% macro default__union_connections(connection_dictionary, single_source_name, single_table_name, default_identifier=single_table_name) %}

{%- set exception_warning = "\n\nPlease be aware: The " ~ single_source_name|upper ~ "." ~ single_table_name|upper ~ " table was not found in your schema(s). The Fivetran Data Model will create a completely empty staging model as to not break downstream transformations. To turn off these warnings, set the `fivetran__remove_empty_table_warnings` variable to TRUE (see https://github.com/fivetran/dbt_fivetran_utils/tree/releases/v0.4.latest#union_data-source for details).\n"%}
{%- set using_empty_table_warnings = (execute and not var('fivetran__remove_empty_table_warnings', false)) %}
{%- set connections = var(connection_dictionary, []) %}
{%- set using_unioning = connections | length > 0 %}
{%- set identifier_var = single_source_name + "_" + single_table_name + "_identifier" %}
{# POC CHANGE (1 of 3): new lookup, not present in upstream fivetran_utils.default__union_connections #}
{%- set custom_names = var(single_source_name ~ '_custom_names', {}) %}

{%- if using_unioning %}
{# For unioning #}
    {%- set relations = [] -%}
    {%- for connection in connections -%}

        {% if var('has_defined_sources', false) %}
            {%- set database = source(connection.name, single_table_name).database %}
            {%- set schema = source(connection.name, single_table_name).schema %}
            {%- set identifier = source(connection.name, single_table_name).identifier %}
        {%- else %}
            {%- set database = connection.database if connection.database else target.database %}
            {%- set schema = connection.schema if connection.schema else single_source_name %}
            {# POC CHANGE (2 of 3): upstream has `identifier = var(identifier_var, default_identifier)` here - #}
            {# this checks the custom_names dict first, falling back to that same flat var #}
            {%- set identifier = custom_names.get(schema, {}).get(single_table_name, {}).get('__identifier__', var(identifier_var, default_identifier)) %}
        {%- endif %}

        {%- set relation=adapter.get_relation(
            database=database,
            schema=schema,
            identifier=identifier
            )
        -%}

        {%- if relation is not none -%}
            {%- do relations.append(relation) -%}
        {%- endif -%}

        -- ** Values passed to adapter.get_relation:
        {{ '-- database: ' ~ database }}
        {{ '-- schema: ' ~ schema }}
        {{ '-- identifier: ' ~ identifier ~ '\n' }}

    {%- endfor -%}

    {%- if relations | length > 0 -%}
        {{ fivetran_utils.union_relations_custom(relations, source_column_name='_dbt_source_relation') }}

    {%- else -%}
        {{ exceptions.warn(exception_warning) if using_empty_table_warnings }}

        select
            cast(null as {{ dbt.type_string() }}) as _dbt_source_relation
        limit {{ '0' if target.type != 'redshift' else '1' }}
    {%- endif -%}

{% else %}
{# Not unioning #}

    {%- set database = source(single_source_name, single_table_name).database %}
    {%- set schema = source(single_source_name, single_table_name).schema %}
    {# POC CHANGE (3 of 3): same swap as above, applied to the non-union branch - upstream has #}
    {# `identifier = var(identifier_var, default_identifier)` here #}
    {%- set identifier = custom_names.get(schema, {}).get(single_table_name, {}).get('__identifier__', var(identifier_var, default_identifier)) %}

    {%- set relation=adapter.get_relation(
        database=database,
        schema=schema,
        identifier=identifier
        )
    -%}

    -- ** Values passed to adapter.get_relation:
    {{ '-- full-identifier_var: ' ~ identifier_var }}
    {{ '-- database: ' ~ database }}
    {{ '-- schema: ' ~ schema }}
    {{ '-- identifier: ' ~ identifier ~ '\n' }}

    {% if relation is not none -%}
        select
            {{ dbt_utils.star(from=source(single_source_name, single_table_name)) }}
            , '{{ database ~ "." ~ schema }}' as _dbt_source_relation
        from {{ source(single_source_name, single_table_name) }} as source_table

    {% else %}
        {{ exceptions.warn(exception_warning) if using_empty_table_warnings }}

        select
            cast(null as {{ dbt.type_string() }}) as _dbt_source_relation
        limit {{ '0' if target.type != 'redshift' else '1' }}
    {%- endif -%}
{% endif -%}

{%- endmacro %}
