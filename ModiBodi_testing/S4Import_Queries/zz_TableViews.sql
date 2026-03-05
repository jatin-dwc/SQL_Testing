

select * from S4Import_VariantGeneric ;

select * from  S4Import_ArticleCodeMaster ;

select * from S4Import_Suppliers ;

select * from S4Import_Logistics ;

select * from S4Import_PurchaseOrder
-- ORDER BY poNumber ;

select * from vw_Warehouse ;

select * from vw_location_warehouse ;

select * from S4Import_Historical_PO
WHERE warehouse IS NULL ;

-- Testing Queries below

select * from ingest_POHistory ;

-- Location Quantity Checks

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
        lw.warehouse as warehouse,
        SUM(units) as units_total
    FROM 
        unique_location as ul
    LEFT JOIN vw_location_warehouse as lw
    ON lw.location = ul.location
    WHERE ul.rn=1
    GROUP BY ul.location , lw.location, lw.warehouse )
    SELECT
    *
    from unique_check
    where warehouse IS NOT NULL ;