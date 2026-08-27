with deal_lost_events as (
    select
        deal_id,
        new_value::int as lost_reason_id,
        changed_at
    from {{ ref('stg_pipedrive__deal_changes') }}
    where changed_field_key = 'LOST_REASON'
),

ranked as (
    select
        deal_id,
        lost_reason_id,
        changed_at as lost_at,
        -- Most recent lost_reason event wins as the deal's current state. On today's data this
        -- only ever matters for the 5 known colliding deal_ids (excluded downstream in the fact,
        -- not here); kept generic so a genuine future double-loss case still resolves correctly.
        row_number() over (partition by deal_id order by changed_at desc) as recency_rank
    from deal_lost_events
),

final as (
    select
        deal_id,
        lost_reason_id,
        lost_at
    from ranked
    where recency_rank = 1
)

select * from final
