
-- Create Transaction table, all Columns required
/*
CREATE TABLE S4Import_Transactions (
controlID  INTEGER, transactionNumber  NVARCHAR(50), transactionType  INTEGER, transactionName  NVARCHAR(50), transactionStatus  NVARCHAR(50), 
warehouse  NVARCHAR(20), code  NVARCHAR(40), issueDate  CHAR(8), confirmedDate  CHAR(8), requestedDate  CHAR(8), issueQuantity  FLOAT, lineNumber  NVARCHAR(50), 
confirmedQuantity  FLOAT, requestedQuantity  FLOAT, customerNumber  NVARCHAR(25), customerType  NVARCHAR(50), customerName  NVARCHAR(100), salesPrice  FLOAT, 
deliveryLocation  NVARCHAR(255), supplier  NVARCHAR(25), supplierType  NVARCHAR(50), supplierName  NVARCHAR(100), uyingPrice  FLOAT, supplyingLocation  NVARCHAR(255), 
conversionFactor  FLOAT, uD1  NVARCHAR(255), uD2  NVARCHAR(255), uD3  NVARCHAR(255), uD4  NVARCHAR(255), issueTime  Time, linkedTransactionNumber  NVARCHAR(50), 
demandChannel  NVARCHAR(100), demandRegion  NVARCHAR(100)
)
*/

/*
-- Baseline for all Transaction tables, remove those that are unavailable
INSERT INTO S4Import_Transactions (
controlID , transactionNumber  , transactionType , transactionName ,warehouse , code , 
issueDate , issueQuantity , lineNumber ,customerNumber , salesPrice , deliveryLocation , 
supplier , buyingPrice , supplyingLocation  , conversionFactor )
*/

-- Row 339 is the END OF THE QUERY

-- Clear table before writing new data

TRUNCATE TABLE S4Import_Transactions ;

-- Transaction tables for all customers below

WITH 
/*                                                                                      SHOPIFY AU - ON HOLD UNTIL FORMAT IS FINAL AS AT 18 MARCH 2026
        INPUT_SHPFY_AU as ( -- SHOPIFY AUSTRALIA
        select 
            "Line: ID" as transactionNumber,
            '1' as transactionType,
            "Line: Type" as transactionName,
            CONVERT(NVARCHAR(50), CAST("Line: SKU" AS BIGINT)) AS code,
            CONVERT(CHAR(8), CAST(CAST( LEFT( "Created At", 19) AS DATETIME) AS DATE), 112) AS issueDate,
            "Line: Quantity" as issueQuantity,
            "Row #" as lineNumber,
            'OL - AU' as customerNumber, -- Adjust Customer Number here, use this to map against Warehouse
            "Line: Price" as salesPrice,
            'x' as deliveryLocation,
            'ps' as supplier,
            'suppliertype' as supplierType,
            'supplierName' as supplierName,
            '1' as conversionFactor
        FROM
            SHPFY_AU
        WHERE 
        "Line: Quantity" IS NOT NULL  -- probably need for all Shopify sites
        AND "Line: Type" = 'Line Item'
),
*/
        INPUT_AMZ_AU as (
        select 
            CAST(CONCAT("amazon-order-id", CAST(SKU AS BIGINT) ) AS NVARCHAR)  as transactionNumber,
            '2' as transactionType,
            "order-status" as transactionName,
            CONVERT(NVARCHAR(50), CAST( SKU  AS BIGINT)) as code,
            CONVERT(CHAR(8), CAST(CAST( LEFT( "purchase-date", 19) AS DATETIME) AS DATE), 112) AS issueDate,
            quantity as issueQuantity,
            ROW_NUMBER() OVER (PARTITION BY "amazon-order-id" ORDER BY "amazon-order-id") as lineNumber,
            'MP - Amazon AU' as customerNumber,  -- Adjust Customer Number here, use this to map against Warehouse
            "item-price" as salesPrice,
            'x' as deliveryLocation,
            'ps' as supplier,
            'suppliertype' as supplierType,
            'supplierName' as supplierName,
            '1' as conversionFactor
        FROM
            AMZ_AU
        WHERE "order-status" = 'Shipped'
),
        INPUT_AMZ_UK as (
        select 
            CAST(CONCAT("amazon-order-id", CAST(SKU AS BIGINT) ) AS NVARCHAR)  as transactionNumber,
            '2' as transactionType,
            "order-status" as transactionName,
            CONVERT(NVARCHAR(50), CAST( SKU  AS BIGINT)) as code,
            CONVERT(CHAR(8), CAST(CAST( LEFT( "purchase-date", 19) AS DATETIME) AS DATE), 112) AS issueDate,
            quantity as issueQuantity,
            ROW_NUMBER() OVER (PARTITION BY "amazon-order-id" ORDER BY "amazon-order-id") as lineNumber,
            'MP - Amazon UK' as customerNumber,  -- Adjust Customer Number here, use this to map against Warehouse
            "item-price" as salesPrice,
            'x' as deliveryLocation,
            'ps' as supplier,
            'suppliertype' as supplierType,
            'supplierName' as supplierName,
            '1' as conversionFactor
        FROM
            AMZ_UK
        WHERE "order-status" = 'Shipped'
),
        INPUT_REBELAU_1 as (
        select 
            '1' as transactionNumber,
            '2' as transactionType,
            'Shipped' as transactionName,
            CONVERT(NVARCHAR(50), CAST( "REBEL SKU"  AS BIGINT)) as code,
            CONVERT(CHAR(8), CAST(CAST( LEFT( "End of Week", 19) AS DATETIME) AS DATE), 112) AS issueDate,
            "Sum of SalesUnits" as issueQuantity,
            -- ROW_NUMBER() OVER (PARTITION BY (CONVERT(NVARCHAR(50), CAST( Sku  AS BIGINT))) ORDER BY (CONVERT(NVARCHAR(50), CAST( Sku  AS BIGINT))) ) as lineNumber,
            'RB - AU' as customerNumber,  -- Adjust Customer Number here, use this to map against Warehouse
            '0' as salesPrice,
            'x' as deliveryLocation,
            'ps' as supplier,
            'suppliertype' as supplierType,
            'supplierName' as supplierName,
            '1' as conversionFactor,
            CONCAT(CAST( "REBEL SKU" AS BIGINT) , CAST(CONVERT(CHAR(8), CAST(CAST( LEFT( "End of Week", 19) AS DATETIME) AS DATE), 112) as NVARCHAR )) as comboline
        FROM
            REBELAU
),
        INPUT_REBELAU_2 AS (
        select 
            transactionNumber,
            transactionType,
            transactionName,
            code,
            issueDate,
            issueQuantity,
            customerNumber,
            salesPrice,
            deliveryLocation,
            supplier,
            supplierType,
            supplierName,
            conversionFactor,
            ROW_NUMBER() OVER (PARTITION BY comboline ORDER BY comboline ) as lineNumber
        FROM
            INPUT_REBELAU_1
),
        INPUT_COLES_1 as (
        select 
            '1'  as transactionNumber,
            '2' as transactionType,
            'Shipped' as transactionName,
            CONVERT(NVARCHAR(50), CAST( Sku  AS BIGINT)) as code,
            CONVERT(CHAR(8), CAST(CAST( LEFT( "Date", 19) AS DATETIME) AS DATE), 112) AS issueDate,
            Qty as issueQuantity,
            -- ROW_NUMBER() OVER (PARTITION BY (CONVERT(NVARCHAR(50), CAST( Sku  AS BIGINT))) ORDER BY (CONVERT(NVARCHAR(50), CAST( Sku  AS BIGINT))) ) as lineNumber,
            'CS' as customerNumber,  -- Adjust Customer Number here, use this to map against Warehouse
            '0' as salesPrice,
            'x' as deliveryLocation,
            'ps' as supplier,
            'suppliertype' as supplierType,
            'supplierName' as supplierName,
            '1' as conversionFactor,
            CONCAT(CAST( Sku AS BIGINT) , CAST(CONVERT(CHAR(8), CAST(CAST( LEFT( "Date", 19) AS DATETIME) AS DATE), 112) as NVARCHAR )) as comboline
        FROM
            COLES
),
        INPUT_COLES_2 AS (
        select 
            transactionNumber,
            transactionType,
            transactionName,
            code,
            issueDate,
            issueQuantity,
            customerNumber,
            salesPrice,
            deliveryLocation,
            supplier,
            supplierType,
            supplierName,
            conversionFactor,
            ROW_NUMBER() OVER (PARTITION BY comboline ORDER BY comboline ) as lineNumber
        FROM
            INPUT_COLES_1
),
        INPUT_WOOLIES_1 AS (
        select 
            '1'  as transactionNumber,
            '2' as transactionType,
            'Shipped' as transactionName,
            CONVERT(CHAR(8), TRY_CONVERT(DATE, F1, 103), 112) AS issueDate,
            CONVERT(NVARCHAR(50), CAST( F3 AS BIGINT)) as code,
            ROUND(TRY_CONVERT(FLOAT , F10 ),0) as issueQuantity,
            'WW' as customerNumber,  -- Adjust Customer Number here, use this to map against Warehouse
            CASE 
                WHEN F10 = 0 THEN 0
                ELSE ROUND( TRY_CONVERT(FLOAT , F9 ) / F10, 3 )
            END AS salesPrice,
            'x' as deliveryLocation,
            'ps' as supplier,
            'suppliertype' as supplierType,
            'supplierName' as supplierName,
            '1' as conversionFactor,
            CONCAT(CAST( F3 AS BIGINT) , CONVERT(CHAR(8), TRY_CONVERT(DATE, F1, 103), 112) ) as comboline
        FROM 
            Woolies
        WHERE F3 IS NOT NULL
        ORDER BY (SELECT NULL)
        OFFSET 16 ROWS
        FETCH NEXT 1000000 ROWS ONLY
        
),
        INPUT_WOOLIES_2 AS (
        SELECT 
            transactionNumber,
            transactionType,
            transactionName,
            code,
            issueDate,
            issueQuantity,
            customerNumber,
            salesPrice,
            deliveryLocation,
            supplier,
            supplierType,
            supplierName,
            conversionFactor,
            ROW_NUMBER() OVER (PARTITION BY comboline ORDER BY comboline ) as lineNumber
        FROM 
            INPUT_WOOLIES_1            
),
        INPUT_BIGW_AU_1 AS (
        select
            '1' as transactionNumber,
            '2' as transactionType,
            'ShippedBigW' as transactionName,
            CONVERT(NVARCHAR(50), CAST( EAN  AS BIGINT)) as code,
            CONVERT(CHAR(8), CAST(CAST( LEFT( "Promo week", 19) AS DATETIME) AS DATE), 112) AS issueDate,
            Units as issueQuantity,
            'BW' as customerNumber,  -- Adjust Customer Number here, use this to map against Warehouse
            CASE 
                WHEN Units = 0 THEN 0
                ELSE ROUND(Sales / Units, 3 )
            END AS salesPrice,
            'x' as deliveryLocation,
            'ps' as supplier,
            'suppliertype' as supplierType,
            'supplierName' as supplierName,
            '1' as conversionFactor,
            CONCAT(CAST( EAN AS BIGINT) , CAST(CONVERT(CHAR(8), CAST(CAST( LEFT( "Promo week", 19) AS DATETIME) AS DATE), 112) as NVARCHAR )) as comboline
        FROM 
            BigW_AU
        WHERE Units IS NOT NULL
),
        INPUT_BIGW_AU_2 AS (
        select 
            transactionNumber,
            transactionType,
            transactionName,
            code,
            issueDate,
            issueQuantity,
            customerNumber,
            salesPrice,
            deliveryLocation,
            supplier,
            supplierType,
            supplierName,
            conversionFactor,
            ROW_NUMBER() OVER (PARTITION BY comboline ORDER BY comboline ) as lineNumber
        FROM
            INPUT_BIGW_AU_1
        ),
    COMBINED_TRX AS (
/*
        SELECT 
        transactionNumber, transactionType, transactionName, code, issueDate, issueQuantity, lineNumber, customerNumber, 
        salesPrice, deliveryLocation, supplier,supplierType, supplierName, conversionFactor FROM INPUT_SHPFY_AU
        UNION ALL
*/
        SELECT 
        transactionNumber, transactionType, transactionName, code, issueDate, issueQuantity, lineNumber, customerNumber, 
        salesPrice, deliveryLocation, supplier, supplierType, supplierName, conversionFactor FROM INPUT_AMZ_AU
        UNION ALL
        SELECT 
        transactionNumber, transactionType, transactionName, code, issueDate, issueQuantity, lineNumber, customerNumber, 
        salesPrice, deliveryLocation, supplier, supplierType, supplierName, conversionFactor FROM INPUT_AMZ_UK
        UNION ALL
        SELECT 
        transactionNumber, transactionType, transactionName, code, issueDate, issueQuantity, linenumber, customerNumber,
        salesPrice, deliveryLocation, supplier, supplierType, supplierName, conversionFactor FROM INPUT_COLES_2
        UNION ALL
        SELECT 
        transactionNumber, transactionType, transactionName, code, issueDate, issueQuantity, linenumber, customerNumber,
        salesPrice, deliveryLocation, supplier, supplierType, supplierName, conversionFactor FROM INPUT_REBELAU_2
        UNION ALL
        SELECT 
        transactionNumber, transactionType, transactionName, code, issueDate, issueQuantity, lineNumber, customerNumber, 
        salesPrice, deliveryLocation, supplier, supplierType, supplierName, conversionFactor FROM INPUT_WOOLIES_2
        UNION ALL
        SELECT 
        transactionNumber, transactionType, transactionName, code, issueDate, issueQuantity, linenumber, customerNumber,
        salesPrice, deliveryLocation, supplier, supplierType, supplierName, conversionFactor FROM INPUT_BIGW_AU_2
),
    transfers_au AS (
    SELECT
        CASE  
            WHEN "From" = 'EDI'     THEN 'AU EDI'
            WHEN "From" = 'MB'      THEN 'AU MB'
            WHEN "From" = 'WS'      THEN 'AU WS'
            ELSE NULL 
        END AS warehouse_from,
        CASE  
            WHEN "To" = 'EDI'     THEN 'AU EDI'
            WHEN "To" = 'MB'      THEN 'AU MB'
            WHEN "To" = 'WS'      THEN 'AU WS'
            ELSE NULL 
        END AS warehouse_to,
        CONVERT(NVARCHAR(40), CAST( SKU AS BIGINT)) as code,
        "File Reference" as poNumber,
        CONVERT(CHAR(8),"Date Completed", 112) as deliveryDate,
        ROUND(Qty,0) as openQuantity,
        "Comments" as poComment,
        ROUND(Qty,0) as originalQuantity,
        ROUND(Qty,0) as suppliedQuantity,
        NULL as freeText1,
        '2' as orderTypeNumber,
        NULL as supplierName,
        CONVERT(CHAR(8),"Date of Request", 112) as orderDate,
        CONVERT(CHAR(8),"Date of Request", 112) as requestDate
    FROM 
        TFR_AU 
    ),
    ---- EU Transfers
    transfers_eu AS (
    SELECT
        CASE  
            WHEN "From" = 'MB'      THEN 'EU MB'
            WHEN "From" = 'WS'      THEN 'EU WS'
            WHEN "From" = 'EU-WS'   THEN 'EU WS'
            ELSE NULL 
        END AS warehouse_from,
        CASE  
            WHEN "To" = 'UK MB'     THEN 'UK MB'
            WHEN "To" = 'UK-MB'     THEN 'UK MB'
            WHEN "To" = 'UK WS'     THEN 'UK WS'
            WHEN "To" = 'UK-WS'     THEN 'UK WS'
            WHEN "To" = 'MB'        THEN 'EU MB'
            WHEN "To" = 'WS'        THEN 'EU WS'
            ELSE NULL 
        END AS warehouse_to,
        CONVERT(NVARCHAR(40), CAST( SKU AS BIGINT)) as code,
        "File Reference" as poNumber,
        CONVERT(CHAR(8),"Date Completed", 112) as deliveryDate,
        ROUND(Qty,0) as openQuantity,
        "Comments" as poComment,
        ROUND(Qty,0) as originalQuantity,
        ROUND(Qty,0) as suppliedQuantity,
        NULL as freeText1,
        '2' as orderTypeNumber,
        NULL as supplierName,
        CONVERT(CHAR(8),"Date of Request", 112) as orderDate,
        CONVERT(CHAR(8),"Date of Request", 112) as requestDate
    FROM 
        TFR_EU
    ),

    ---- UK Transfers
    transfers_uk AS (
    SELECT
        CASE  
            WHEN "From" = 'UK WS'       THEN 'UK WS'
            WHEN "From" = 'WS'          THEN 'UK WS'
            WHEN "From" = 'MB'          THEN 'UK MB'
            ELSE NULL 
        END AS warehouse_from,
        CASE  
            WHEN "To" = 'MB'        THEN 'UK MB'
            WHEN "To" = 'WS'        THEN 'UK WS'
            WHEN "To" = ' WS'       THEN 'UK WS'
            WHEN "To" = 'EU MB'     THEN 'EU MB'
            WHEN "To" = 'EU WS'     THEN 'EU WS'
            ELSE NULL 
        END AS warehouse_to,
        CONVERT(NVARCHAR(40), CAST( SKU AS BIGINT)) as code,
        "File Reference" as poNumber,
        CONVERT(CHAR(8),"Date Completed", 112) as deliveryDate,
        ROUND(Qty,0) as openQuantity,
        "Comments" as poComment,
        ROUND(Qty,0) as originalQuantity,
        ROUND(Qty,0) as suppliedQuantity,
        NULL as freeText1,
        '2' as orderTypeNumber,
        NULL as supplierName,
        CONVERT(CHAR(8),"Date of Request", 112) as orderDate,
        CONVERT(CHAR(8),"Date of Request", 112) as requestDate
    FROM 
        TFR_UK
    ),
    COMBINED AS (
        SELECT
            warehouse_from, warehouse_to, code, poNumber, deliveryDate, openQuantity,poComment,
            originalQuantity,suppliedQuantity,freeText1,orderTypeNumber,supplierName, orderDate, requestDate
        FROM 
            transfers_au
        UNION ALL
        SELECT
            warehouse_from, warehouse_to, code, poNumber, deliveryDate, openQuantity,poComment,
            originalQuantity,suppliedQuantity,freeText1,orderTypeNumber,supplierName, orderDate, requestDate
        FROM 
            transfers_eu
        UNION ALL
        SELECT
            warehouse_from, warehouse_to, code, poNumber, deliveryDate, openQuantity,poComment,
            originalQuantity,suppliedQuantity,freeText1,orderTypeNumber,supplierName, orderDate, requestDate
        FROM 
            transfers_uk
    ),
    CLEANUP_TFR AS (
        SELECT 
            warehouse_from AS warehouse, 
    --        warehouse_to AS warehouse, 
            code, 
            poNumber as transactionNumber, 
            deliveryDate as issueDate, 
            openQuantity as issueQuantity,
            poComment,
            originalQuantity,
            suppliedQuantity,
            freeText1, 
            orderTypeNumber, 
            supplierName, 
            orderDate, 
            requestDate,
            '1' as conversionFactor,
            '3' as transactionType,
            NULL as transactionName,
            NULL as lineNumber,
            NULL as customerNumber,
            NULL as salesPrice,
            NULL as deliveryLocation,
            NULL as supplier,
            NULL as supplierType
        from COMBINED as cb
        INNER JOIN vw_ArticleFilter_12Months as xd
                ON cb.deliveryDate = xd.DateKey
        WHERE
            orderDate IS NOT NULL 
            AND warehouse_from IS NOT NULL
            AND warehouse_to IS NOT NULL
            AND xd.FullDate <= CURRENT_DATE
            AND deliveryDate IS NOT NULL -- Keep this for feed into PurchaseOrder, deliveryDate IS NULL, keep the warehouse_to
                                    -- Historical_PO - Change deliveryDate filter to IS NOT NULL, keep warehouse_to
                                    -- Transactions - Change deliveryDate filter to IS NOT NULL, keep warehouse_from
),
--select * from CLEANUP_TFR

COMBO_TRX_TRF AS (
        SELECT
            transactionNumber, transactionType, transactionName,cs.WarehouseCode as warehouse, code, issueDate, issueQuantity, lineNumber, cmt.customerNumber, 
        salesPrice, deliveryLocation, supplier, supplierType, supplierName, conversionFactor
        FROM
            COMBINED_TRX as cmt
        LEFT JOIN vw_Customers as cs  
            ON cs.CustomerNumber = cmt.customerNumber
        UNION ALL
        SELECT
            transactionNumber, transactionType, transactionName, warehouse, code, issueDate, issueQuantity, lineNumber, customerNumber, 
        salesPrice, deliveryLocation , supplier, supplierType, supplierName, conversionFactor
        FROM
            CLEANUP_TFR

)
--    SELECT * from COMBINED -- use this line as a test of the combination and order

    INSERT INTO S4Import_Transactions ( 
        controlID , 
        transactionNumber  , 
        transactionType , 
        transactionName ,
        warehouse , 
        code , 
        issueDate , 
        issueQuantity , 
        lineNumber ,
        customerNumber , 
        salesPrice , 
        deliveryLocation , 
        supplier , 
        supplierType ,
        supplierName ,
        -- buyingPrice , -- Need to find this
        -- supplyingLocation  , -- Need to find this
        conversionFactor )
        SELECT 
            '1' as controlID,
            transactionNumber,
            transactionType,
            transactionName,
            cm.warehouse,  -- WAREHOUSE LINK TO Customer but do this as the last step
            cm.code,
            issueDate,
            issueQuantity,
            lineNumber,
            customerNumber,
            salesPrice,
            deliveryLocation,
            supplier,
            supplierType,
            supplierName,
            conversionFactor
        FROM
            COMBO_TRX_TRF as cm
        INNER JOIN vw_ArticleFilter_12Months as xd
            ON cm.issueDate = xd.DateKey
        INNER JOIN S4Import_ArticleFilter as af 
            ON af.code = cm.code
            AND af.warehouse = cm.warehouse
        WHERE 
            xd.FullDate <= CURRENT_DATE
        
;
