with source as (
    select * from {{ source('pipedrive', 'activity') }}
),

transformed as (
    select
        activity_id,
        assigned_to_user as assigned_to_user_id,
        deal_id,
        done as is_done,
        due_to as due_at,
        upper(replace(type, ' ', '_')) as activity_type_code
    from source
),

final as (
    select
        activity_id,
        activity_type_code,
        assigned_to_user_id,
        deal_id,
        is_done,
        due_at
    from transformed
)

select * from final
