{% macro databricks__get_rename_table_sql(relation, new_name) %}
  ALTER TABLE {{ relation }} RENAME TO `{{ new_name }}`
{% endmacro %}