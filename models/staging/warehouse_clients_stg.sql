{{ config(
    materialized='view',
    schema='dbt_karsic'
) }}

with final as (

    select
        -- keys
        CONCAT('EUP_F70', '-', nvl(trim(upper(s.FSKONZ)), ''), '-', nvl(trim(upper(s.FSFIRM)), ''))         as BK,
        MD5(CONCAT('EUP_F70', '-', nvl(trim(upper(s.FSKONZ)), ''), '-', nvl(trim(upper(s.FSFIRM)), '')))    as sk,

        -- identifiers
        s.FSFIRM                                                                as warehouse_client_id,

        -- foreign keys
        -1                                                                      as fk_location_id,
        CAST(92302 AS INT)                                                      as fk_structural_branch_no,

        -- client info
        s.FSBEZ                                                                 as warehouse_client,
        CONCAT(
            nvl(trim(s.FSAN1), ''), ' ',
            nvl(trim(s.FSAN2), ''), ' ',
            nvl(trim(s.FSAN3), ''), ' ',
            nvl(trim(s.FSAN4), '')
        )                                                                       as warehouse_client_long_name,

        -- address
        nvl(s.FSSTR, '')                                                        as warehouse_address,
        nvl(trim(s.FSLORT), '')                                                 as warehouse_city,
        CAST(s.FSPLZ AS INT)                                                    as warehouse_zip_code,
        CAST(s.FSLAKZ AS STRING)                                                as warehouse_country,

        -- other
        CAST(s.FSWABZ AS STRING)                                                as industry_sector,
        CAST('' AS STRING)                                                      as copa_key,
        CAST(1 AS BOOLEAN)                                                      as active_flag
        
    from meta_bronze.eup_f40013de_f70_PFISTAM s

    where nvl(trim(upper(s.FSFIRM)), '') <> ''
      and nvl(trim(upper(s.FSFIRM)), '') <> '000'

)

select * from final