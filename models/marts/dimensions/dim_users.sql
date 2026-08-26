with users as (
    select * from {{ ref('stg_pipedrive__users') }}
),

renamed as (
    select
        user_id,
        user_name,
        user_email,
        user_modified_at
    from users
)

select * from renamed
