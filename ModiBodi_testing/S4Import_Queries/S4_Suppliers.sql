
-- Clear table before writing new data

TRUNCATE TABLE S4Import_Suppliers ;

WITH 
    whs AS (
        select 
            vww.warehouse,
            vww.region
        from 
            vw_Warehouse as vww
    ),
    stg_masterSupplier AS (
        SELECT
            "Supplier Name",
            "Supplier Number",
            Australia,
            Europe,
            UK
        FROM 
            Master_Supplier
    ),
    sup_leadTime AS (
        select
            "Supplier Number" as supplierNumber_slt,
            sRegion,
            sleadTime       -- Add Shipping Lead Time per Supplier
        FROM
            stg_masterSupplier as sms
        UNPIVOT (sleadTime FOR sRegion IN ( Australia, Europe, UK)) as unpvt
    ),
    whs_sup_leadTime AS (
        SELECT
            slt.supplierNumber_slt,
            w.warehouse as supwhs,
            sleadTime
        FROM
            sup_leadTime as slt
        JOIN whs as w 
        ON w.region = slt.sRegion
    ),
    stg_suppliers AS (
        SELECT
            CONVERT(NVARCHAR(40), CAST("Item Code" AS BIGINT)) as code,
            "Primary Supplier" as pSupplier,
            "Secondary Supplier" as sSupplier,
            CASE 
                WHEN FOB IS NULL THEN 0
                ELSE FOB
            END AS FOB_,
            MOQ,
            "Lead Time (days)" as bleadTime
        FROM
            Suppliers
    ),
    primary_Suppliers AS (
        SELECT
            code,
            sp.pSupplier as supplierNumber,
            '1' as primarySupplier,
            FOB_ as buyingPrice,
            MOQ as minimumOrderQuantity,
            bleadTime
        FROM
            stg_suppliers as sp
        WHERE pSupplier IS NOT NULL
    ),
    secondary_Suppliers AS (
        SELECT
            code,
            sss.sSupplier as supplierNumber,
            '0' as primarySupplier,
            FOB_ as buyingPrice,
            MOQ as minimumOrderQuantity,
            bleadTime
        FROM
            stg_suppliers as sss
        WHERE sSupplier IS NOT NULL
    ),
    join_Suppliers AS (
        SELECT
            code, supplierNumber, primS.primarySupplier, buyingPrice, minimumOrderQuantity, bleadTime
        FROM
            primary_Suppliers as primS
        UNION ALL 
        SELECT
            code, supplierNumber, secS.primarySupplier, buyingPrice, minimumOrderQuantity, bleadTime
        FROM
            secondary_Suppliers as secS
    ),
    final_Suppliers AS (        
        SELECT
            '1' as controlID,
            wsl.supwhs as warehouse,
            js.code,
            js.supplierNumber,
            sts."Supplier Name" as supplierName,
            js.primarySupplier,
            js.bleadTime + wsl.sleadTime as leadTime,
            NULL as reviewTime,
            js.buyingPrice,
            'USD' as currencyCode,
            js.minimumOrderQuantity,
            NULL as incrementelOrderQuantity
        FROM
            join_Suppliers as js 
        JOIN
            whs_sup_leadTime as wsl 
        ON wsl.supplierNumber_slt = js.supplierNumber
        JOIN 
            stg_masterSupplier as sts
        ON sts."Supplier Number" = wsl.supplierNumber_slt
    )
   INSERT INTO S4Import_Suppliers ( controlID, warehouse, code, supplierNumber, supplierName, primarySupplier , 
    leadTime, reviewTime, buyingPrice, currencyCode, minimumOrderQuantity, incrementelOrderQuantity )
        SELECT
            s.controlID, s.warehouse, s.code, supplierNumber, supplierName, primarySupplier , 
            leadTime, reviewTime, buyingPrice, currencyCode, minimumOrderQuantity, incrementelOrderQuantity
        FROM
            final_Suppliers as s 
        INNER JOIN S4Import_ArticleFilter as af
            ON af.code = s.code
            AND af.warehouse = s.warehouse


-- Setup queries below
/*
CREATE TABLE S4Import_Suppliers (

controlID  INTEGER, 
warehouse  NVARCHAR(20), 
code  NVARCHAR(40), 
supplierNumber  NVARCHAR(60), 
supplierName  NVARCHAR(100), 
primarySupplier  INTEGER, 
preference  INTEGER, 
leadTime  FLOAT, 
reviewTime  FLOAT, 
buyingPrice  FLOAT, 
currencyCode  NVARCHAR(3), 
minimumOrderQuantity  INTEGER, 
incrementelOrderQuantity  INTEGER, 
economicOrderQuantity  INTEGER, 
supplierReliability  FLOAT, 
supplierReliabilitySetting  INTEGER, 
supplierArticleCode  NVARCHAR(65), 
availableInventory  INTEGER, 
desiredSplit  FLOAT, 
suppliedQuantity  INTEGER, 
orderFromDate  CHAR(8), 
orderToDate  CHAR(8), 
logisticUnit1  INTEGER, 
logisticUnit2  INTEGER, 
logisticUnit3  INTEGER, 
logisticUnit4  INTEGER, 
logisticUnit5  INTEGER, 
logisticUnit6  INTEGER, 
uD1  NVARCHAR(255), 
uD2  NVARCHAR(255), 
uD3  NVARCHAR(255), 
uD4  NVARCHAR(255), 
uD5  NVARCHAR(255), 
replenishmentScheduleId  NVARCHAR(60), 
inboundGuaranteedShelfLife  FLOAT, 
outboundGuaranteedShelfLife  FLOAT, 
netShelfLife  FLOAT, 
nonStocked  NVARCHAR(25), 
totalInventory  NVARCHAR(25), 
uDNum1  NVARCHAR(25), 
uDNum2  NVARCHAR(25), 
uDNum3  NVARCHAR(25), 
uDNum4  NVARCHAR(25), 
uDNum5  NVARCHAR(25) ) */