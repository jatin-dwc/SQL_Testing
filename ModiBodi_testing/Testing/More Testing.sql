WITH Article_1 AS (
    SELECT 
        CONVERT(NVARCHAR(40), CAST("Item Code" AS BIGINT))  AS code,
        CONVERT(CHAR(8), "SKU created/updated", 112)        AS creationDate,
        Description                                          AS description,
        '1'                                                  AS criterium1,
        NULL                                                 AS criterium2,
        NULL                                                 AS criterium3,
        NULL                                                 AS criterium4,
        "PRODUCT FAMILY"                                     AS groupCode1,
        "Product Class"                                      AS groupCode2,
        "PRODUCT LINE"                                       AS groupCode3,
        "ABSORBENCY"                                         AS groupCode4,
        Colour                                               AS groupCode6,
        Size                                                 AS uD1,
        "Customer name"                                      AS uD2,
        "ACTIVE SKUS"                                        AS uD3
    FROM ArticleTest2
),
Art_WHS AS (
    SELECT 
        a1.*,
        w.warehouse                                          AS warehouse
    FROM Article_1 AS a1
    CROSS JOIN vw_Warehouse AS w
)
INSERT INTO stg_ArticleCodeMaster_TestOnly (warehouse, code, creationDate, description, criterium1, criterium2,
                                            criterium3, criterium4, groupCode1, groupCode2, groupCode3, groupCode4,
                                            groupCode6, uD1, uD2, uD3)
SELECT
    warehouse,
    code,
    creationDate,
    description,
    criterium1,
    criterium2,
    criterium3,
    criterium4,
    groupCode1,
    groupCode2,
    groupCode3,
    groupCode4,
    groupCode6,
    uD1,
    uD2,
    uD3
FROM Art_WHS;