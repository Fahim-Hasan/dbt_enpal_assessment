with source as (
    select * from {{ source('pipedrive', 'stages') }}
),

transformed as (
    select
        stage_id,
        upper(replace(stage_name, ' ', '_')) as stage_name
    from source
),

final as (
    select
        stage_id,
        stage_name
    from transformed
)

select * from final
