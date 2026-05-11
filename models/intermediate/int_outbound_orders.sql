{{ config(
    materialized='view',
    schema='dbt_karsic'
) }}

with orders as (

    select * from {{ ref('orders_stg') }}

),

final as (

    select
        -- keys
        outbound_order_id,

        -- foreign keys
       MD5(CONCAT('EUP_F70', '-', client_code, '-', firm_name))  as fk_warehouse_clients,

        CASE
            WHEN status_code_raw = '00' OR status_code_raw IS NULL          THEN 61
            WHEN CAST(status_code_raw AS INT) <= 10                         THEN 61
            WHEN CAST(status_code_raw AS INT) <= 19                         THEN 64
            WHEN CAST(status_code_raw AS INT) <= 40                         THEN 82
            WHEN CAST(status_code_raw AS INT) < 44                          THEN 83
            WHEN CAST(status_code_raw AS INT) = 44                          THEN 99
            WHEN CAST(status_code_raw AS INT) < 48                          THEN 92
            WHEN CAST(status_code_raw AS INT) = 48                          THEN 93
            WHEN CAST(status_code_raw AS INT) = 49                          THEN 96
        END                                         as fk_warehouse_process_status,

        -- order attributes
        client_code,
        firm_name,
        order_number,

        -- dates
        created_date,
        created_time,
        created_at

    from orders

)

select * from final