with months as (
    -- month is a required column name per the brief, not a mistaken keyword-as-identifier
    select distinct month_start_date as month  -- noqa: RF04
    from {{ ref('dim_dates') }}
),

funnel_steps as (
    select
        funnel_step,
        kpi_name
    from {{ ref('dim_deals__funnel_steps') }}
),

month_step_grid as (
    select
        m.month,
        f.funnel_step,
        f.kpi_name
    from months as m
    cross join funnel_steps as f
),

monthly_actuals as (
    select
        funnel_step,
        date_trunc('month', event_date)::date as month,  -- noqa: RF04
        count(distinct deal_id) as deals_count
    from {{ ref('fct_deals__funnel') }}
    group by 1, 2
),

final as (
    select
        g.month,
        g.kpi_name,
        g.funnel_step,
        coalesce(a.deals_count, 0) as deals_count
    from month_step_grid as g
    left join monthly_actuals as a
        on
            g.month = a.month
            and g.funnel_step = a.funnel_step
)

select * from final
