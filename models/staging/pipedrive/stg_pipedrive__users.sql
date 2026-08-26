with source as (
    select * from {{ source('pipedrive', 'users') }}
),

transformed as (
    select
        id as user_id,
        email as user_email,
        modified as user_modified_at,
        upper(name) as user_name
    from source
),

final as (
    select
        user_id,
        user_name,
        user_email,
        user_modified_at
    from transformed
)

select * from final
