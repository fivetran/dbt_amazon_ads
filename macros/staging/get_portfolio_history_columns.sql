{% macro get_portfolio_history_columns() %}

{% set _fivetran_columns = [
    {"name": "budget_amount", "datatype": dbt.type_float()},
    {"name": "budget_currency_code", "datatype": dbt.type_string()},
    {"name": "budget_end_date", "datatype": "date"},
    {"name": "budget_policy", "datatype": dbt.type_string()},
    {"name": "budget_start_date", "datatype": "date"},
    {"name": "creation_date", "datatype": dbt.type_timestamp()},
    {"name": "id", "datatype": dbt.type_int()},
    {"name": "in_budget", "datatype": "boolean"},
    {"name": "last_updated_date", "datatype": dbt.type_timestamp()},
    {"name": "name", "datatype": dbt.type_string()},
    {"name": "profile_id", "datatype": dbt.type_int()},
    {"name": "serving_status", "datatype": dbt.type_string()},
    {"name": "state", "datatype": dbt.type_string()}
] %}

{% set columns = amazon_ads.resolve_column_names('portfolio_history', _fivetran_columns) %}

{{ return(columns) }}

{% endmacro %}
