
-- VIEWS
-- Create Supporting Warehouse Table to derive filters for included warehouses, assign pricing and other region specific attributes

CREATE VIEW vw_Warehouse AS
select
    "WarehouseCode" as warehouse,
    "WarehouseLocation" as "location",
    Currency as currency,
    Region as region,
    "Slim4Inscope" as scope       -- Column name may not be the same
FROM 
ingest_Warehouse                -- Replace this with scheduled table that gets imported
WHERE "Slim4Inscope" = 'Y' ;



CREATE VIEW vw_Location_Warehouse AS 
SELECT
    "Location" as location,
    "WarehouseLocation" as warehousename,
    code as warehouse
FROM
    ingest_WHS_location
    ;


CREATE VIEW vw_Customers AS 
SELECT
    "CustomerNumber",
    "CustomerName",
    "CustomerType",
    "WarehouseCode",
    "Slim4Inscope"
FROM
    ingest_Customers
WHERE "Slim4Inscope" = 'Y'
    ;

select * from vw_Customers



ALTER VIEW vw_Location_Warehouse AS 
SELECT
    "Location" as location,
    "WarehouseLocation" as warehousename,
    code as warehouse
FROM
    ingest_WHS_location
WHERE code IS NOT NULL;


select * from vw_Location_Warehouse


/*

DROP TABLE ingest_Warehouse
select * from  vw_Warehouse
*/