-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements. See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership. The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License. You may obtain a copy of the License at
--
-- http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing,
-- software distributed under the License is distributed on an
-- "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
-- KIND, either express or implied. See the License for the
-- specific language governing permissions and limitations
-- under the License.

{% macro dbt_doris_validate_get_incremental_strategy(config) %}
  {#-- Find and validate the incremental strategy #}
  {%- set strategy = config.get("incremental_strategy", default="insert_overwrite") -%}

  {% set invalid_strategy_msg -%}
    Invalid incremental strategy provided: {{ strategy }}
    Expected one of: 'insert_overwrite', 'delete_insert'
  {%- endset %}
  {% if strategy not in ['delete_insert', 'insert_overwrite'] %}
    {% do exceptions.raise_compiler_error(invalid_strategy_msg) %}
  {% endif %}

  {% do return(strategy) %}
{% endmacro %}

{% macro default__get_delete_insert_merge_sql(target, source, unique_key, dest_columns) -%}

    {%- set dest_cols_csv = get_quoted_csv(dest_columns | map(attribute="name")) -%}
    {% set strategy = dbt_doris_validate_get_incremental_strategy(config) -%}


    {% if strategy == 'insert_overwrite' %}
        {#}
        {% set missing_unique_key_msg -%}
          The 'insert_overwrite' strategy requires the `unique_key` config.
        {%- endset %}
        {% if unique_key is none %}
          {% do exceptions.raise_compiler_error(missing_unique_key_msg) %}
        {% endif %}
        #}

        insert into {{ target }} ({{ dest_cols_csv }})
        (
            select {{ dest_cols_csv }}
            from {{ source }}
        )

  {% else %} {# strategy == 'delete_insert' #}
        {% do exceptions.raise_compiler_error('not support delete_insert strategy yet') %}
  {% endif %}

{%- endmacro %}
