

-- This table needs to ingest all other tables, apply the relevant filters and THEN act as a filter for all other reports


select * from ArticleTest2

select * from vw_Warehouse


WITH Article_base AS (
        select
            CONVERT(NVARCHAR(40), CAST("Item Code" AS BIGINT))                  AS code,
            CONVERT(CHAR(8), "Launch date AU-US-NZ", 112)                       as L_AUUSNZ,
            CONVERT(CHAR(8), "Launch date EU", 112)                             as L_EU,
            CONVERT(CHAR(8), "Launch date UK", 112)                             as L_UK,
            ROW_NUMBER() OVER (PARTITION BY "Item Code" ORDER BY "Item Code")   AS rn
        FROM
            ArticleTest7
            WHERE "ACTIVE SKUS" = 'YES'
             ),
Article_Warehouse AS (
select 
    ab.*,
    w.warehouse 
FROM
    Article_base as ab
CROSS JOIN vw_Warehouse as w 
WHERE ab.rn = 1
),
Article_Warehouse_Date AS (
SELECT
    aw.code,
    aw.warehouse,
    CASE
        WHEN w.region IN ('Australia' , 'USA', 'NZ') then aw.L_AUUSNZ
        WHEN w.region = 'UK' then aw.L_UK
        WHEN w.region = 'Europe' then aw.L_EU 
    ELSE aw.L_AUUSNZ
    END AS launchdate
FROM 
    Article_Warehouse as aw
INNER JOIN vw_Warehouse w 
ON  w.warehouse = aw.warehouse

),
ArticleCodeMaster_final AS (    -- include this as final part of code
SELECT 
    awd.warehouse,
    awd.code
from Article_Warehouse_Date as awd 
INNER JOIN vw_Last_XMonths as d  
ON awd.launchdate = d.DateKey ),


