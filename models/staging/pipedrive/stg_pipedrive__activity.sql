with source as (
    select * from {{ source('pipedrive', 'activity') }}
),

renamed as (
    select
        activity_id,
        type as activity_type_code,
        assigned_to_user as assigned_to_user_id,
        deal_id,
        done as is_done,
        due_to as due_at
    from source
)

select * from renamed
