{{ config(
    materialized='view',
    schema='dbt_karsic'
) }}

with final as (

    select
        -- keys
        CONCAT_WS('-',
            nvl(trim(upper(AKKONZ)), ''),
            nvl(trim(upper(AKFIRM)), ''),
            nvl(trim(upper(cast(AKAPN as int))), '')
        )                           as outbound_order_id,

        -- identifiers
        trim(upper(AKKONZ))         as client_code,
        trim(upper(AKFIRM))         as firm_name,
        cast(AKAPN as int)          as order_number,

        -- status (raw — mapping happens in intermediate)
        AKPSTS                      as status_code_raw,

        -- dates
        CASE
            WHEN CAST(AKDTDF AS DECIMAL(20,0)) = 0 OR AKDTDF IS NULL THEN NULL
            ELSE TO_DATE(CAST(CAST(AKDTDF AS DECIMAL(20,0)) AS STRING), 'yyyyMMdd')
        END                         AS created_date,

        -- time
        CASE
            WHEN CAST(AKTIDF AS DECIMAL(20,0)) = 0 OR AKTIDF IS NULL THEN NULL
            ELSE DATE_FORMAT(
                TO_TIMESTAMP(LPAD(CAST(CAST(AKTIDF AS DECIMAL(20,0)) AS STRING), 6, '0'), 'HHmmss'),
                'HH:mm:ss'
            )
        END                         AS created_time,

        -- timestamp
        CASE
            WHEN CAST(AKDTDF AS DECIMAL(20,0)) = 0 OR AKDTDF IS NULL THEN NULL
            WHEN CAST(AKTIDF AS DECIMAL(20,0)) = 0 OR AKTIDF IS NULL THEN NULL
            ELSE TO_TIMESTAMP(
                CONCAT(
                    CAST(CAST(AKDTDF AS DECIMAL(20,0)) AS STRING),
                    LPAD(CAST(CAST(AKTIDF AS DECIMAL(20,0)) AS STRING), 6, '0')
                ), 'yyyyMMddHHmmss'
            )
        END                         AS created_at

    from meta_bronze.eup_f40013de_f70_psaveak o

)

select * from final