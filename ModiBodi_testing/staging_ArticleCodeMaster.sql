
-- Clear table before writing new data

TRUNCATE TABLE stg_ArticleCodeMaster_TestOnly ;

WITH Article_1 AS (
SELECT 
    CONVERT(NVARCHAR(40), CAST("Item Code" AS BIGINT)) AS code,
    CONVERT(CHAR(8), "SKU created/updated", 112) as creationDate,
    Description as description,
    '1' as criterium1,
    NULL  as criterium2,
    NULL  as criterium3,
    NULL  as criterium4,
    "PRODUCT FAMILY" as groupCode1,
    "Product Class" as groupCode2,
    "PRODUCT LINE" as groupCode3,
    "ABSORBENCY" as groupCode4,
    Colour as groupCode6,
    Size as uD1,
    "Customer name" as uD2,
    "ACTIVE SKUS" as uD3,
    ROW_NUMBER() OVER (PARTITION BY "Item Code" ORDER BY "Item Code") AS rn, -- this acts to count the rows for non unique values and returns a count value for each line, the WHERE rn = 1 limits the result to only a single value should the CUSTOMERID be Unique
    ROUND("Current RRP AUD",2 ) as RRPAUD,
    ROUND("Current RRP EUR",2 ) as RRPEUR,
    ROUND("Current RRP GBP",2 ) as RRPGBP,
    ROUND("Current RRP NZD",2 ) as RRPNZD,
    ROUND("ONLINE USD RRP" ,2 ) as RRPUSD,
    CONVERT(CHAR(8), "Launch date AU-US-NZ", 112) as L_AUUSNZ,
    CONVERT(CHAR(8), "Launch date EU", 112) as L_EU,
    CONVERT(CHAR(8), "Launch date UK", 112) as L_UK
FROM 
    ArticleTest4 ) ,

-- Combine Warehouse Table with all Records in Master Article codes to later assign Region specifc attributes

Art_WHS AS (
SELECT 
a1.*,
w.warehouse as warehouse
FROM 
Article_1 as a1
CROSS JOIN
vw_Warehouse as w
WHERE a1.rn=1 ) ,

Art_WHS_Price AS (
SELECT 
    aw.*,
    CASE 
        WHEN w.Currency = 'AUD' then RRPAUD
        WHEN w.Currency = 'GBP' then RRPGBP
        WHEN w.Currency = 'USD' then RRPUSD
        WHEN w.Currency = 'NZD' then RRPNZD
        WHEN w.Currency = 'EUR' then RRPEUR
    ELSE RRPAUD
    END AS salesPrice,
    CASE
        WHEN w.region IN ('Australia' , 'USA', 'NZ') then L_AUUSNZ
        WHEN w.region = 'UK' then L_UK
        WHEN w.region = 'EU' then L_EU 
    ELSE L_AUUSNZ
    END AS groupCode5
FROM 
    Art_WHS AS aw 
INNER JOIN vw_Warehouse as w 
ON aw.warehouse = w.warehouse

)



-- Update ArticleCodeMaster Table
-- Need to amend this code further to include the correct sales price base on the Country - this can be done in the step above and combining a link
-- Also need to keep in mind that this table will need to be filtered to adhere to the ArticleFilter requirements
-- Need to add a date table to start with the ArticleFitler process.

INSERT INTO stg_ArticleCodeMaster_TestOnly ( warehouse, code,creationDate,description,salesPrice,criterium1,criterium2,
                                criterium3,criterium4,groupCode1,groupCode2,groupCode3,groupCode4,groupCode5,groupCode6,uD1,uD2,uD3)
SELECT
    warehouse,
    code,
    creationDate,
    description,
    salesPrice,
    criterium1,
    criterium2,
    criterium3,
    criterium4,
    groupCode1,
    groupCode2,
    groupCode3,
    groupCode4,
    groupCode5,
    groupCode6,
    uD1,
    uD2,
    uD3
FROM
    Art_WHS_Price ;






-- Testing code below ONLY









DROP TABLE stg_ArticleCodes_1

UPDATE ingest_Warehouse
SET Country = 'UK'
WHERE Country = 'United Kingdom'

UPDATE ingest_Warehouse
SET "Slim4 Inscope?" = 'N'
WHERE Country = 'Japan';


select * from ingest_Warehouse

select *
FROM ArticleTest2;

SELECT * FROM ArticleTest1
UNION ALL
SELECT * FROM ArticleTest2

SELECT * FROM ArticleTest4

TRUNCATE TABLE ArticleTest2;


INSERT INTO ArticleTest2 ( "Product Class", "Description", "Item Code", "Colour", "Size", "Current RRP AUD", "Current RRP GBP", "Current RRP EUR", "Current RRP NZD", "Launch date AU-US-NZ", "Launch date UK", "Launch date EU", "SKU created/updated", "PRODUCT FAMILY", "PRODUCT LINE", "ABSORBENCY", "Customer name", "ACTIVE SKUS", "ONLINE USD RRP" )
SELECT 
"Product Class" as "Product Class", 
"Description" as"Description" ,
CONVERT(NVARCHAR(50), CAST("Item Code" AS BIGINT)) AS "Item Code",
 "Colour" as  "Colour",
  "Size" as "Size", 
  "Current RRP AUD" as "Current RRP AUD",
   "Current RRP GBP" as "Current RRP GBP",
    "Current RRP EUR" as "Current RRP EUR",
     "Current RRP NZD" as "Current RRP NZD",
      "Launch date AU-US-NZ" as "Launch date AU-US-NZ", 
      "Launch date UK" as  "Launch date UK",
       "Launch date EU" as  "Launch date EU",
        "SKU created/updated" as  "SKU created/updated",
         "PRODUCT FAMILY" as  "PRODUCT FAMILY",
          "PRODUCT LINE" as "PRODUCT LINE",
           "ABSORBENCY" as"ABSORBENCY",
            "Customer name" as  "Customer name", 
            "ACTIVE SKUS" as  "ACTIVE SKUS",
             "ONLINE USD RRP" as  "ONLINE USD RRP"


from ArticleTest1





CREATE TABLE stg_ArticleCodes_1 (
    code            NVARCHAR(40),
    creationDate    CHAR(8),
    description     NVARCHAR(100),
    criterium1      INTEGER,       -- Innerbox etc.
    criterium2      INTEGER,       -- TBC
    criterium3      INTEGER,       -- TBC
    criterium4      INTEGER,       -- TBC
    groupCode1      NVARCHAR(255), -- ProductFamily
    groupCode2      NVARCHAR(255), -- ProductClass, used for Stocked/Non-Stocked - Core = Y, else N
    groupCode3      NVARCHAR(255), -- ProductLine
    groupCode4      NVARCHAR(255), -- Absobency
    groupCode5      NVARCHAR(255), -- Launch Date
    groupCode6      NVARCHAR(255), -- Colour
    uD1             NVARCHAR(255), -- Size
    uD2             NVARCHAR(255), -- CustomerName
    uD3             NVARCHAR(255) -- ArticleStatus
);



SELECT * from stg_ArticleCodes_1


ALTER TABLE stg_ArticleCodes_1
DROP COLUMN groupCode5

ALTER TABLE stg_ArticleCodes_1
ALTER COLUMN code NVARCHAR(40)

ALTER TABLE ArticleTest2
ALTER COLUMN "Item Code" NVARCHAR (40)

ALTER TABLE stg_ArticleCodeMaster_TESTONLY
ALTER COLUMN salesPrice FLOAT

-- Create Test for ArticleCodeMaster

ALTER TABLE stg_ArticleCodeMaster_TESTONLY
ADD  groupCode5 NVARCHAR(255)

ALTER TABLE stg_ArticleCodeMaster_TESTONLY
ADD  salesPrice INTEGER


CREATE TABLE stg_ArticleCodeMaster_TESTONLY (
    warehouse       NVARCHAR(20),
    code            NVARCHAR(40),
    creationDate    CHAR(8),
    description     NVARCHAR(100),
    criterium1      INTEGER,       -- Innerbox etc.
    criterium2      INTEGER,       -- TBC
    criterium3      INTEGER,       -- TBC  
    criterium4      INTEGER,       -- TBC
    groupCode1      NVARCHAR(255), -- ProductFamily
    groupCode2      NVARCHAR(255), -- ProductClass
    groupCode3      NVARCHAR(255), -- ProductLine
    groupCode4      NVARCHAR(255), -- Absobency
    groupCode5      NVARCHAR(255), -- Launch Date
    groupCode6      NVARCHAR(255), -- Colour
    uD1             NVARCHAR(255), -- Size
    uD2             NVARCHAR(255), -- CustomerName
    uD3             NVARCHAR(255) -- ArticleStatus
);