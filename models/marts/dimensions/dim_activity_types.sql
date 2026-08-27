with general_activity_types as (
    select
        {{ get_activity_type_from_code('activity_type_code') }} as activity_type
    from {{ ref('stg_pipedrive__activity_types') }}
    where activity_type_code in ('FOLLOW_UP', 'AFTER_CLOSE_CALL')
),

deal_change_activity_types as (
    select {{ get_activity_type_from_code("'ADD_TIME'") }} as activity_type
    union all
    select {{ get_activity_type_from_code("'USER_ID'") }} as activity_type
),

unioned as (

    select * from general_activity_types
    union all
    select * from deal_change_activity_types

),

final as (
    select activity_type
    from unioned
)

select * from final
