select * from ArticleTest7;

select * from ingest_SizeOrder;


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
            ArticleTest7
    LEFT JOIN ingest_SizeOrder as s  
    ON s.SizeCode = Size
    WHERE "ACTIVE SKUS" = 'YES'
)
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
AND variantCode IS NOT NULL
;