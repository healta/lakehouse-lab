{# Unity Catalog cannot replace a view yet (github.com/unitycatalog/unitycatalog/pull/1982),
   so drop it and create it again. Views and snapshots need this. #}
{% macro spark__create_view_as(relation, sql) %}
  {%- do run_query('drop view if exists ' ~ relation) -%}
  {{ dbt.spark__create_view_as(relation, sql).replace('create or replace view', 'create view', 1) }}
{% endmacro %}
