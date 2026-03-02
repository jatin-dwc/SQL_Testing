select  *
FROM
    ingest_POCurrent

    select  *
FROM
    ingest_POCurrent
    WHERE "MB PO Number" = 'PO-HAN130625AU1'

select  *
FROM
    ingest_POHistory
    
WHERE "MB PO Number" = 'PO-HAN130625AU1'


--CONVERT(CHAR(8), "Launch date EU", 112)  

    select 
       c."Location Code" as warehouse,
        CONVERT(NVARCHAR(40), CAST(c."Item Code/Barcode"AS BIGINT)) as code,
        c."MB PO Number" as poNumber,
        CONVERT(CHAR(8),c."Estimated stock available date (ETA)" , 112) as deliveryDate,
        c."Qty" as openQuantity,
        c."order reference- EG- Oct 26 seasonal/NPD/July 26 Core" as poComment,
        c."Qty" as originalQuantity,
        h."Qty" as suppliedQuantity, -- need to amend this with the HistoricalPO data by PO Number and ItemCode
        c." Shipping Mode" as freeText1,
        NULL as orderTypeNumber,
        NULL as "line",
        c."Supplier" as supplierName,
        CONVERT(CHAR(8),c."PO RAISED DATE", 112) as orderDate,
        CONVERT(CHAR(8),c."Original ex factory", 112) as requestDate
    FROM 
    ingest_POCurrent as c 
    LEFT JOIN ingest_POHistory as h 
    ON c."Item Code/Barcode" = h."Item Code"
    AND c."MB PO Number" = h."MB PO Number"

WHERE h."Qty" IS NOT NULL
AND c."MB PO Number" = 'PO-HAN130625AU1'
     ;


    select 
       "Location Code" as warehouse,
        CONVERT(NVARCHAR(40), CAST("Item Code"AS BIGINT)) as code,
        "MB PO Number" as poNumber,
        CONVERT(CHAR(8),"Estimated stock available date" , 112) as deliveryDate,
        "Qty" as openQuantity,
        "order reference- EG- Oct 26 seasonal/NPD/July 26 Core" as poComment,
        "Qty" as originalQuantity,
        "Qty" as suppliedQuantity, -- need to amend this with the HistoricalPO data by PO Number and ItemCode
        " Shipping Mode" as freeText1,
        NULL as orderTypeNumber,
        NULL as "line",
        "Supplier" as supplierName,
        CONVERT(CHAR(8),"PO RAISED DATE", 112) as orderDate,
        CONVERT(CHAR(8),"Original ex fty", 112) as requestDate
    FROM 
    ingest_POHistory ;