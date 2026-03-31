
-- Clear table before writing new data

TRUNCATE TABLE S4Import_PurchaseOrder ;

-- Current Purchase Order table creation

WITH CurrentPO AS (
select 
        w.warehouse as warehouse,
        CONVERT(NVARCHAR(40), CAST(c."Item Code/Barcode"AS BIGINT)) as code,
        c."MB PO Number" as poNumber,
        CONVERT(CHAR(8),c."Estimated stock available date (ETA)" , 112) as deliveryDate,
        c."Qty" as openQuantity,
        c."order reference- EG- Oct 26 seasonal/NPD/July 26 Core" as poComment,
        c."Qty" as originalQuantity,
        '0' as suppliedQuantity,                
        c." Shipping Mode" as freeText1,
        '1' as orderTypeNumber,
        "Line #" as line,
        '0' as excludeSetting,
        c."Supplier Number" as supplierNumber,
        c."Supplier" as supplierName,
        CONVERT(CHAR(8),c."PO RAISED DATE", 112) as orderDate,
        CONVERT(CHAR(8),c."Original ex factory", 112) as requestDate
    FROM 
    ingest_POCurrent as c 
   LEFT JOIN vw_Warehouse as w
   ON w.location = c.Location

WHERE w.warehouse IS NOT NULL
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
        AND deliveryDate IS NULL -- Keep this for PurchaseOrders, deliveryDate IS NULL, keep the warehouse_to
                                 -- Historical_PO - Change deliveryDate filter to IS NOT NULL, keep warehouse_to
                                 -- Transactions - Change deliveryDate filter to IS NOT NULL, keep warehouse_from
),
COMBO_PO_TFR AS (
    SELECT 
        warehouse, code, poNumber, deliveryDate, openQuantity, poComment,originalQuantity,
        suppliedQuantity, freeText1, orderTypeNumber, 
        NULL as line , 
        '0' as excludeSetting, 
        NULL as supplierNumber, 
        supplierName, orderDate, requestDate
    FROM
    CLEANUP_TFR
    UNION ALL
    SELECT 
        warehouse, code, poNumber, deliveryDate, openQuantity, poComment,originalQuantity,
        suppliedQuantity, freeText1, orderTypeNumber, line , excludeSetting, supplierNumber, supplierName, orderDate, requestDate
    FROM 
    CurrentPO
    )

INSERT INTO S4Import_PurchaseOrder ( controlID, warehouse, code, poNumber, deliveryDate, openQuantity, poComment,originalQuantity,
suppliedQuantity, freeText1, orderTypeNumber, line , excludeSetting, supplierNumber, supplierName, orderDate, requestDate )
SELECT
    '1' as controlID, 
    po.warehouse, 
    po.code, 
    poNumber, 
    deliveryDate, 
    openQuantity, 
    poComment,
    originalQuantity,
    suppliedQuantity, 
    freeText1, 
    orderTypeNumber, 
    line, 
    excludeSetting,
    supplierNumber,
    supplierName, 
    orderDate, 
    requestDate
FROM 
    COMBO_PO_TFR as po
    JOIN dim_Date as dd 
        ON dd.DateKey = po.deliveryDate
    INNER JOIN vw_Last_XDays as xd 
        ON xd.DateKey = po.deliveryDate
    INNER JOIN S4Import_ArticleFilter as af
        ON af.code = po.code
        AND af.warehouse = po.warehouse
    WHERE dd.FullDate >= CURRENT_DATE
    AND openQuantity > 0


-- Setup queries below
/*
CREATE TABLE S4Import_PurchaseOrder  ( 
    controlID  INTEGER, warehouse  NVARCHAR(20), code  NVARCHAR(40), poNumber  NVARCHAR(100), 
    deliveryDate  CHAR(8), openQuantity  INTEGER, supplierDetails  NVARCHAR(100), poComment  NVARCHAR(4000), 
    originalQuantity  INTEGER, suppliedQuantity  INTEGER, freeText1  NVARCHAR(255), freeText2  NVARCHAR(255), 
    freeNumber1  FLOAT, freeNumber2  FLOAT, orderTypeNumber  INTEGER, line  INTEGER, excludeSetting  INTEGER, 
    excludeDate  CHAR(8), excludeFromAM  INTEGER, supplierNumber  NVARCHAR(60), supplierName  NVARCHAR(100), 
    activeDate  NVARCHAR(10), defaultContract  INTEGER, buyingPrice  FLOAT, orderDate  NVARCHAR(10), requestDate  NVARCHAR(10), 
    excludeFromPP  INTEGER, supplierArticleCode  NVARCHAR(25)
 )
 */