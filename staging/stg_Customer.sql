
-- Pulls data from Ingested Excel table "ingest_Customer" and pushes to Staging table stg_Customers

-- Clear the staging table before loading
TRUNCATE TABLE stg_Customers;

-- Insert transformed data, keeping only one row per Customer ID
INSERT INTO stg_Customers (CustomerID, FirstName, LastName, Email, Age, Gender, Country, controlID)
SELECT 
    CustomerID,
    FirstName,
    LastName,
    Email,
    Age,
    Gender,
    Country,
    controlID
FROM (
    SELECT 
        c."Customer ID" AS CustomerID,
        SUBSTRING(c.CustomerName, 1, CHARINDEX(' ', c.CustomerName) - 1) AS FirstName,
        SUBSTRING(c.CustomerName, CHARINDEX(' ', c.CustomerName) + 1, LEN(c.CustomerName)) AS LastName,
        c.Email,
        c.Age,
        c.Gender,
        c.Country,
        '1' AS controlID,
        ROW_NUMBER() OVER (PARTITION BY c."Customer ID" ORDER BY c."Customer ID") AS rn -- this acts to count the rows for non unique values and returns a count value for each line, the WHERE rn = 1 limits the result to only a single value should the CUSTOMERID be Unique
    FROM
        ingest_Customer AS c
) AS deduped
WHERE rn = 1;



-- Code Testing Below

select 
    *
FROM
    stg_Customers ;


INSERT INTO stg_Customers (FirstName, LastName, Email, Age, Gender, Country, controlID)
VALUES ('Jane', 'Smith', 'jane@example.com', '32', 'Female', 'Australia', '1');


DROP TABLE if EXISTS stg_Customers ;

CREATE TABLE stg_Customers (
    CustomerID   NVARCHAR(100),
    FirstName    NVARCHAR(100),
    LastName     NVARCHAR(100),
    Email        NVARCHAR(200),
    Age          INTEGER,
    Gender       NVARCHAR(200),
    Country      NVARCHAR(200),
    controlID    INTEGER)
    ;

TRUNCATE TABLE stg_Customers ;

INSERT INTO stg_Customers (CustomerID, FirstName, LastName, Email, Age, Gender, Country, controlID)
SELECT 
    DISTINCT( c."Customer ID" ) as CustomerID
    , SUBSTRING(c.CustomerName, 1, CHARINDEX(' ', c.CustomerName) - 1) AS FirstName
    , SUBSTRING(c.CustomerName, CHARINDEX(' ', c.CustomerName) + 1, LEN(c.CustomerName)) AS LastName
    , c.Email
    , c.Age
    , c.Gender
    , c.Country
    , '1' as controlID
FROM
    ingest_Customer as c
ORDER BY c."Customer ID" ASC

select 
    *
FROM ingest_Customer ;

select 
    *
FROM
    stg_Customers ;