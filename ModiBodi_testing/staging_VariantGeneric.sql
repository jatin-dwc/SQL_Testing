select * from ArticleTest4;

select * from ingest_SizeOrder;


WITH Article_base AS (
        select
            "Child SKU"                                                         as variantCode,
            "Parent SKU"                                                        as genericCode,
            "Description"                                                       as genericName,
            s.SizeOrder                                                         as variantNumber,
            "Combo"                                                             as variantName,
            '1'                                                              as core,
            ROW_NUMBER() OVER (PARTITION BY "Child SKU" ORDER BY "Child SKU")   AS rn
        FROM
            ArticleTest4
    LEFT JOIN ingest_SizeOrder as s  
    ON s.SizeCode = Size
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
;