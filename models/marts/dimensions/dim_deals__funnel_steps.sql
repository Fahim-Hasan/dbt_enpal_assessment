with stages as (
    select
        {{ get_funnel_step_from_code('stage_id::text') }} as funnel_step,
        stage_name as kpi_name
    from {{ ref('stg_pipedrive__stages') }}
),

activity_substeps as (
    select
        {{ get_funnel_step_from_code('activity_type_code') }} as funnel_step,
        activity_type_name as kpi_name
    from {{ ref('stg_pipedrive__activity_types') }}
    where activity_type_code in ('MEETING', 'SC_2')
),

unioned as (
    select * from stages
    union all
    select * from activity_substeps
),

final as (
    select
        funnel_step,
        kpi_name
    from unioned
)

select * from final
