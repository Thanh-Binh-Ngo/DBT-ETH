{% macro devided_two(column_name)%}

{{ column_name }}/2

{% endmacro %}

{% macro devided(column_name, factor)%}

{{ column_name }}/{{factor}}

{% endmacro %}