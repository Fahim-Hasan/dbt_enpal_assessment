with deal_change_activity as (
    select
        deal_id,
        changed_field_key,
        new_value,
        changed_at
    from {{ ref('stg_pipedrive__deal_changes') }}
    where changed_field_key in ('ADD_TIME', 'USER_ID')
),

transformed as (
    select
        deal_id,
        -- Calling get_activity_type_from_code to convert the raw field key into a
        -- human-legible activity_type value
        {{ get_activity_type_from_code('changed_field_key') }} as activity_type,
        -- new_value only holds a user id for USER_ID events -- for ADD_TIME it holds a
        -- timestamp, so user_id must be null there rather than a bad cast
        case
            when changed_field_key = 'USER_ID' then new_value::int
        end as user_id,
        changed_at as event_date
    from deal_change_activity
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
