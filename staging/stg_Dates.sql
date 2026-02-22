

-- Populate the table using a recursive CTE
DECLARE @StartDate DATE = '20200101';  -- change to your desired start date
DECLARE @EndDate   DATE = '20801231';  -- change to your desired end date

WITH DateExpansion AS (
    SELECT @StartDate AS DateValue
    UNION ALL
    SELECT DATEADD(DAY, 1, DateValue)
    FROM DateExpansion
    WHERE DateValue < @EndDate
)
INSERT INTO dbo.dim_Date (DateKey, FullDate, CalendarYear, ShortMonthName)
SELECT 
    CONVERT(CHAR(8), DateValue, 112)        AS DateKey,
    DateValue                               AS FullDate,
    YEAR(DateValue)                         AS CalendarYear,
    UPPER(FORMAT(DateValue, 'MMM'))         AS ShortMonthName
FROM DateExpansion
OPTION (MAXRECURSION 0);

select * from dim_Date;


-- Clear Dates table to adjust date range from 2030 to 2080
TRUNCATE TABLE dbo.dim_Date;


-- 14 DAYS
-- Select view for Last 14 Days
select *
FROM
vw_Last14Days
ORDER BY FullDate ;

-- Adjust View for Last 14 Days

ALTER VIEW vw_Last14Days AS
SELECT *
FROM dim_Date
WHERE DayOffset >= -14;


-- 12 MONTHS
-- Select view for Last 12 Months
select *
FROM
vw_Last12Months
ORDER BY FullDate ASC

-- Create View for Last 12 months

ALTER VIEW vw_Last12Months AS
SELECT *
FROM dim_Date
WHERE DayOffset >= -366;


-- 3 DAYS
-- Select view for Last 3 Days
select *
FROM
vw_Last3Days
ORDER BY FullDate ;

-- Adjust View for Last 3 Days

ALTER VIEW vw_Last3Days AS
SELECT *
FROM dim_Date
WHERE DayOffset BETWEEN -3 and 0;

-- Create View for Last 3 Days

CREATE VIEW vw_Last3Days AS
SELECT *
FROM dim_Date
WHERE DayOffset BETWEEN -3 and 0;









-- Create the table
CREATE TABLE dbo.dim_Date (
    DateKey         CHAR(8)     NOT NULL PRIMARY KEY,  -- YYYYMMDD
    FullDate        DATE        NOT NULL,
    DayOffset       AS DATEDIFF(DAY, CAST(GETDATE() AS DATE), FullDate),  -- computed, updates daily
    CalendarYear    INT         NOT NULL,
    ShortMonthName  CHAR(3)     NOT NULL
);