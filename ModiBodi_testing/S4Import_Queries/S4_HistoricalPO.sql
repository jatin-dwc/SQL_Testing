
-- Clear table before writing new data

TRUNCATE TABLE S4Import_Historical_PO ;

WITH HistoricalPO AS (
select 
        w.warehouse as warehouse,
        CONVERT(NVARCHAR(40), CAST(c."Item Code"AS BIGINT)) as code,
        c."MB PO Number" as poNumber,
        '3' as line,
        '1' as orderTypeNumber,         -- 1 = PO , 2 = Transfer Order -- Transfer orders in a separate file
        CONVERT(CHAR(8),"Good Received Date" , 112) as deliveredDate,
        Quantity as deliveredQuantity,
        Supplier as supplierDetails,
        CONVERT(CHAR(8),"PO RAISED DATE" , 112)  as orderedDate,
        CONVERT(CHAR(8),"Original ex fty" , 112)  as requestedDate,
        Qty as orderedQuantity,
        '3' as requestedQuantity,
        'Production to provide' as supplierNumber,
        Supplier as supplierName,
        " FOB" as buyingPrice
    FROM 
    ingest_POHistory as c 
    LEFT JOIN vw_location_warehouse as w
   ON w.location = c.Location )

INSERT INTO S4Import_Historical_PO ( controlID, warehouse, code, poNumber, line, orderTypeNumber, deliveredDate, 
deliveredQuantity, supplierDetails, orderedDate, requestedDate, orderedQuantity, requestedQuantity, supplierNumber, 
supplierName, buyingPrice )
    SELECT
        '1' as controlID, 
        warehouse, 
        code, 
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
        HistoricalPO
    WHERE warehouse IS NULL
        ;

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