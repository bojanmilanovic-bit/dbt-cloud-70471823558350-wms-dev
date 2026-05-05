{% macro show_tables() %}

    {% set query %}
        SHOW TABLES IN hive_metastore.meta_bronze
    {% endset %}

    {% set results = run_query(query) %}

    {% if execute %}
        {% for row in results.rows %}
            {{ log(row, info=True) }}
        {% endfor %}
    {% endif %}

{% endmacro %}