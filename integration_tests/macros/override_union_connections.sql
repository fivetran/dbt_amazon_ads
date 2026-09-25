-- TEMPORARY - local override of fivetran_utils.union_connections, scoped to this
-- repo's integration_tests project only (via dbt's default dispatch search order,
-- which checks the root project before the fivetran_utils package itself).
--
-- Testing a fix for a dbt v2 (Fusion) compile failure on Databricks:
-- "Unexpected Result: Unexpected result type ()" on the empty-relation stub query
-- (cast(null as ...) with limit 0). Extends the existing redshift-only `limit 1`
-- workaround to databricks too, since Fusion's Databricks adapter hits the same
-- class of type-inference issue on a zero-row typed-NULL result that redshift
-- has always needed a non-zero limit for.
--
-- Remove this file (and revert packages.yml if it was changed) once validated,
-- and land the real fix in fivetran/dbt_fivetran_utils directly.

{% macro default__union_connections(connection_dictionary, single_source_name, single_table_name, default_identifier=single_table_name) %}

{%- set exception_warning = "\n\nPlease be aware: The " ~ single_source_name|upper ~ "." ~ single_table_name|upper ~ " table was not found in your schema(s). The Fivetran Data Model will create a completely empty staging model as to not break downstream transformations. To turn off these warnings, set the `fivetran__remove_empty_table_warnings` variable to TRUE (see https://github.com/fivetran/dbt_fivetran_utils/tree/releases/v0.4.latest#union_connections-source for details).\n"%}
{%- set using_empty_table_warnings = (execute and not var('fivetran__remove_empty_table_warnings', false)) %}
{%- set connections = var(connection_dictionary, []) %}
{%- set using_unioning = connections | length > 0 %}
{%- set identifier_var = single_source_name + "_" + single_table_name + "_identifier" %}

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
            {%- set identifier = var(identifier_var, default_identifier) %}
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
        limit {{ '0' if target.type not in ('redshift', 'databricks') else '1' }}
    {%- endif -%}

{% else %}
{# Not unioning #}

    {%- set database = source(single_source_name, single_table_name).database %}
    {%- set schema = source(single_source_name, single_table_name).schema %}
    {%- set identifier = var(identifier_var, default_identifier) %}

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
        from {{ source(single_source_name, single_table_name) }} as source_table

    {% else %}
        {{ exceptions.warn(exception_warning) if using_empty_table_warnings }}

        select
            cast(null as {{ dbt.type_string() }}) as _dbt_source_relation
        limit {{ '0' if target.type not in ('redshift', 'databricks') else '1' }}
    {%- endif -%}
{% endif -%}

{%- endmacro %}
