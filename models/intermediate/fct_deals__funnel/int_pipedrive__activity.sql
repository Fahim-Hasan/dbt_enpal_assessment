with deal_stage_events as (
    select
        deal_id,
        activity_type_code,
        due_at
    from {{ ref('stg_pipedrive__activity') }}
    where
        activity_type_code in ('SC_2', 'MEETING')
        and is_done = true
),

transformed_funnel_step as (
    select
        deal_id,
        -- Calling the funnel_step_from_code macro here to convert the activity into a funnel_step value
        {{ get_funnel_step_from_code('activity_type_code::text') }} as funnel_step,
        due_at as event_date
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
