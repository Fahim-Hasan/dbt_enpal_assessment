with source as (
    select * from {{ source('pipedrive', 'fields') }}
),

lost_reason_field as (
    -- field_value_options is a JSON array shared across multiple field definitions;
    -- lost_reason is the only one this project needs unpacked into a proper lookup
    -- (stage_id's options are already covered by stg_pipedrive__stages).
    select field_value_options
    from source
    where field_key = 'lost_reason'
),

unnested as (
    select lost_reason_option
    from lost_reason_field,
        jsonb_array_elements(lost_reason_field.field_value_options) as lost_reason_option
),

transformed as (
    select
        (lost_reason_option ->> 'id')::int as lost_reason_id,
        upper(replace(lost_reason_option ->> 'label', ' ', '_')) as lost_reason_name
    from unnested
),

final as (
    select
        lost_reason_id,
        lost_reason_name
    from transformed
)

select * from final
