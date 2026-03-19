{% macro get_ad_group_history_columns() %}

{% set columns = [
    {"name": "campaign_id", "datatype": dbt.type_int()},
    {"name": "creation_date", "datatype": dbt.type_timestamp()},
    {"name": "default_bid", "datatype": dbt.type_float()},
    {"name": "id", "datatype": dbt.type_string()},
    {"name": "last_updated_date", "datatype": dbt.type_timestamp()},
    {"name": "name", "datatype": dbt.type_string()},
    {"name": "serving_status", "datatype": dbt.type_string()},
    {"name": "state", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
