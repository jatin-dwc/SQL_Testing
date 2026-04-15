

select * from ingest_Products


-- Use this logic to build out the base for the Article Filter table
select 
    c.CustomerID,
    p."Product ID"
FROM 
    stg_Customers as c    

    CROSS JOIN ingest_Products as p   -- CROSS JOIN combines all rows from each
    INNER JOIN vw_ProdFilter as pf      -- create a view or views that drive the filters for each criteria
    on p."Product ID" = pf."Product ID";        -- 


    ALTER VIEW vw_ProdFilter AS
    SELECT * 
    FROM
    ingest_Products
    WHERE Brand = 'Samsung';



    CREATE VIEW vw_ProdFilter AS
    SELECT * 
    FROM
    ingest_Products
    WHERE Brand = 'Apple';

