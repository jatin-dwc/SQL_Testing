select * from ingest_Transactions


TRUNCATE TABLE stg_Transactions;

INSERT INTO stg_Transactions (TransactionID, CustomerID, ProductID, QuantitySold, TransactionDate)
SELECT
    "Transaction ID" as TransactionID
    , "Customer ID" as CustomerID 
    , "Product ID" as ProductID 
    , "Quantity Sold" as QuantitySold 
    , CONVERT(CHAR(8), t.[Date], 112) as TransactionDate
FROM
    ingest_Transactions as t;


CREATE TABLE stg_Transactions (
    TransactionID   NVARCHAR(100),
    CustomerID      NVARCHAR(100),
    ProductID       NVARCHAR(100),
    QuantitySold    INTEGER,
    TransactionDate DATE)