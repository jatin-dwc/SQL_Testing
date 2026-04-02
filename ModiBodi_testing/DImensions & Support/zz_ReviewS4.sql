
SELECT * from S4Import_ArticleFilter
WHERE 1=1
-- AND   ;

SELECT * from S4Import_ArticleCodeMaster as s4
INNER JOIN S4Import_ArticleFilter as af
ON s4.code = af.code
AND s4.warehouse = af.warehouse
WHERE 1=1
-- AND   ;

SELECT  * from S4Import_VariantGeneric
WHERE 1=1
-- AND   ;

SELECT  * from S4Import_Transactions as s4
INNER JOIN S4Import_ArticleFilter as af
ON s4.code = af.code
AND s4.warehouse = af.warehouse
WHERE 1=1
-- AND   ;

SELECT * from S4Import_StockDetails as s4
INNER JOIN S4Import_ArticleFilter as af
ON s4.code = af.code
AND s4.warehouse = af.warehouse
WHERE 1=1
-- AND   ;

SELECT  * from S4Import_PurchaseOrder as s4
INNER JOIN S4Import_ArticleFilter as af
ON s4.code = af.code
AND s4.warehouse = af.warehouse
WHERE 1=1
-- AND   ;

SELECT  * from S4Import_Logistics as s4
INNER JOIN S4Import_ArticleFilter as af
ON s4.code = af.code
AND s4.warehouse = af.warehouse
WHERE 1=1
-- AND   ;

SELECT * from S4Import_Historical_PO as s4
LEFT JOIN S4Import_ArticleFilter as af
ON s4.code = af.code
AND s4.warehouse = af.warehouse
WHERE 1=1
AND af.code IS NULL
--AND supplierNumber IS NULL
AND orderTypeNumber = 1 ;

SELECT * from S4Import_Suppliers as s4
INNER JOIN S4Import_ArticleFilter as af
ON s4.code = af.code
AND s4.warehouse = af.warehouse
WHERE 1=1
-- AND   ;

SELECT 
    
from 
    S4Import_StockDetails 

    SELECT * from S4Import_Historical_PO
    ORDER BY deliveredDate DESC