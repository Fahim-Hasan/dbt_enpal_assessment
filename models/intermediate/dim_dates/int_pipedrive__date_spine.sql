with unioned_event_dates as (
    select changed_at as event_date from {{ ref('stg_pipedrive__deal_changes') }}
    union all
    select due_at as event_date from {{ ref('stg_pipedrive__activity') }}
),

bounds as (
    select
        min(event_date)::date as min_date,
        max(event_date)::date as max_date
    from unioned_event_dates
),

date_spine as (
    -- Native Postgres generate_series, evaluated by the database at query time -- avoids
    -- dbt_utils.date_spine's dynamic-subquery-bounds pattern, which requires run_query() at
    -- compile time and returns None
    select generate_series(min_date, max_date, interval '1 day')::date as date_day
    from bounds
)

select date_day from date_spine
