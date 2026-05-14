{% macro drop_ci_schema() %}
  {% set schema_name = env_var('DBT_SCHEMA', '') %}
  {% if schema_name.startswith('pr_') %}
    {% set drop_sql %}
      DROP SCHEMA IF EXISTS {{ target.database }}.{{ schema_name }} CASCADE
    {% endset %}
    {% do run_query(drop_sql) %}
    {{ log("CI-Schema '" ~ schema_name ~ "' wurde gelöscht.", info=True) }}
  {% else %}
    {{ exceptions.raise_compiler_error("drop_ci_schema: DBT_SCHEMA '" ~ schema_name ~ "' ist kein PR-Schema — Abbruch.") }}
  {% endif %}
{% endmacro %}
