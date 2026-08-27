with deal_created as (
    select * from {{ ref('int_pipedrive__deal_created') }}
),

deal_lost_events as (
    select * from {{ ref('int_pipedrive__deal_lost_events') }}
),

valid_deals as (
    -- Excludes deal_ids whose history actually belongs to two unrelated deals collided onto one
    -- id -- a single-row-per-deal snapshot has no safe way to represent two blended truths.
    select *
    from deal_created
    where deal_id not in ({{ get_colliding_deal_ids(ref('stg_pipedrive__deal_changes')) }})
),

final as (
    select
        vd.deal_id,
        vd.created_at,
        dl.lost_reason_id,
        dl.lost_at,
        (dl.deal_id is not null) as is_lost
    from valid_deals as vd
    left join deal_lost_events as dl
        on vd.deal_id = dl.deal_id
)

select * from final
