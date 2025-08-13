{% macro get_keyword_history_columns() %}

{% set columns = [
    {"name": "ad_group_id", "datatype": dbt.type_int()},
    {"name": "bid", "datatype": dbt.type_float()},
    {"name": "campaign_id", "datatype": dbt.type_int()},
    {"name": "creation_date", "datatype": dbt.type_timestamp()},
    {"name": "id", "datatype": dbt.type_string()},
    {"name": "keyword_text", "datatype": dbt.type_string()},
    {"name": "last_updated_date", "datatype": dbt.type_timestamp()},
    {"name": "match_type", "datatype": dbt.type_string()},
    {"name": "native_language_keyword", "datatype": dbt.type_string()},
    {"name": "serving_status", "datatype": dbt.type_string()},
    {"name": "state", "datatype": dbt.type_string()},
    {"name": "native_language_locale", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
