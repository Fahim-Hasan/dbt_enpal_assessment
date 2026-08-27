with deals_funnel as (
    select * from {{ ref('int_deals_funnel_unioned') }}
),

invalid_steps as (
    -- Calling get_invalid_substep_events to identify sub-step events that couldn't have
    -- genuinely happened at the claimed funnel step
    {{ get_invalid_substep_events('deals_funnel') }}
),

valid_deals as (
    select df.*
    from deals_funnel as df
    left join invalid_steps as inv
        on
            df.deal_id = inv.deal_id
            and df.funnel_step = inv.funnel_step
            and df.event_date = inv.event_date
    where inv.deal_id is null
),

final as (
    select
        {{ dbt_utils.generate_surrogate_key(['deal_id', 'funnel_step', 'event_date']) }} as funnel_event_id,
        deal_id,
        funnel_step,
        event_date
    from valid_deals
)

select * from final
