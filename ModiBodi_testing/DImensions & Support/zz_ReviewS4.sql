
SELECT TOP 100 * from S4Import_ArticleFilter  ;

SELECT TOP 100 * from S4Import_ArticleCodeMaster  ;

SELECT TOP 100 * from S4Import_VariantGeneric ;

SELECT TOP 100 * from S4Import_Transactions  ;

SELECT TOP 100 * from S4Import_StockDetails  ;

SELECT TOP 100 * from S4Import_PurchaseOrder  ;

SELECT TOP 100 * from S4Import_Logistics ;

SELECT TOP 100 * from S4Import_Historical_PO
WHERE 1=1
--AND supplierNumber IS NULL
AND orderTypeNumber = 1 ;

SELECT TOP 100 * from S4Import_Suppliers ;
