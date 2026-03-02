select * from dim_Date ;

select * from vw_Last_XDays;
select * from vw_Last_XMonths;

--Update XDays View

ALTER VIEW vw_Last_XDays AS     --  vw_Last_XDays ; vw_Last_XMonths
SELECT *
FROM dim_Date
WHERE DayOffset BETWEEN -3 and 0; -- Interchange between - 3 days (BETWEEN -3 and 0); 12 months (DayOffset >= -366); 24 months (DayOffset >= -723)

-- Create View for Last X Days

CREATE VIEW vw_Last_XMonths AS  --  vw_Last_XDays ; vw_Last_XMonths 
SELECT *
FROM dim_Date
WHERE DayOffset >= -366;




-- RUN BELOW QUERIES ONCE TO SETUP else use "TRUNCATE TABLE dbo.dim_Date;" to clear and reset

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



-- Create the table
CREATE TABLE dbo.dim_Date (
    DateKey         CHAR(8)     NOT NULL PRIMARY KEY,  -- YYYYMMDD
    FullDate        DATE        NOT NULL,
    DayOffset       AS DATEDIFF(DAY, CAST(GETDATE() AS DATE), FullDate),  -- computed, updates daily
    CalendarYear    INT         NOT NULL,
    ShortMonthName  CHAR(3)     NOT NULL
);