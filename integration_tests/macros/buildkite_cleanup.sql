{% macro buildkite_cleanup() %}
    {{ return(adapter.dispatch('buildkite_cleanup', 'amazon_ads_integration_tests')()) }}
{%- endmacro %}

{% macro default__buildkite_cleanup() %}

{% set build_schema = env_var('BUILD_SCHEMA', '') %}
{% set package_name = env_var('DBT_PACKAGE_NAME', 'amazon_ads') %}

{% if build_schema == '' %}
    {{ print('No BUILD_SCHEMA specified for cleanup, skipping.') }}
    {{ return('') }}
{% endif %}

{{ print('Cleaning up schemas for ' ~ target.type ~ ' target...') }}

{# Clean up both the source schema and the model output schema #}
{% set schemas_to_clean = [
    build_schema,
    package_name ~ '_dev_' ~ build_schema
] %}

{% for schema_name in schemas_to_clean %}
    {% do adapter.drop_schema(api.Relation.create(database=target.database, schema=schema_name)) %}
    {{ print('Schema ' ~ schema_name ~ ' dropped successfully.') }}
{% endfor %}

{{ print('Cleanup completed for ' ~ target.type ~ '.') }}

{% endmacro %}