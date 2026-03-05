
-- Clear table before writing new data

TRUNCATE TABLE S4Import_PurchaseOrder ;

WITH CurrentPO AS (
select 
        w.warehouse as warehouse,
        CONVERT(NVARCHAR(40), CAST(c."Item Code/Barcode"AS BIGINT)) as code,
        c."MB PO Number" as poNumber,
        CONVERT(CHAR(8),c."Estimated stock available date (ETA)" , 112) as deliveryDate,
        c."Qty" as openQuantity,
        c."order reference- EG- Oct 26 seasonal/NPD/July 26 Core" as poComment,
        c."Qty" as originalQuantity,
        h."Qty" as suppliedQuantity, -- need to amend this with the HistoricalPO data by PO Number and ItemCode
        c." Shipping Mode" as freeText1,
        NULL as orderTypeNumber,
        NULL as line,
        c."Supplier" as supplierName,
        CONVERT(CHAR(8),c."PO RAISED DATE", 112) as orderDate,
        CONVERT(CHAR(8),c."Original ex factory", 112) as requestDate
    FROM 
    ingest_POCurrent as c 
    LEFT JOIN ingest_POHistory as h 
    ON c."Item Code/Barcode" = h."Item Code"
    AND c."MB PO Number" = h."MB PO Number"  -- need to identify the best combination to match this data
    AND c."Location" = h."Location"
   -- AND c." Shipping Mode" = h." Shipping Mode" -- not always the same for specific PO, need to identify
   LEFT JOIN vw_Warehouse as w
   ON w.location = c.Location

WHERE h."Qty" IS NOT NULL )
--AND c."MB PO Number" = 'PO-HAN130625AU1' )
INSERT INTO S4Import_PurchaseOrder ( controlID, warehouse, code, poNumber, deliveryDate, openQuantity, poComment,originalQuantity,
suppliedQuantity, freeText1, orderTypeNumber, line , supplierName, orderDate, requestDate )
SELECT
    '1' as controlID, 
    warehouse, 
    code, 
    poNumber, 
    deliveryDate, 
    openQuantity, 
    poComment,
    originalQuantity,
    suppliedQuantity, 
    freeText1, 
    orderTypeNumber, 
    line, 
    supplierName, 
    orderDate, 
    requestDate
FROM 
    CurrentPO 
     ;


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