
CREATE PROCEDURE load_S4Logistics
    AS
        BEGIN

-- Clear table before writing new data

TRUNCATE TABLE S4Import_Logistics;

WITH Article_base AS (
        select
            CONVERT(NVARCHAR(40), CAST("Item Code" AS BIGINT))                  AS code,
            "Product Class"                                                     as productClass,              
            ROW_NUMBER() OVER (PARTITION BY "Item Code" ORDER BY "Item Code")   AS rn
        FROM
            ArticleTest7                        --- REPLACE WITH SQL TABLE
            WHERE "ACTIVE SKUS" = 'YES' ),
Article_Warehouse AS (
select 
    ab.code,
    CASE 
        WHEN productClass = 'Core' then 'Y'
        ELSE 'N'
        END AS stockedItem,
    w.warehouse
FROM
    Article_base as ab
CROSS JOIN vw_Warehouse as w 
WHERE ab.rn=1 
AND ab.code IS NOT NULL )
INSERT INTO S4Import_Logistics (controlID, warehouse, code, stockedItem)
SELECT 
    '1' as controlID,
    aw.warehouse,
    aw.code,
    stockedItem
FROM 
    Article_Warehouse as aw
INNER JOIN S4Import_ArticleFilter as af 
    ON af.code = aw.code
    AND af.warehouse = aw.warehouse
    ;
END

-- Setup queries below

-- Only use if errors arise -- DROP TABLE S4Import_Logistics;

/* Run Once 
CREATE TABLE S4Import_Logistics(
controlID INTEGER,
warehouse NVARCHAR(20),
code NVARCHAR(40),
supplierNumber NVARCHAR(60),
supplierName NVARCHAR(100),
leadTime FLOAT,
reviewTime FLOAT,
supplierReliability FLOAT,
supplierReliabilitySetting INTEGER,
stockedItem NVARCHAR(1),
minimumOrderQuantity INTEGER,
incrementelOrderQuantity INTEGER,
economicOrderQuantity INTEGER,
logisticUnit1 INTEGER,
logisticUnit2 INTEGER,
logisticUnit3 INTEGER,
logisticUnit4 INTEGER,
logisticUnit5 INTEGER,
logisticUnit6 INTEGER,
insuranceInventory INTEGER,
insuranceInventoryType INTEGER,
targetServiceLevel FLOAT,
plcArticleCode NVARCHAR(85),
plcDate CHAR(8),
plcPerc FLOAT,
abcClass NVARCHAR(2),
buyingPrice FLOAT,
MSQ INTEGER,
ISQ INTEGER,
coverDate CHAR(8),
coverSetting INTEGER,
coverTime FLOAT,
supplierArticleCode NVARCHAR(65),
replenishmentScheduleId NVARCHAR(60),
inboundGuaranteedShelfLife FLOAT,
outboundGuaranteedShelfLife FLOAT,
netShelfLife FLOAT,
productionResource NVARCHAR(65),
productionResourceName NVARCHAR(100),
returnWarehouse NVARCHAR(25)); 
*/