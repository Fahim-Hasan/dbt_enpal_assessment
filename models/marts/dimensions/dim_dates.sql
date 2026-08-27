with date_spine as (
    select * from {{ ref('int_pipedrive__date_spine') }}
),

renamed as (
    select
        date_day,
        extract(year from date_day)::int as calendar_year,
        extract(month from date_day)::int as month_number,
        date_trunc('month', date_day)::date as month_start_date,
        extract(day from date_day)::int as day_of_month,
        extract(isodow from date_day)::int as day_of_week,
        to_char(date_day, 'FMDay') as day_name
    from date_spine
)

select * from renamed
