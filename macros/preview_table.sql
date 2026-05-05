{% macro preview_table() %}

    {% set query %}
        SELECT *
        FROM meta_silver.eup_f40001de_f20_carrier
        LIMIT 10
    {% endset %}

    {% set results = run_query(query) %}

    {% if execute %}

        {{ log("Columns: " ~ results.column_names, info=True) }}

        {% for row in results.rows %}
            {{ log(row, info=True) }}
        {% endfor %}

    {% endif %}

{% endmacro %}