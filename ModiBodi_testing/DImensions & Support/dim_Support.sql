
-- VIEWS
-- Create Supporting Warehouse Table to derive filters for included warehouses, assign pricing and other region specific attributes

CREATE VIEW vw_Warehouse AS
select
    "WarehouseCode" as warehouse,
    "WarehouseGrouping" as whsgroup,
    Currency as currency,
    Region as region,
    "Slim4Inscope" as scope       -- Column name may not be the same
FROM 
ingest_Warehouse                -- Replace this with scheduled table that gets imported
WHERE "Slim4Inscope" = 'Y'


DROP TABLE ingest_Warehouse
select * from  vw_Warehouse