
-- Clear table before writing new data

TRUNCATE TABLE S4Import_VariantGeneric;

WITH 
    whs AS (
        select
            warehouse,
            region
        from 
            vw_Warehouse
    ),
    Article_base AS (
        select
            CONVERT(NVARCHAR(40), CAST("Item Code" AS BIGINT))                                                        as code,            
            "Parent SKU"                                                        as genericCode,
            "Description"                                                       as genericName,
            s.SizeOrder                                                         as variantNumber,
            LEFT( Size , 15 )                                                   as variantName,
            CASE   
            WHEN "Product Class" = 'Core' then 1
            ELSE 0
            END AS core
        FROM
            ArticleTest7                        --- REPLACE WITH SQL TABLE, this needs to be the final table
    LEFT JOIN ingest_SizeOrder as s  
    ON s.SizeCode = Size
    WHERE "ACTIVE SKUS" = 'YES' 
    AND LEN("Parent&child SKU" ) > 10
    AND "Parent&child SKU" IS NOT NULL
),
    variantPrep AS (
        SELECT
            CONCAT ( w.warehouse, '_' , ab.code ) as variantCode,
            genericCode,
            genericName,
            variantNumber,
            variantName,
            core,
            ROW_NUMBER() OVER (PARTITION BY CONCAT ( w.warehouse, '_' , ab.code ) ORDER BY CONCAT ( w.warehouse, '_' , ab.code )) AS rn
        FROM 
            Article_base as ab
        CROSS JOIN
            whs as w
        INNER JOIN S4Import_ArticleFilter as af 
            ON af.warehouse = w.warehouse
            AND af.code = ab.code
    )
INSERT INTO S4Import_VariantGeneric (controlID,  variantCode, genericCode, genericName, variantNumber, variantName, core )
        SELECT 
            '1' as controlID,
            variantCode,
            genericCode,
            genericName,
            variantNumber,
            variantName,
            core
            from
            variantPrep
                WHERE 1=1
                AND rn = 1
                AND variantCode IS NOT NULL ;

-- Setup queries 
/*
CREATE TABLE S4Import_VariantGeneric (
    controlID  INTEGER, 
    variantCode  NVARCHAR(40), 
    genericCode  NVARCHAR(40), 
    genericName  NVARCHAR(255), 
    variantNumber  INTEGER, 
    variantName  NVARCHAR(15), 
    core  INTEGER
) */

