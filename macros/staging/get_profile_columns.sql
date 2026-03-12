{% macro get_profile_columns() %}

{% set _fivetran_columns = [
    {"name": "id", "datatype": dbt.type_int()},
    {"name": "account_id", "datatype": dbt.type_string()},
    {"name": "account_marketplace_string_id", "datatype": dbt.type_string()},
    {"name": "account_name", "datatype": dbt.type_string()},
    {"name": "account_sub_type", "datatype": dbt.type_string()},
    {"name": "account_type", "datatype": dbt.type_string()},
    {"name": "account_valid_payment_method", "datatype": dbt.type_boolean()},
    {"name": "country_code", "datatype": dbt.type_string()},
    {"name": "currency_code", "datatype": dbt.type_string()},
    {"name": "daily_budget", "datatype": dbt.type_int()},
    {"name": "timezone", "datatype": dbt.type_string()},
    {"name": "_fivetran_deleted", "datatype": dbt.type_boolean()}
] %}

{% set columns = amazon_ads.resolve_column_names('profile', _fivetran_columns) %}

{{ return(columns) }}

{% endmacro %}