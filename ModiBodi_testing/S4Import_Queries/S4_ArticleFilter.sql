
-- Transaction Data
WITH 
    INPUT_AMZ_AU as (
        select 
            CONVERT(NVARCHAR(50), CAST( SKU  AS BIGINT)) as code,
            CONVERT(CHAR(8), CAST(CAST( LEFT( "purchase-date", 19) AS DATETIME) AS DATE), 112) AS issueDate,
            quantity as issueQuantity,
            'MP - Amazon AU' as customerNumber  -- Adjust Customer Number here, use this to map against Warehouse
        FROM
            AMZ_AU
        WHERE "order-status" = 'Shipped'
),
        INPUT_AMZ_UK as (
        select 
            CONVERT(NVARCHAR(50), CAST( SKU  AS BIGINT)) as code,
            CONVERT(CHAR(8), CAST(CAST( LEFT( "purchase-date", 19) AS DATETIME) AS DATE), 112) AS issueDate,
            quantity as issueQuantity,
            'MP - Amazon UK' as customerNumber  -- Adjust Customer Number here, use this to map against Warehouse
        FROM
            AMZ_UK
        WHERE "order-status" = 'Shipped'
),
        INPUT_REBELAU_1 as (
        select 
            CONVERT(NVARCHAR(50), CAST( "REBEL SKU"  AS BIGINT)) as code,
            CONVERT(CHAR(8), CAST(CAST( LEFT( "End of Week", 19) AS DATETIME) AS DATE), 112) AS issueDate,
            "Sum of SalesUnits" as issueQuantity,
            'RB - AU' as customerNumber  -- Adjust Customer Number here, use this to map against Warehouse
        FROM
            REBELAU
),
        INPUT_REBELAU_2 AS (
        select 
            code,
            issueDate,
            issueQuantity,
            customerNumber
        FROM
            INPUT_REBELAU_1
),
        INPUT_COLES_1 as (
        select 
            CONVERT(NVARCHAR(50), CAST( Sku  AS BIGINT)) as code,
            CONVERT(CHAR(8), CAST(CAST( LEFT( "Date", 19) AS DATETIME) AS DATE), 112) AS issueDate,
            Qty as issueQuantity,
            'CS' as customerNumber  -- Adjust Customer Number here, use this to map against Warehouse
        FROM
            COLES
),
        INPUT_COLES_2 AS (
        select 
            code,
            issueDate,
            issueQuantity,
            customerNumber
        FROM
            INPUT_COLES_1
),
        INPUT_WOOLIES_1 AS (
        select 
            CONVERT(CHAR(8), TRY_CONVERT(DATE, F1, 103), 112) AS issueDate,
            CONVERT(NVARCHAR(50), CAST( F3 AS BIGINT)) as code,
            ROUND(TRY_CONVERT(FLOAT , F10 ),0) as issueQuantity,
            'WW' as customerNumber  -- Adjust Customer Number here, use this to map against Warehouse
        FROM 
            Woolies
        WHERE F3 IS NOT NULL
        ORDER BY (SELECT NULL)
        OFFSET 16 ROWS
        FETCH NEXT 1000000 ROWS ONLY
        
),
        INPUT_WOOLIES_2 AS (
        SELECT 
            code,
            issueDate,
            issueQuantity,
            customerNumber
        FROM 
            INPUT_WOOLIES_1            
),
        INPUT_BIGW_AU_1 AS (
        select
            CONVERT(NVARCHAR(50), CAST( EAN  AS BIGINT)) as code,
            CONVERT(CHAR(8), CAST(CAST( LEFT( "Promo week", 19) AS DATETIME) AS DATE), 112) AS issueDate,
            Units as issueQuantity,
            'BW' as customerNumber  -- Adjust Customer Number here, use this to map against Warehouse
        FROM 
            BigW_AU
        WHERE Units IS NOT NULL
),
        INPUT_BIGW_AU_2 AS (
        select 
            code,
            issueDate,
            issueQuantity,
            customerNumber
        FROM
            INPUT_BIGW_AU_1
        ),
    COMBINED AS (
/*
        SELECT 
        transactionNumber, transactionType, transactionName, code, issueDate, issueQuantity, lineNumber, customerNumber, 
        salesPrice, deliveryLocation, supplier,supplierType, supplierName, conversionFactor FROM INPUT_SHPFY_AU
        UNION ALL
*/
        SELECT 
        code, issueDate, issueQuantity, customerNumber
        FROM INPUT_AMZ_AU
        UNION ALL
        SELECT 
        code, issueDate, issueQuantity, customerNumber 
        FROM INPUT_AMZ_UK
        UNION ALL
        SELECT code, issueDate, issueQuantity, customerNumber 
        FROM INPUT_COLES_2
        UNION ALL
        SELECT 
        code, issueDate, issueQuantity, customerNumber
        FROM INPUT_REBELAU_2
        UNION ALL
        SELECT 
        code, issueDate, issueQuantity, customerNumber
        FROM INPUT_WOOLIES_2
        UNION ALL
        SELECT 
        code, issueDate, issueQuantity, customerNumber
        FROM INPUT_BIGW_AU_2
)
--    SELECT * from COMBINED -- use this line as a test of the combination and order
    S4_Transaction_all AS (
        SELECT 
            '1' as controlID,
            cs.WarehouseCode,  -- WAREHOUSE LINK TO Customer but do this as the last step
            code,
            issueDate,
            issueQuantity,
            cm.customerNumber
        FROM
            COMBINED as cm
        LEFT JOIN vw_Customers as cs  
        ON cs.CustomerNumber = cm.customerNumber 
    ),

-- Article Code Master
Article_1 AS (
    SELECT 
        CONVERT(NVARCHAR(40), CAST("Item Code" AS BIGINT)) AS code,
        ROW_NUMBER() OVER (PARTITION BY "Item Code" ORDER BY "Item Code") AS rn, -- this acts to count the rows for non unique values and returns a count value for each line, the WHERE rn = 1 limits the result to only a single value should the CUSTOMERID be Unique
        CONVERT(CHAR(8), "Launch date AU-US-NZ", 112) as L_AUUSNZ,
        CONVERT(CHAR(8), "Launch date EU", 112) as L_EU,
        CONVERT(CHAR(8), "Launch date UK", 112) as L_UK
    FROM 
        ArticleTest7                        --- REPLACE WITH SQL TABLE
    WHERE "ACTIVE SKUS" = 'YES'
),

-- Combine Warehouse Table with all Records in Master Article codes to later assign Region specifc attributes

Art_WHS AS (
    SELECT 
        a1.*,
        w.warehouse as warehouse
    FROM 
        Article_1 as a1
    CROSS JOIN
        vw_Warehouse as w
    WHERE a1.rn=1 
    AND a1.code IS NOT NULL
),
Art_WHS_Price AS (
    SELECT 
        aw.code,
        aw.warehouse,
        CASE
            WHEN w.region IN ('Australia' , 'USA', 'NZ') then L_AUUSNZ
            WHEN w.region = 'UK' then L_UK
            WHEN w.region = 'Europe' then L_EU 
        ELSE L_AUUSNZ
        END AS groupCode5
    FROM 
        Art_WHS AS aw 
    INNER JOIN vw_Warehouse as w 
    ON aw.warehouse = w.warehouse
),

-- Historical PO
HistoricalPO AS (
select 
        w.warehouse as warehouse,
        CONVERT(NVARCHAR(40), CAST(c."Item Code"AS BIGINT)) as code,
        CONVERT(CHAR(8),"Good Received Date" , 112) as deliveredDate,
        Quantity as deliveredQuantity
    FROM 
    ingest_POHistory as c 
    LEFT JOIN vw_location_warehouse as w
   ON w.location = c.Location
   ),

-- Stock Details

AU_EDI AS (
    SELECT
        'AU EDI' as warehouse,
        CONVERT(NVARCHAR(40), CAST("ItemCode" AS BIGINT)) AS code,
        "ItemClass" as stockType_setting,
        -- SOH,
        "Available Stock" as "AVS",
        "Allocated Current orders" as "ALS",
        "Allocated Back orders" as "BOS",
        "On Hold Qty" as "RQS"
    FROM 
        soh_au_edi
),
AU_ONLINE AS (
    SELECT
        'AU MB' as warehouse, 
        CONVERT(NVARCHAR(40), CAST(",10,0)" AS BIGINT)) AS code,
        "ItemClass" as stockType_setting,
        "Available Stock" as "AVS",
        "Allocated Current orders" as "ALS",
        "Allocated Back orders" as "BOS",
        "On Hold Qty" as "RQS"
    FROM 
        soh_au_online
),
EU_ONLINE AS (
    SELECT
        'EU MB' as warehouse,
        CASE 
            WHEN CHARINDEX('-',  SKU) > 0 THEN LEFT( SKU , CHARINDEX('-',  SKU  ) - 1 )
            ELSE  SKU
        END AS code,
        "Type" as stockType_setting,
        "QTY Available" as "AVS",
        "QTY allocated" as "ALS",
        "QTY on backorder" as "BOS",
        "QTY reserved" as "RQS"
    FROM
        soh_eu_online
),
EU_WS AS (
    SELECT
        'EU MB' as warehouse,
        CASE 
            WHEN CHARINDEX('-',  SKU) > 0 THEN LEFT( SKU , CHARINDEX('-',  SKU  ) - 1 )
            ELSE  SKU
        END AS code,
        "Type" as stockType_setting,
        "QTY Available" as "AVS",
        "QTY allocated" as "ALS",
        "QTY on backorder" as "BOS",
        "QTY reserved" as "RQS"
    FROM
        soh_eu_ws
),
UK_ONLINE AS (
    SELECT
        'UK MB' as warehouse,
        CASE 
            WHEN CHARINDEX('-',  SKU) > 0 THEN LEFT( SKU , CHARINDEX('-',  SKU  ) - 1 )
            ELSE  SKU
        END AS code,
        "Type" as stockType_setting,
        "QTY Available" as "AVS",
        "QTY allocated" as "ALS",
        "QTY on backorder" as "BOS",
        "QTY reserved" as "RQS"
    FROM
        soh_uk_online
),
UK_WS AS (
    SELECT
        'UK WS' as warehouse,
        CASE 
            WHEN CHARINDEX('-',  SKU) > 0 THEN LEFT( SKU , CHARINDEX('-',  SKU  ) - 1 )
            ELSE  SKU
        END AS code,
        "Type" as stockType_setting,
        "QTY Available" as "AVS",
        "QTY allocated" as "ALS",
        "QTY on backorder" as "BOS",
        "QTY reserved" as "RQS"
    FROM
        soh_uk_ws
),

COMBINATION AS (
    SELECT
        warehouse, code, stockType_setting, AVS, ALS, BOS, RQS
    FROM 
        AU_EDI
    UNION ALL
    SELECT
        warehouse, code, stockType_setting, AVS, ALS, BOS, RQS
    FROM 
        AU_ONLINE
    /*
    UNION ALL
    SELECT
        warehouse, code, AVS, ALS, BOS, RQS
    FROM 
        AU_PR
    UNION ALL
    SELECT
        warehouse, code, AVS, ALS, BOS, RQS
    FROM 
        AU_OTHER
    */
    UNION ALL
    SELECT
        warehouse, code, stockType_setting, AVS, ALS, BOS, RQS
    FROM 
        EU_ONLINE
    UNION ALL
    SELECT
        warehouse, code, stockType_setting, AVS, ALS, BOS, RQS
    FROM 
        EU_WS
    UNION ALL
    SELECT
        warehouse, code, stockType_setting, AVS, ALS, BOS, RQS
    FROM 
        UK_ONLINE
    UNION ALL
    SELECT
        warehouse, code, stockType_setting, AVS, ALS, BOS, RQS
    FROM 
        UK_WS
),

-- combine queries then UNPIVOT

    SOH_UNPIVOT AS (
    SELECT
        warehouse,
        code,
        stockType_setting,
        stockTypeCode,
        stockOnHand
    FROM
        COMBINATION 
    UNPIVOT (stockOnHand FOR stockTypeCode IN ( "AVS", "ALS", "BOS", "RQS" ) ) as unpvt 
),
    SOH_FINAL AS ( 
    SELECT
        warehouse,
        code,
        stockOnHand
    FROM
        SOH_UNPIVOT
),



    )
        
;