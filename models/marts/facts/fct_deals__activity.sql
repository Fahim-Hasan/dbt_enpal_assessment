with deals_activity as (
    select * from {{ ref('int_deals_activity_unioned') }}
),

final as (
    select
        {{ dbt_utils.generate_surrogate_key(['deal_id', 'activity_type', 'event_date']) }} as activity_event_id,
        deal_id,
        activity_type,
        user_id,
        event_date
    from deals_activity
)

select * from final
