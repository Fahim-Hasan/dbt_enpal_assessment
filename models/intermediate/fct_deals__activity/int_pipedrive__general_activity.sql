with general_activity as (
    select
        deal_id,
        activity_type_code,
        assigned_to_user_id,
        due_at
    from {{ ref('stg_pipedrive__activity') }}
    where activity_type_code in ('FOLLOW_UP', 'AFTER_CLOSE_CALL')
),

transformed as (
    select
        deal_id,
        -- Calling get_activity_type_from_code to convert the raw activity type into a
        -- human-legible activity_type value
        {{ get_activity_type_from_code('activity_type_code') }} as activity_type,
        assigned_to_user_id as user_id,
        due_at as event_date
    from general_activity
),

final as (
    select
        deal_id,
        activity_type,
        user_id,
        event_date
    from transformed
)

select * from final
