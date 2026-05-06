{{ config(
    materialized='view',
    schema='meta_silver'
) }}

SELECT *
FROM meta_bronze.eup_f40013de_f70_phisttp
LIMIT 200