{% macro test_always_fails(model, column_name) %}

-- Gibt immer eine Zeile zurück → Test schlägt immer fehl.
-- Nur für Simulationszwecke, um das CI-Verhalten bei fehlschlagenden Tests zu demonstrieren.
select 1 as failing_row

{% endmacro %}
