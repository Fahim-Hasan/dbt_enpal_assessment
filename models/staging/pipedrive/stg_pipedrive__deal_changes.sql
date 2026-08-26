with source as (
    select * from {{ source('pipedrive', 'deal_changes') }}
),

transformed as (
    select
        deal_id,
        change_time as changed_at,
        new_value,
        upper(replace(changed_field_key, ' ', '_')) as changed_field_key
    from source
),

final as (
    select
        deal_id,
        changed_at,
        changed_field_key,
        new_value
    from transformed
)

select * from final
