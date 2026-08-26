with source as (
    select * from {{ source('pipedrive', 'activity_types') }}
),

transformed as (
    select
        id as activity_type_id,
        upper(replace(name, ' ', '_')) as activity_type_name,
        upper(replace(type, ' ', '_')) as activity_type_code,
        (upper(active) = 'YES') as is_active
    from source
),

final as (
    select
        activity_type_id,
        activity_type_name,
        activity_type_code,
        is_active
    from transformed
)

select * from final
