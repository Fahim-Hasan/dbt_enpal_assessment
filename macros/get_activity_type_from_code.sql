{% macro get_activity_type_from_code(code_column) %}
/*
    Single centralized mapping from a raw source code (activity.activity_type_code or
    deal_changes.changed_field_key) to a human-legible activity_type for fct_deals__activity and
    dim_activity_types. Mirrors get_funnel_step_from_code.sql's pattern -- one definition, reused,
    not redefined per consumer.
*/
    case {{ code_column }}
        when 'FOLLOW_UP' then 'FOLLOW_UP_CALL'
        when 'AFTER_CLOSE_CALL' then 'AFTER_CLOSE_CALL'
        when 'ADD_TIME' then 'DEAL_CREATED'
        when 'USER_ID' then 'OWNER_CHANGED'
    end
{% endmacro %}
