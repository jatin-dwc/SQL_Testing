select *

FROM
    ingest_POCurrent

--CONVERT(CHAR(8), "Launch date EU", 112)  

    select 
       "Location" as warehouse,
        "Item Code/Barcode" as code,
        "MB PO Number" as poNumber,
        CONVERT(CHAR(8),"Estimated stock available date (ETA)" , 112) as deliveryDate,
        "Qty" as openQuantity,
        "order reference- EG- Oct 26 seasonal/NPD/July 26 Core" as poComment,
        "Qty" as originalQuantity,
        "Qty" as suppliedQuantity, -- need to amend this with the HistoricalPO data by PO Number and ItemCode
        "Shipping Mode" as freeText1,
        NULL as orderTypeNumber,
        NULL as "line",
        "Supplier" as supplierName,
        CONVERT(CHAR(8),"PO RAISED DATE", 112) as orderDate,
        CONVERT(CHAR(8),"Original ex factory", 112) as requestDate
    FROM 
    ingest_POCurrent