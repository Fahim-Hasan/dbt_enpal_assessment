with stage_events as (
    select
        deal_id,
        funnel_step,
        event_date
    from {{ ref('int_pipedrive__deal_stage_events') }}

),

activity_events as (
    select
        deal_id,
        funnel_step,
        event_date
    from {{ ref('int_pipedrive__activity') }}
),

unioned as (

    select * from stage_events
    union all
    select * from activity_events

),

final as (
    select
        deal_id,
        funnel_step,
        event_date
    from unioned
)

select * from final
