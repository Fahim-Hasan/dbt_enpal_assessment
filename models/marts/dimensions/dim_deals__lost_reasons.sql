with lost_reasons as (
    select * from {{ ref('stg_pipedrive__lost_reasons') }}
),

renamed as (
    select
        lost_reason_id,
        lost_reason_name
    from lost_reasons
)

select * from renamed
