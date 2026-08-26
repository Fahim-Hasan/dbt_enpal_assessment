{% set unioned_event_dates %}
    select changed_at as event_date from {{ ref('stg_pipedrive__deal_changes') }}
    union all
    select due_at as event_date from {{ ref('stg_pipedrive__activity') }}
{% endset %}

{{ dbt_utils.date_spine(
    datepart="day",
    start_date="(select min(event_date)::date from (" ~ unioned_event_dates ~ ") as bounds)",
    end_date="(select max(event_date)::date + interval '1 day' from (" ~ unioned_event_dates ~ ") as bounds)"
) }}
