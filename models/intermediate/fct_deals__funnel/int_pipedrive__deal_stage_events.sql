with deal_stage_events as (
    select
        deal_id,
        new_value::int as stage_id,
        changed_at
    from {{ ref('stg_pipedrive__deal_changes') }}
    where changed_field_key = 'STAGE_ID'

),

transformed_funnel_step as (
    select
        deal_id,
        -- Calling the funnel_step_from_code macro here to convert the stage_id into a funnel_step value
        {{ get_funnel_step_from_code('stage_id::text') }} as funnel_step,
        changed_at as event_date
    from deal_stage_events
),

final as (
    select
        deal_id,
        funnel_step,
        event_date
    from transformed_funnel_step
)

select * from final
