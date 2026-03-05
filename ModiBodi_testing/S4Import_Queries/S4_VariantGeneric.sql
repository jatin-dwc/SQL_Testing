
-- Clear table before writing new data

TRUNCATE TABLE S4Import_VariantGeneric;

WITH Article_base AS (
        select
            "Child SKU"                                                         as variantCode,
            "Parent SKU"                                                        as genericCode,
            "Description"                                                       as genericName,
            s.SizeOrder                                                         as variantNumber,
            "Combo"                                                             as variantName,
            '1'                                                                 as core,
            ROW_NUMBER() OVER (PARTITION BY "Child SKU" ORDER BY "Child SKU")   AS rn
        FROM
            ArticleTest7                        --- REPLACE WITH SQL TABLE
    LEFT JOIN ingest_SizeOrder as s  
    ON s.SizeCode = Size
    WHERE "ACTIVE SKUS" = 'YES'
)
INSERT INTO S4Import_VariantGeneric (controlID,  variantCode, genericCode, genericName, variantNumber, variantName, code )
SELECT 
    '1' as controlID,
    variantCode,
    genericCode,
    genericName,
    variantNumber,
    variantName,
    core
    from
    Article_base
        WHERE rn = 1
        AND variantCode IS NOT NULL ;

-- Setup queries 

CREATE TABLE S4Import_VariantGeneric (
    controlID  INTEGER, 
    variantCode  NVARCHAR(40), 
    genericCode  NVARCHAR(40), 
    genericName  NVARCHAR(255), 
    variantNumber  INTEGER, 
    variantName  NVARCHAR(15), 
    core  INTEGER
)

