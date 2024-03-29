    global with sharing class cmpOrderItemClass {
        
    public static boolean output = false;
    
        @AuraEnabled
        public static Boolean checkExistenceProduct(String orderId, String priceBookId) {
            List<OrderItem> ord = [SELECT Id FROM OrderItem WHERE PricebookEntryId=:priceBookId AND OrderId=:orderId];
            
            if (ord.size() > 0) {
                output = true;
            }
            return output;
        }

        @AuraEnabled
        public static Boolean updateOrderitem(String orderId, String product2Id) {
            OrderItem itemInOrder = [SELECT Id, Quantity FROM OrderItem WHERE OrderId =:orderId AND Product2Id =:product2Id];
            itemInOrder.Quantity += 1;
            
            try {
                upsert itemInOrder;
                output = true;
                return output;
            }
            catch (Exception e) {
                system.debug('Error in updateOrderitem Method ' + e.getMessage());
            }
            return output;
        }   

        @AuraEnabled
        public static Boolean insertOrderItem(String orderId, Decimal unitprice,String pricebookEntryId, String product2Id ) {
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
                system.debug('Error in insertOrderItem Method ' + e.getMessage());
            }
            return output;
        }

        @AuraEnabled
        public static List<OrderItem> getAllOrderItems(String orderId) {
            return [SELECT Id ,Product2.Name ,Quantity ,UnitPrice ,TotalPrice,Product2.ProductCode  FROM OrderItem WHERE OrderId =:orderId ORDER BY Product2.Name ASC];
        } 
}
