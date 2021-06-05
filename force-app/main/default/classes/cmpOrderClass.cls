global with sharing class cmpOrderClass {
    
    public static boolean output = false;

        @AuraEnabled
        public static Boolean UpdateOrderStatus(String orderId) {
            Order ord = [SELECT Id, Status FROM Order WHERE Id=:orderId];
            ord.Status = 'Activated';
            try {
                upsert ord;
                output = true;
                return output;
            }
            catch (Exception e) {
                system.debug('Error in UpdateOrderStatus Method ' + e.getMessage());
            }
            return output;
        }
}
