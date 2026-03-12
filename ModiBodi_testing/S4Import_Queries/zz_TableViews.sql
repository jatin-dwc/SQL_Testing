

-- Slim4 Import Tables

select * from S4Import_VariantGeneric
WHERE core <> 1 ;

select * from  S4Import_ArticleCodeMaster ;

select * from S4Import_Suppliers ;

select * from S4Import_Logistics ;

select * from S4Import_Transactions 
WHERE transactionName <> 'Line Item' ;

select * from S4Import_PurchaseOrder
-- ORDER BY poNumber ;

select * from S4Import_Historical_PO
WHERE warehouse IS NULL ;

-- Supporting Tables 

select * from vw_Warehouse ;

select * from vw_location_warehouse ;

select * from ingest_Customers ;

select * from vw_Last_XMonths ;

--  Ingestion tables testing

select *
FROM
    AMZ_Orders

select *
from 
ArticleTest7 ;

select 
DISTINCT( [Size])
from 
ArticleTest7 ;

select *,
    LEN(SizeCode) as length
 from ingest_SizeOrder ;

    select  
    *
    FROM
        ingest_POCurrent
 --   WHERE "Supplier's Inv# Number" IS NOT NULL
    WHERE "MB PO Number" = 'PO-HAN130625AU1' ;  -- PO-HAN130625AU1

    select  
    *
    FROM
        ingest_POHistory
    WHERE "Completed (DISCREPANCY)" IS NOT NULL
    AND "MB PO Number" = 'PO-JI150825AU' 
-- 'PO-HAN130625AU1'
-- AND "Location" = '3PLUK UK';

    select  
    "MB PO Number" as poNumber,
    Quantity,
    Qty,
    "Completed (DISCREPANCY)" as QtyMvmt 
    FROM
        ingest_POHistory                -- Need to confirm the Quantity columns with MB team
    WHERE "Completed (DISCREPANCY)" IS NOT NULL
    AND "MB PO Number" = 'PO-JI150825AU' 

-- Testing Queries below

select
    Combo,
    LEN(Combo) as length
from 
    ArticleTest7
WHERE LEN(Combo) <= 15
    ;


select * from ingest_POHistory ;

-- Location Quantity Checks to show which Locations exist in the Input for Hisorical POs but are not being mapped

WITH unique_location AS (
    select 
        h."Location",
        SUM(h.Qty) as units,
        ROW_NUMBER() OVER (PARTITION BY h."Location" ORDER BY h."Location") AS rn -- this acts to count the rows for non unique values and returns a count value for each line, the WHERE rn = 1 limits the result to only a single value should the CUSTOMERID be Unique
    FROM 
        ingest_POHistory as h
        GROUP BY h."location" ),
    unique_check AS (
    SELECT 
        ul.location as unique_location,
        lw.location as warehouse_location,
        lw.warehousename as warehouse_name,
        lw.warehouse as warehouse,
        SUM(units) as units_total
    FROM 
        unique_location as ul
    LEFT JOIN vw_location_warehouse as lw
    ON lw.location = ul.location
    WHERE ul.rn=1
    GROUP BY ul.location , lw.location, lw.warehousename, lw.warehouse )
    SELECT
    *
    from unique_check 
    -- where warehouse IS NOT NULL ;
    ORDER BY warehouse
    ;

    select *
    from 
    SHPFY_AU