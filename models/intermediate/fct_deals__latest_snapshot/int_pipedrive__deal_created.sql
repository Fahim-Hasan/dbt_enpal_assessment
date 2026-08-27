with deal_created as (
    select
        deal_id,
        changed_at
    from {{ ref('stg_pipedrive__deal_changes') }}
    where changed_field_key = 'ADD_TIME'
),

final as (
    select
        deal_id,
        changed_at as created_at
    from deal_created
)

select * from final
