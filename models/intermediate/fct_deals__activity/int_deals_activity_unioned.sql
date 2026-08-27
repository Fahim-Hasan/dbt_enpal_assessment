with general_activity_events as (
    select
        deal_id,
        activity_type,
        user_id,
        event_date
    from {{ ref('int_pipedrive__general_activity') }}
),

deal_change_activity_events as (
    select
        deal_id,
        activity_type,
        user_id,
        event_date
    from {{ ref('int_pipedrive__deal_change_activity') }}
),

unioned as (

    select * from general_activity_events
    union all
    select * from deal_change_activity_events

),

final as (
    select
        deal_id,
        activity_type,
        user_id,
        event_date
    from unioned
)

select * from final
