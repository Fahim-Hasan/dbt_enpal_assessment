{% macro get_invalid_substep_events(funnel_events_relation) %}
  /*
      Sub-step (2.1/3.1) events whose event_date does NOT fall inside any real interval during which
      the deal was actually sitting in that sub-step's parent stage. Stage/sub-step rows are told
      apart by whether funnel_step contains a '.' -- stages are '1'..'9', sub-steps are 'X.Y'.
      Built from actual per-deal timestamps, not a fixed step-order assumption -- stays correct even
      if a deal's real stage history regresses.
  */
  with stage_periods as (
      select
          deal_id,
          funnel_step::int as stage_id,
          event_date as stage_start,
          lead(event_date) over (partition by deal_id order by event_date) as stage_end
      from {{ funnel_events_relation }}
      where position('.' in funnel_step) = 0
  ),

  substep_candidates as (
      select
          deal_id,
          funnel_step,
          event_date,
          floor(funnel_step::numeric)::int as parent_stage_id
      from {{ funnel_events_relation }}
      where position('.' in funnel_step) > 0
  ),

  matched as (
      select c.deal_id, c.funnel_step, c.event_date
      from substep_candidates c
      join stage_periods sp
          on c.deal_id = sp.deal_id
          and c.parent_stage_id = sp.stage_id
          and c.event_date >= sp.stage_start
          and (sp.stage_end is null or c.event_date < sp.stage_end)
  )

  select c.deal_id, c.funnel_step, c.event_date
  from substep_candidates c
  left join matched m
      on c.deal_id = m.deal_id and c.funnel_step = m.funnel_step and c.event_date = m.event_date
  where m.deal_id is null

  {% endmacro %}

{% test no_invalid_substep_events(model) %}

    select * from ({{ get_invalid_substep_events(model) }}) as invalid

{% endtest %}
