   -- AU Transfers
WITH transfers_au AS (
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
)
SELECT * from CLEANUP_TFR
WHERE warehouse IS NOT NULL