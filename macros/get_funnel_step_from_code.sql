{% macro get_funnel_step_from_code(code_column) %}
/*
    This macro takes a stage_id column or activity_type_code as input and returns the corresponding funnel step value based on the provided mapping.
    The mapping is defined using a case statement, where each code is associated with a specific funnel step value.
    This helps us to define every funnel step in the process of a deal, from initial contact to final closure.
    Changing here will affect the funnel step values in the final output of the models that use this macro.
*/
    case {{ code_column }}
        when '1' then '1'
        when '2' then '2'
        when '3' then '3'
        when '4' then '4'
        when '5' then '5'
        when '6' then '6'
        when '7' then '7'
        when '8' then '8'
        when '9' then '9'
        when 'MEETING' then '2.1'
        when 'SC_2' then '3.1'
    end
{% endmacro %}
