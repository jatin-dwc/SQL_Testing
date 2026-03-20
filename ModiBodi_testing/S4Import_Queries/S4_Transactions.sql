
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
            '1' as transactionType,
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
            '1' as transactionType,
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
            '1'  as transactionNumber,
            '1' as transactionType,
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
            '1' as transactionType,
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
            '1' as transactionType,
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
    COMBINED AS (
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
            cs.WarehouseCode,  -- WAREHOUSE LINK TO Customer but do this as the last step
            code,
            issueDate,
            issueQuantity,
            lineNumber,
            cm.customerNumber,
            salesPrice,
            deliveryLocation,
            supplier,
            supplierType,
            supplierName,
            conversionFactor
        FROM
            COMBINED as cm
        LEFT JOIN vw_Customers as cs  
        ON cs.CustomerNumber = cm.customerNumber 
        
;




-- Testing Queries below, the above encompasses the live query to use in SQL server to update dataset
--/*

select * from REBELNZ


INPUT_REBELNZ_1 as (
        select 
            '1'  as transactionNumber,
            '1' as transactionType,
            'Shipped' as transactionName,
            CONVERT(NVARCHAR(50), CAST( "ean_upc"  AS BIGINT)) as code,
            -- CONVERT(CHAR(8), CAST(CAST( LEFT( "End of Week", 19) AS DATETIME) AS DATE), 112) AS issueDate,
            "qty_sold" as issueQuantity,
            -- ROW_NUMBER() OVER (PARTITION BY (CONVERT(NVARCHAR(50), CAST( Sku  AS BIGINT))) ORDER BY (CONVERT(NVARCHAR(50), CAST( Sku  AS BIGINT))) ) as lineNumber,
            'RB - NZ' as customerNumber,  -- Adjust Customer Number here, use this to map against Warehouse
            '0' as salesPrice,
            'x' as deliveryLocation,
            'ps' as supplier,
            'suppliertype' as supplierType,
            'supplierName' as supplierName,
            '1' as conversionFactor,
            CONCAT(CAST( "ean_upc" AS BIGINT) , CAST(CONVERT(CHAR(8), CAST(CAST( LEFT( "End of Week", 19) AS DATETIME) AS DATE), 112) as NVARCHAR )) as comboline
        FROM
            REBELNZ


WITH
BIGW_AU_1 AS (
        select
            '1' as transactionNumber,
            '2' as transactionType,
            'ShippedBigW' as transactionName,
            EAN as code,
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
)
    --    BIGW_AU_2 AS (
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
            BIGW_AU_1


WITH BW AS (
select
            EAN as code,
            CONVERT(CHAR(8), CAST(CAST( LEFT( "Promo week", 19) AS DATETIME) AS DATE), 112) AS issueDate
        FROM 
            BigW_AU 
        WHERE Units IS NOT NULL
)
SELECT 
    b.*,
    CONCAT(b.code, b.issueDate ) as combo,
    ROW_NUMBER() OVER (PARTITION BY b.code ORDER BY b.code) as codeline,
    ROW_NUMBER() OVER (PARTITION BY b.issueDate ORDER BY b.issueDate) as dateline,
    ROW_NUMBER() OVER (PARTITION BY (CAST(CONCAT(CAST( b.code AS BIGINT), CAST(b.issueDate AS NVARCHAR )) AS NVARCHAR)) ORDER BY (CAST(CONCAT(CAST( b.code AS BIGINT), CAST(b.issueDate AS NVARCHAR )) AS NVARCHAR)) as comboline
FROM BW as b
ORDER BY issueDate DESC 
;




WITH BW AS (
select
            CAST( EAN AS BIGINT) as code,
            CONVERT(CHAR(8), CAST(CAST( LEFT( "Promo week", 19) AS DATETIME) AS DATE), 112) AS issueDate,
            CONCAT(CAST( EAN AS BIGINT) , CAST(CONVERT(CHAR(8), CAST(CAST( LEFT( "Promo week", 19) AS DATETIME) AS DATE), 112) as NVARCHAR )) as comboline
        FROM 
            BigW_AU 
        WHERE Units IS NOT NULL
),
BW_Combo AS (
SELECT 
    /*(CAST(CONCAT(CAST( b.code AS BIGINT), CAST(b.issueDate AS NVARCHAR )) AS NVARCHAR))
    */
    b.*,
    CONCAT(b.code, b.issueDate ) as combo,
    ROW_NUMBER() OVER (PARTITION BY b.code ORDER BY b.code) as codeline,
    ROW_NUMBER() OVER (PARTITION BY b.issueDate ORDER BY b.issueDate) as dateline,
    ROW_NUMBER() OVER (PARTITION BY comboline ORDER BY comboline ) as lineNumber
FROM BW as b )
select * FROM BW_Combo where combolinecount = 1
;





select 
    CAST(CONCAT(CAST( b.code AS BIGINT), CAST(b.issueDate AS NVARCHAR )) AS NVARCHAR)
from 
    BigW_AU ;

select 
    CAST(CONCAT("amazon-order-id", CAST(SKU AS BIGINT) ) AS NVARCHAR)  as transactionNumber,
    --LEN(CAST(CONCAT("amazon-order-id", CAST(SKU AS BIGINT) ) AS NVARCHAR)) as len_trx,
    '1' as transactionType,
    "order-status" as transactionName,
    SKU as code,
    CONVERT(CHAR(8), CAST(CAST( LEFT( "purchase-date", 19) AS DATETIME) AS DATE), 112) AS issueDate,

FROM
    AMZ_AU


select 
    DISTINCT "amazon-order-id" as amz_order,
    COUNT("amazon-order-id" ) as count
FROM
AMZ_AU
GROUP BY "amazon-order-id"
WHERE "amazon-order-id" = '249-1452995-2338203'
;

select * from vw_Customers

select * from AMZ_Orders ;


select * from AMZ_Orders
WHERE ID ='6077244407908'
--AND "Line: Type" = 'Line Item' ;



-- Clarity of Transaction ID to ID
WITH AMZ_AU as (
select 
    ID ,
    "Transaction: Parent ID" as parentID,
    ROW_NUMBER() OVER (PARTITION BY "Transaction: Parent ID" ORDER BY "Transaction: Parent ID") AS rn -- this acts to count the rows for non unique values and returns a count value for each line, the WHERE rn = 1 limits the result to only a single value should the CUSTOMERID be Unique
FROM 
    AMZ_Orders
WHERE 
    "Transaction: Parent ID" IS NOT NULL
--AND ID ='6077244407908' 
)
SELECT
    ID,
    parentID,
    LEN(ID) as id_len,
    LEN(parentID) as is_parent
FROM 
    AMZ_AU
    WHERE
    rn = 1
     ;


select 
    ID,
    "Line: SKU" as sku,
--    "Transaction: Parent ID" as transactionNumber,
    "Line: ID" as transactionNumber,
    "Line: Quantity" as units
FROM
    AMZ_Orders
WHERE 
--ID ='6077244407908'
-- AND 
"Line: Quantity" IS NOT NULL
AND "Line: Type" = 'Line Item'  ;


select 
    DISTINCT "Line: ID" as transactionNumber
FROM
    AMZ_Orders
WHERE 
--ID ='6077244407908'
-- AND 
"Line: Quantity" IS NOT NULL
AND "Line: Type" = 'Line Item'  ;


/*
AND
    ID ='6077244407908' */

DROP TABLE S4Import_Transactions

    CREATE TABLE S4Import_Transactions (
        controlID  INTEGER, 
        transactionNumber  NVARCHAR(50), 
        transactionType  INTEGER, 
        transactionName  NVARCHAR(50), 
        transactionStatus  NVARCHAR(50), 
        warehouse  NVARCHAR(20), 
        code  NVARCHAR(40), 
        issueDate  CHAR(8), 
        confirmedDate  CHAR(8), 
        requestedDate  CHAR(8), 
        issueQuantity  FLOAT, 
        lineNumber  NVARCHAR(50), 
        confirmedQuantity  FLOAT, 
        requestedQuantity  FLOAT, 
        customerNumber  NVARCHAR(25), 
        customerType  NVARCHAR(50), 
        customerName  NVARCHAR(100), 
        salesPrice  FLOAT, 
        deliveryLocation  NVARCHAR(255), 
        supplier  NVARCHAR(25), 
        supplierType  NVARCHAR(50), 
        supplierName  NVARCHAR(100), 
        buyingPrice  FLOAT, 
        supplyingLocation  NVARCHAR(255),
        conversionFactor  INTEGER, 
        uD1  NVARCHAR(255), 
        uD2  NVARCHAR(255), 
        uD3  NVARCHAR(255), 
        uD4  NVARCHAR(255), 
        issueTime  Time, 
        linkedTransactionNumber  NVARCHAR(50), 
        demandChannel  NVARCHAR(100), 
        demandRegion  NVARCHAR(100)
    )