with source as (
    select * from {{ source('pipedrive', 'activity_types') }}
),

renamed as (
    select
        id as activity_type_id,
        name as activity_type_name,
        type as activity_type_code,
        (active = 'Yes') as is_active
    from source
)

select * from renamed
