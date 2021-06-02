    public with sharing class cmpHelperClass {
    public static boolean output = false;

        @AuraEnabled(cacheable=true)
        public static List<PricebookEntry> getProductsByOrderId(String orderId) {

            Order ord = [SELECT Id, Pricebook2Id FROM Order WHERE Id=:orderId];
            return [SELECT Id, Name, Product2Id, UnitPrice FROM PricebookEntry 
                    WHERE Pricebook2Id =: ord.Pricebook2Id AND IsActive = true];
        }
    
        @AuraEnabled
        public static Boolean checkExistenceProduct(String priceBookId) {
        
            List<OrderItem> ord = [SELECT Id FROM OrderItem WHERE PricebookEntryId=:priceBookId];
            
            if (ord.size() > 0) {
                output = true;
            }
            return output;
        }

        @AuraEnabled
        public static boolean updateOrderitem(String orderId, String product2Id) {
            OrderItem itemInOrder = [SELECT Id, Quantity FROM OrderItem WHERE OrderId =:orderId AND Product2Id =:product2Id];
            itemInOrder.Quantity += 1;
            
            try {
                upsert itemInOrder;
                system.debug(itemInOrder);
                output = true;
                return output;
            }
            catch (Exception e) {
                system.debug(e.getMessage());
            }
            return output;
        }   

        @AuraEnabled
        public static boolean insertOrderItem(String orderId, Decimal unitprice,String pricebookEntryId, String product2Id ) {
            OrderItem ordIte = New OrderItem();
            ordIte.ListPrice = unitprice;
            ordIte.OrderId = orderId;
            ordIte.PricebookEntryId = pricebookEntryId;
            ordIte.Product2Id = product2Id;
            ordIte.Quantity = 1;
            ordIte.UnitPrice = unitprice;
            
            try {
                insert ordIte;
                output = true;
                return output;
            }
            catch (Exception e) {
                system.debug(e.getMessage());
            }
            return output;
        }

        @AuraEnabled(cacheable=true)
        public static List<OrderItem> getAllOrderItems(String orderId) {
            return [SELECT Id ,Product2.Name ,Quantity ,UnitPrice ,TotalPrice  FROM OrderItem WHERE OrderId =:orderId];
        } 
}
