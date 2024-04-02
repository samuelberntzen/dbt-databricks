{% macro fetch_tags(relation) -%}
  {% if relation.is_hive_metastore() %}
    {{ exceptions.raise_compiler_error("Tags are only supported for Unity Catalog") }}
  {%- endif %}
  {% call statement('list_tags', fetch_result=True) -%}
    {{ fetch_tags_sql(relation) }}
  {% endcall %}
  {% do return(load_result('list_tags').table) %}
{%- endmacro -%}

{% macro fetch_tags_sql(relation) -%}
  SELECT tag_name, tag_value
  FROM `{{ relation.database }}`.`information_schema`.`table_tags`
  WHERE schema_name = '{{ relation.schema }}' AND table_name = '{{ relation.identifier }}'
{%- endmacro -%}

{% macro apply_tags(relation, set_tags, unset_tags=[]) -%}
  {%- if (set_tags is not none or unset_tags is not none) and relation.is_hive_metastore() -%}
    {{ exceptions.raise_compiler_error("Tags are only supported for Unity Catalog") }}
  {%- endif -%}
  {%- if set_tags %}
    {%- call statement('set_tags') -%}
       {{ alter_set_tags(relation, set_tags) }}
    {%- endcall -%}
  {%- endif %}
  {%- if unset_tags %}
    {%- call statement('unset_tags') -%}
       {{ alter_unset_tags(relation, unset_tags) }}
    {%- endcall -%}
  {%- endif %}
{%- endmacro -%}

{% macro alter_set_tags(relation, tags) -%}
  ALTER {{ relation.type }} {{ relation }} SET TAGS (
    {% for tag in tags -%}
      '{{ tag }}' = '{{ tags[tag] }}' {%- if not loop.last %}, {% endif -%}
    {%- endfor %}
  )
{%- endmacro -%}

{% macro alter_unset_tags(relation, tags) -%}
  ALTER {{ relation.type }} {{ relation }} UNSET TAGS (
    {% for tag in tags -%}
      '{{ tag }}' {%- if not loop.last %}, {%- endif %}
    {%- endfor %}
  )
{%- endmacro -%}
