CREATE PROCEDURE load_S4Tables
    AS
    BEGIN
        EXEC load_S4ArticleFilter ;
        EXEC load_S4ArticleCodeMaster ;
        EXEC load_S4VariantGeneric ;
        EXEC load_S4Transactions ;
        EXEC load_S4Suppliers ;
        EXEC load_S4StockDetails ;
        EXEC load_S4PurchaseOrders ;
        EXEC load_S4HistoricalPO ;
        EXEC load_S4Logistics ;


END ;