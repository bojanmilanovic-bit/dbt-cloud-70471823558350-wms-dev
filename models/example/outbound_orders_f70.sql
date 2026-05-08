{{ config(
    materialized='view',
    schema='meta_silver'
) }}

with final as (

    select
        count(distinct CONCAT_WS('-',
            nvl(trim(upper(o.AKKONZ)), ''),
            nvl(trim(upper(o.AKFIRM)), ''),
            nvl(trim(upper(cast(o.AKAPN as int))), '')
        )) AS total_orders,

        akdtdf AS creation_date,

        CASE
            WHEN o.AKPSTS = '00' OR o.AKPSTS IS NULL           THEN 61
            WHEN cast(o.AKPSTS as int) >= 0  AND cast(o.AKPSTS as int) <= 10   THEN 61
            WHEN cast(o.AKPSTS as int) >= 11 AND cast(o.AKPSTS as int) < 20    THEN 64
            WHEN cast(o.AKPSTS as int) >= 20 AND cast(o.AKPSTS as int) <= 40   THEN 82
            WHEN cast(o.AKPSTS as int) > 40  AND cast(o.AKPSTS as int) < 44    THEN 83
            WHEN cast(o.AKPSTS as int) = 44                                     THEN 99
            WHEN cast(o.AKPSTS as int) > 44  AND cast(o.AKPSTS as int) < 48    THEN 92
            WHEN cast(o.AKPSTS as int) = 48                                     THEN 93
            WHEN cast(o.AKPSTS as int) = 49                                     THEN 96
        END AS fk_warehouse_processes_status
    from meta_bronze.eup_f40013de_f70_psaveak o
    group by akdtdf, fk_warehouse_processes_status

)

select * from final