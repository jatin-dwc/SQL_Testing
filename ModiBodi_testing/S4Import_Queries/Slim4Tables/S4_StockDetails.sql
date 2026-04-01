CREATE PROCEDURE load_S4LStockDetails
    AS
        BEGIN
-- Clear table before writing new data

TRUNCATE TABLE S4Import_StockDetails ;

-- Current Stock Details table creation

WITH 
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
/*AU_OTHER AS (
    SELECT
        'AU WS' as warehouse,
        CONVERT(NVARCHAR(40), CAST("ItemCode" AS BIGINT)) AS code,
        -- SOH,
        "Available Stock" as "AVS",
        "Allocated Current orders" as "ALS",
        "Allocated Back orders" as "BOS",
        "On Hold Qty" as "RQS"
    FROM 
        soh_au_other 
),
AU_PR AS (
    SELECT
        'AU PR' as warehouse,
        CONVERT(NVARCHAR(40), CAST("ItemCode" AS BIGINT)) AS code,
        -- SOH,
        "Available Stock" as "AVS",
        "Allocated Current orders" as "ALS",
        "Allocated Back orders" as "BOS",
        "On Hold Qty" as "RQS"
    FROM 
        soh_au_pr
), */
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
        '1' as controlID,
        warehouse,
        code,
        CONCAT( warehouse, code, su.stockTypeCode ) as stockID,
        st.StockType,
        CASE 
            WHEN su.stockTypeCode = 'AVS' AND stockType_setting = 'Quarantined' THEN 1
            WHEN su.stockTypeCode = 'AVS' THEN 0
            ELSE 1
            END AS excludeSetting,
        stockOnHand
    FROM
        SOH_UNPIVOT as su
    LEFT JOIN StockType as st
    ON st.StockTypeABB = su.stockTypeCode
)
    INSERT INTO S4Import_StockDetails (
        controlID, warehouse, code, stockID, stockType, excludeSetting, stockOnHand )
    SELECT
        controlID, warehouse, code, stockID, stockType, excludeSetting, stockOnHand
    FROM 
        SOH_FINAL   
    WHERE 
        code IS NOT NULL
    AND stockOnHand <> 0

;
END ;



---- Testing queries below


/*
CREATE TABLE S4Import_StockDetails (
    controlID  INTEGER, warehouse  NVARCHAR(20), code  NVARCHAR(40), stockOnHand  INTEGER, stockID  NVARCHAR(50), stockType  NVARCHAR(100), excludeSetting  INTEGER, 
    excludeTillDate  CHAR(8), excludeFromDate  CHAR(8), initialShelfLife  FLOAT, remainingShelfLife  FLOAT, uD1  NVARCHAR(255), 
    uD2  NVARCHAR(255), uD3  NVARCHAR(255), uD4  NVARCHAR(255), ExcludeFromAM  NVARCHAR(25)
)
 */