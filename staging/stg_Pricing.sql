
-- Clear table of all data

TRUNCATE TABLE stg_Pricing_14Days ;

-- Construct table using rolling 14 day filter

    WITH DateExpansion AS (
    SELECT 
        p."Product ID"                  as ProductID,  -- include your other pricing columns here
        ROUND(p."Selling Price", 4)     as Price,
        ROUND(p."Cost Price", 4)        as Cost,
        CONVERT(CHAR(8), p.[From], 112) as StartDate,
        CONVERT(CHAR(8), p.[To], 112)   as EndDate,
        p.[From]                        as CurrentDate,
        p.[To]                          as ToDate
    FROM ingest_Pricing AS p

    UNION ALL

    SELECT 
        ProductID,
        Price,
        Cost,
        StartDate,
        EndDate,
        DATEADD(DAY, 1, CurrentDate),
        ToDate
    FROM DateExpansion
    WHERE CurrentDate < ToDate
),
CalcPricing as (
SELECT 
    ProductID,
    Price,
    Cost,
    CONVERT(CHAR(8), CurrentDate, 112) AS EffectiveDate
FROM DateExpansion as de
INNER JOIN vw_Last14Days as d                                   -- Alter this view when toggling for various time periods
ON d.DateKey = CONVERT(CHAR(8), de.CurrentDate, 112)
WHERE CurrentDate IS NOT NULL)

INSERT INTO stg_Pricing_14Days (ProductID, Price, Cost, EffectiveDate, controlID)
SELECT
    ProductID,
    Price,
    Cost,
    EffectiveDate,
    '1' as controlID
FROM
    CalcPricing
OPTION (MAXRECURSION 0);


-- Code Testing below


SELECT * from stg_Pricing_14Days;

-- Temp code - used to create the required Table
CREATE TABLE stg_Pricing_14Days (
    ProductID   NVARCHAR(100),
    Price       INTEGER,
    Cost        INTEGER,
    EffectiveDate    DATE)
    ;

-- Add column/s to exiting table

ALTER TABLE stg_Pricing_14Days
ADD controlID   INTEGER;
