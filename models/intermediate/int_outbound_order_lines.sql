{{ config(
    materialized='view',
    schema='dbt_karsic'
) }}

with order_lines as (

    select * from {{ ref('order_lines_stg') }}

),

final as (

    select
        -- keys
        sk,
        outbound_order_line_id,
        fk_outbound_orders,

        -- identifiers
        client_code,
        firm_code,
        order_number,
        order_line_number,
        item_id,
        item_group,
        item_type,

        -- aggregated quantities
        SUM(pieces_planned_raw)                                             as pieces_planned,
        SUM(pieces_planned_raw - pieces_transacted_raw)                     as pieces_difference,
        SUM(pieces_transacted_raw)                                          as pieces_picked,
        SUM(pieces_packed_raw)                                              as pieces_packed,
        SUM(pieces_loaded_raw)                                              as pieces_loaded,

        -- timestamps
        MIN(created_at)                                                     as creation_ts,
        MAX(modified_at)                                                    as modification_ts,

        -- flags
        0                                                                   as flag_order_line_open,
        SUM(
            CASE WHEN order_line_status_raw = 4
                 AND flag_fn113_raw = 0
                 THEN 1 ELSE 0 END
        )                                                                   as flag_order_line_canceled

    from order_lines
    where client_code = 'D01'
    group by all

)

select * from final