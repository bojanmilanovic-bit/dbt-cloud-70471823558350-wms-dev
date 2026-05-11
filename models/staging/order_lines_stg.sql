{{ config(
    materialized='view',
    schema='dbt_karsic'
) }}

with final as (

    select
        -- keys
        xxhash64(CONCAT('EUP_F70', '-',
            nvl(trim(upper(ol.APKONZ)), ''), '-',
            nvl(trim(upper(ol.APFIRM)), ''), '-',
            nvl(trim(upper(cast(ol.APAPN as int))), ''), '-',
            nvl(trim(upper(cast(ol.APAPPO as int))), '')
        ))                                                          as sk,

        CONCAT_WS('-',
            nvl(trim(upper(ol.APKONZ)), ''),
            nvl(trim(upper(ol.APFIRM)), ''),
            nvl(trim(upper(ol.APAPN)), ''),
            nvl(trim(upper(cast(ol.APAPPO as int))), '')
        )                                                           as outbound_order_line_id,

        -- foreign key back to orders
        xxhash64(CONCAT('EUP_F70', '-',
            nvl(trim(upper(ol.APKONZ)), ''), '-',
            nvl(trim(upper(ol.APFIRM)), ''), '-',
            nvl(trim(upper(cast(ol.APAPN as int))), '')
        ))                                                          as fk_outbound_orders,

        -- identifiers
        ol.APKONZ                                                   as client_code,
        ol.APFIRM                                                   as firm_code,
        CAST(ol.APAPN AS INT)                                       as order_number,
        CAST(ol.APAPPO AS INT)                                      as order_line_number,
        ol.APIDEN                                                   as item_id,
        TRIM(ol.APBTPG)                                             as item_group,
        TRIM(ol.APBTPT)                                             as item_type,

        -- quantities (raw, no SUM yet)
        ol.APBSTM                                                   as pieces_planned_raw,
        ol.APANFM                                                   as pieces_transacted_raw,
        ol.APPM1                                                    as pieces_packed_raw,
        ol.APPM2                                                    as pieces_loaded_raw,

        -- status flags (raw)
        ol.APIAKZ                                                   as order_line_status_raw,
        ol.APFN113                                                  as flag_fn113_raw,

        -- timestamps
        TO_TIMESTAMP(
            LEFT(CAST(ol.APDTDI * 1000000000000 + ol.APTIDI AS STRING), 14),
            'yyyyMMddHHmmss'
        )                                                           as created_at,

        TO_TIMESTAMP(
            LEFT(CAST(ol.APDTDU * 1000000000000 + ol.APTIDU AS STRING), 14),
            'yyyyMMddHHmmss'
        )                                                           as modified_at
        
    from meta_bronze.eup_f40013de_f70_PSAVEAP ol

)

select * from final