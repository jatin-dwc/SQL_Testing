
-- Clear table before writing new data

TRUNCATE TABLE S4Import_ArticleCodeMaster ;

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
    ROUND("Current USD RRP" ,2 ) as RRPUSD,
    CONVERT(CHAR(8), "Launch date AU-US-NZ", 112) as L_AUUSNZ,
    CONVERT(CHAR(8), "Launch date EU", 112) as L_EU,
    CONVERT(CHAR(8), "Launch date UK", 112) as L_UK
FROM 
    ArticleTest7                        --- REPLACE WITH SQL TABLE
WHERE "ACTIVE SKUS" = 'YES'
     ) ,

-- Combine Warehouse Table with all Records in Master Article codes to later assign Region specifc attributes

Art_WHS AS (
SELECT 
a1.*,
w.warehouse as warehouse
FROM 
Article_1 as a1
CROSS JOIN
vw_Warehouse as w
WHERE a1.rn=1 
AND a1.code IS NOT NULL) ,

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
        WHEN w.region = 'Europe' then L_EU 
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

INSERT INTO S4Import_ArticleCodeMaster ( controlID, warehouse, code,creationDate,description,salesPrice,criterium1,criterium2,
                                criterium3,criterium4,groupCode1,groupCode2,groupCode3,groupCode4,groupCode5,groupCode6,uD1,uD2,uD3)
SELECT
    '1' as controlID,
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



-- Setup queries below
/*
CREATE TABLE S4Import_ArticleCodeMaster (
    controlID  INTEGER, 
    warehouse  NVARCHAR(20), 
    code  NVARCHAR(40), 
    creationDate  CHAR(8), 
    description  NVARCHAR(100), 
    unitPrice  FLOAT, 
    salesPrice  FLOAT, 
    criterium1  FLOAT, 
    criterium2  FLOAT, 
    criterium3  FLOAT, 
    criterium4  FLOAT, 
    groupCode1  NVARCHAR(255), 
    groupCode2  NVARCHAR(255), 
    groupCode3  NVARCHAR(255), 
    groupCode4  NVARCHAR(255), 
    groupCode5  NVARCHAR(255), 
    groupCode6  NVARCHAR(255), 
    uD1  NVARCHAR(255), 
    uD2  NVARCHAR(255), 
    uD3  NVARCHAR(255), 
    uD4  NVARCHAR(255), 
    uD5  NVARCHAR(255), 
    uD6  NVARCHAR(255), 
    uD7  NVARCHAR(255), 
    uD8  NVARCHAR(255), 
    uD9  NVARCHAR(255), 
    uD10  NVARCHAR(255), 
    uD11  NVARCHAR(255), 
    uD12  NVARCHAR(255), 
    uD13  NVARCHAR(255), 
    uD14  NVARCHAR(255), 
    uD15  NVARCHAR(255), 
    aUDField1  NVARCHAR(255), 
    aUDField2  NVARCHAR(255), 
    aUDField3  NVARCHAR(255), 
    aUDField4  NVARCHAR(255), 
    aUDField5  NVARCHAR(255), 
    aUDField6  NVARCHAR(255), 
    aUDField7  NVARCHAR(255), 
    aUDField8  NVARCHAR(255), 
    aUDField9  NVARCHAR(255), 
    aUDField10  NVARCHAR(255), 
    aUDField11  NVARCHAR(255), 
    aUDField12  NVARCHAR(255), 
    aUDField13  NVARCHAR(255), 
    aUDField14  NVARCHAR(255), 
    aUDField15  NVARCHAR(255), 
    aUDField16  NVARCHAR(255), 
    aUDField17  NVARCHAR(255), 
    aUDField18  NVARCHAR(255), 
    aUDField19  NVARCHAR(255), 
    aUDField20  NVARCHAR(255), 
    aUDField21  NVARCHAR(255), 
    aUDField22  NVARCHAR(255), 
    aUDField23  NVARCHAR(255), 
    aUDField24  NVARCHAR(255), 
    aUDField25  NVARCHAR(255), 
    aUDField26  NVARCHAR(255), 
    aUDField27  NVARCHAR(255), 
    aUDField28  NVARCHAR(255), 
    aUDField29  NVARCHAR(255), 
    aUDField30  NVARCHAR(255), 
    aUDField31  NVARCHAR(255), 
    aUDField32  NVARCHAR(255), 
    aUDField33  NVARCHAR(255), 
    aUDField34  NVARCHAR(255), 
    aUDField35  NVARCHAR(255), 
    aUDField36  NVARCHAR(255), 
    aUDField37  NVARCHAR(255), 
    aUDField38  NVARCHAR(255), 
    aUDField39  NVARCHAR(255),
    aUDField40  NVARCHAR(255), 
    aUDField41  NVARCHAR(255), 
    aUDField42  NVARCHAR(255), 
    aUDField43  NVARCHAR(255), 
    aUDField44  NVARCHAR(255), 
    aUDField45  NVARCHAR(255), 
    aUDField46  NVARCHAR(255), 
    aUDField47  NVARCHAR(255), 
    aUDField48  NVARCHAR(255), 
    aUDField49  NVARCHAR(255), 
    aUDField50  NVARCHAR(255), 
    aUDField51  NVARCHAR(255), 
    aUDField52  NVARCHAR(255), 
    aUDField53  NVARCHAR(255), 
    aUDField54  NVARCHAR(255), 
    aUDField55  NVARCHAR(255), 
    aUDField56  NVARCHAR(255), 
    aUDField57  NVARCHAR(255), 
    aUDField58  NVARCHAR(255), 
    aUDField59  NVARCHAR(255), 
    aUDField60  NVARCHAR(255), 
    aUDField61  NVARCHAR(255), 
    aUDField62  NVARCHAR(255), 
    aUDField63  NVARCHAR(255), 
    aUDField64  NVARCHAR(255), 
    aUDField65  NVARCHAR(255), 
    aUDField66  NVARCHAR(255), 
    aUDField67  NVARCHAR(255), 
    aUDField68  NVARCHAR(255), 
    aUDField69  NVARCHAR(255), 
    aUDField70  NVARCHAR(255), 
    aUDField71  NVARCHAR(255), 
    aUDField72  NVARCHAR(255), 
    aUDField73  NVARCHAR(255), 
    aUDField74  NVARCHAR(255), 
    aUDField75  NVARCHAR(255), 
    aUDField76  NVARCHAR(255), 
    aUDField77  NVARCHAR(255), 
    aUDField78  NVARCHAR(255), 
    aUDField79  NVARCHAR(255), 
    aUDField80  NVARCHAR(255), 
    aUDField81  NVARCHAR(255), 
    aUDField82  NVARCHAR(255), 
    aUDField83  NVARCHAR(255), 
    aUDField84  NVARCHAR(255), 
    aUDField85  NVARCHAR(255), 
    aUDField86  NVARCHAR(255), 
    aUDField87  NVARCHAR(255), 
    aUDField88  NVARCHAR(255), 
    aUDField89  NVARCHAR(255), 
    aUDField90  NVARCHAR(255), 
    aUDField91  NVARCHAR(255), 
    aUDField92  NVARCHAR(255), 
    aUDField93  NVARCHAR(255), 
    aUDField94  NVARCHAR(255), 
    aUDField95  NVARCHAR(255), 
    aUDField96  NVARCHAR(255), 
    aUDField97  NVARCHAR(255), 
    aUDField98  NVARCHAR(255), 
    aUDField99  NVARCHAR(255), 
    aUDField100  NVARCHAR(255), 
    articleStatus  NVARCHAR(100), 
    barCode  NVARCHAR(20), 
    fefoPercentage  FLOAT, 
    criterium5  FLOAT, 
    criterium6  FLOAT, 
    criterium7  FLOAT, 
    criterium8  FLOAT )