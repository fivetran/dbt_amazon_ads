{% macro get_product_ad_history_columns() %}

{% set columns = [
    {"name": "ad_group_id", "datatype": dbt.type_int()},
    {"name": "asin", "datatype": dbt.type_string()},
    {"name": "campaign_id", "datatype": dbt.type_int()},
    {"name": "creation_date", "datatype": dbt.type_timestamp()},
    {"name": "id", "datatype": dbt.type_string()},
    {"name": "last_updated_date", "datatype": dbt.type_timestamp()},
    {"name": "serving_status", "datatype": dbt.type_string()},
    {"name": "sku", "datatype": dbt.type_string()},
    {"name": "state", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
