select * from ingest_Transactions

EXEC SP_Columns ingest_Transactions;


TRUNCATE TABLE stg_Transactions;

INSERT INTO stg_Transactions (TransactionID, CustomerID, ProductID, QuantitySold, TransactionDate)
SELECT
    "Transaction ID" as TransactionID
    , "Customer ID" as CustomerID 
    , "Product ID" as ProductID 
    , "Quantity Sold" as QuantitySold 
    , CONVERT(CHAR(8), t.TransactionDate, 112) AS TransactionDate
FROM
    ingest_Transactions as t;

select * from stg_Transactions;




select 
    TransactionDate,
    TransactionID,
    t.ProductID,
    CASE 
        WHEN t.ProductID = 201 then p.Price
        WHEN t.ProductID = 202 then p.Price 
        ELSE p.Cost 
        END AS SalesPrice
from 
stg_Transactions as t 

INNER JOIN stg_Pricing_14Days as p  
    ON p.ProductID = t.ProductID AND p.EffectiveDate = t.TransactionDate

ALTER TABLE stg_Transactions
ALTER COLUMN TransactionDate CHAR(8);

CREATE TABLE stg_Transactions (
    TransactionID   NVARCHAR(100),
    CustomerID      NVARCHAR(100),
    ProductID       NVARCHAR(100),
    QuantitySold    INTEGER,
    TransactionDate DATE)  -- need to use TYPE CHAR(8)