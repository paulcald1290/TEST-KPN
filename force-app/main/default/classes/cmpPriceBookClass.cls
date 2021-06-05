    global with sharing class cmpPriceBookClass {

        @AuraEnabled(cacheable=true)
        public static List<PricebookEntry> getProductsByOrderId(String orderId) {
            system.debug('asd ' + orderId);
            Order ord = [SELECT Id, Pricebook2Id FROM Order WHERE Id=:orderId];
            return [SELECT Id, Name, Product2Id, UnitPrice FROM PricebookEntry WHERE Pricebook2Id =: ord.Pricebook2Id AND IsActive = true ORDER BY Name ASC];
        }
        
}
