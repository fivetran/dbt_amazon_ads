{% macro get_campaign_history_columns() %}

{% set columns = [
    {"name": "bidding_strategy", "datatype": dbt.type_string()},
    {"name": "creation_date", "datatype": dbt.type_timestamp()},
    {"name": "end_date", "datatype": "date"},
    {"name": "id", "datatype": dbt.type_string()},
    {"name": "last_updated_date", "datatype": dbt.type_timestamp()},
    {"name": "name", "datatype": dbt.type_string()},
    {"name": "portfolio_id", "datatype": dbt.type_int()},
    {"name": "profile_id", "datatype": dbt.type_int()},
    {"name": "serving_status", "datatype": dbt.type_string()},
    {"name": "start_date", "datatype": "date"},
    {"name": "state", "datatype": dbt.type_string()},
    {"name": "targeting_type", "datatype": dbt.type_string()},
    {"name": "budget", "datatype": dbt.type_float()},
    {"name": "budget_type", "datatype": dbt.type_string()},
    {"name": "effective_budget", "datatype": dbt.type_float()}
] %}

{{ return(columns) }}

{% endmacro %}
