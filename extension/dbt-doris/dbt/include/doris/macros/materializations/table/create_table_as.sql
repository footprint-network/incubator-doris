{% macro doris__create_table_as(temporary, relation, sql) -%}
  {% set sql_header = config.get('sql_header', none) %}

  {{ sql_header if sql_header is not none }}
  create table {{ relation.include(database=False) }}
    {{ doris__partition_by() }}
    {{ doris__distributed_by() }}
    {{ doris__aggregate_key() }}
    {{ doris__properties() }} as {{ sql }};

 {{ doris__partition_values(relation) }}

  insert into {{ relation.include(database=False) }}
  {{ sql }}
{%- endmacro %}
