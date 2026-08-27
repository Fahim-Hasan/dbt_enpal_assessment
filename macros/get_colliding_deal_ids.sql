{% macro get_colliding_deal_ids(relation, timestamp_column='changed_at') %}
/*
    Dynamically detects deal_ids whose event history actually belongs to two unrelated deals
    collided onto the same id. Signal: every event for one real deal shares the exact same
    time-of-day (HH:MI:SS) component -- only the date varies (verified across every clean deal in
    this dataset). A deal_id with more than one distinct time-of-day signature has two deals'
    timelines interleaved on it. No hardcoded ids -- detects whatever the live data shows, so it
    stays correct if a future data refresh introduces new collisions or resolves old ones.
*/
    select deal_id
    from {{ relation }}
    group by deal_id
    having count(distinct to_char({{ timestamp_column }}, 'HH24:MI:SS')) > 1
{% endmacro %}
