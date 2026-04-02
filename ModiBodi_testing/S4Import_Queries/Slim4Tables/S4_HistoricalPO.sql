ALTER PROCEDURE load_S4HistoricalPO
    AS
        BEGIN

-- Clear table before writing new data

TRUNCATE TABLE S4Import_Historical_PO ;

WITH HistoricalPO AS (
select 
        w.warehouse as warehouse,
        CONVERT(NVARCHAR(40), CAST(c."Item Code"AS BIGINT)) as code,
        c."MB PO Number" as poNumber,
        "Line #" as line,
        '1' as orderTypeNumber,         -- 1 = PO , 2 = Transfer Order -- Transfer orders in a separate file
        CONVERT(CHAR(8),"Good Received Date" , 112) as deliveredDate,
        Quantity as deliveredQuantity,
        Supplier as supplierDetails,
        CONVERT(CHAR(8),"PO RAISED DATE" , 112)  as orderedDate,
        CONVERT(CHAR(8),"Original ex fty" , 112)  as requestedDate,
        Qty as orderedQuantity,
        Qty as requestedQuantity,  -- Need to fix this line once review with Purchase order table is vetted
        "Supplier Number" as supplierNumber,
        Supplier as supplierName,
        " FOB" as buyingPrice
    FROM 
    ingest_POHistory as c 
    LEFT JOIN vw_location_warehouse as w
   ON w.location = c.Location
   ),

   -- AU Transfers
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
COMBINED_TFR AS (
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
--      warehouse_from AS warehouse, 
        warehouse_to AS warehouse, 
        code, poNumber, deliveryDate, openQuantity,poComment,
        originalQuantity,suppliedQuantity,freeText1, orderTypeNumber, supplierName, orderDate, requestDate
    from COMBINED_TFR
    WHERE
        orderDate IS NOT NULL 
        AND warehouse_from IS NOT NULL
        AND warehouse_to IS NOT NULL
        AND deliveryDate IS NOT NULL -- Keep this for PurchaseOrders, deliveryDate IS NULL, keep the warehouse_to
                                 -- Historical_PO - Change deliveryDate filter to IS NOT NULL, keep warehouse_to
                                 -- Transactions - Change deliveryDate filter to IS NOT NULL, keep warehouse_from
),
COMBINED_HPO_TFR AS (
    SELECT
        warehouse, code, poNumber,
        NULL as line,
        orderTypeNumber,
        deliveryDate as deliveredDate, 
        openQuantity as deliveredQuantity,
        NULL as supplierDetails,
        orderDate as orderedDate,
        requestDate as requestedDate,
        NULL as orderedQuantity,
        NULL as requestedQuantity,
        NULL as supplierNumber,
        supplierName,
        NULL as buyingPrice
    FROM 
        CLEANUP_TFR
    UNION ALL
    SELECT
        warehouse, code, poNumber, line, orderTypeNumber, deliveredDate, deliveredQuantity, 
        supplierDetails, orderedDate, requestedDate, orderedQuantity, requestedQuantity,supplierNumber, supplierName, buyingPrice
    FROM 
        HistoricalPO
)

INSERT INTO S4Import_Historical_PO ( controlID, warehouse, code, poNumber, line, orderTypeNumber, deliveredDate, 
deliveredQuantity, supplierDetails, orderedDate, requestedDate, orderedQuantity, requestedQuantity, supplierNumber, 
supplierName, buyingPrice )
    SELECT
        '1' as controlID, 
        po.warehouse, 
        po.code, 
        poNumber, 
        line, 
        orderTypeNumber, 
        deliveredDate, 
        deliveredQuantity, 
        supplierDetails, 
        orderedDate, 
        requestedDate, 
        orderedQuantity, 
        requestedQuantity, 
        supplierNumber, 
        supplierName, 
        buyingPrice
    FROM 
        COMBINED_HPO_TFR as po
    JOIN dim_Date as dd 
        ON dd.DateKey = po.deliveredDate
    INNER JOIN vw_Last_XDays as xd 
        ON xd.DateKey = po.deliveredDate
    INNER JOIN S4Import_ArticleFilter as af
        ON po.code = af.code
        AND po.warehouse = af.warehouse 
    WHERE dd.FullDate < CURRENT_DATE
        AND po.warehouse IS NOT NULL
        AND po.code IS NOT NULL
        ;
END;


-- Setup queries below
/*
CREATE TABLE S4Import_Historical_PO (

controlID  INTEGER, warehouse  NVARCHAR(20), code  NVARCHAR(40), poNumber  NVARCHAR(100), 
line  INTEGER, orderTypeNumber  INTEGER, deliveredDate  NVARCHAR(10), deliveredQuantity  INTEGER, 
supplierDetails  NVARCHAR(100), poComment  NVARCHAR(4000), freeText1  NVARCHAR(255), 
freeText2  NVARCHAR(255), freeNumber1  FLOAT, freeNumber2  FLOAT, orderedDate  NVARCHAR(10), 
requestedDate  NVARCHAR(10), orderedQuantity  INTEGER, requestedQuantity  INTEGER, confirmedQuantity  INTEGER, 
confirmedDate  NVARCHAR(10), supplierNumber  NVARCHAR(60), supplierName  NVARCHAR(100), buyingPrice  FLOAT
)
*/