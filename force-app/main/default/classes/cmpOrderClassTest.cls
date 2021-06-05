@isTest
public with sharing class cmpOrderClassTest {
    
    private static String ordId;
    private static Boolean resultTest = false;

    @TestSetup
    static void makeData(){
        Account acc = new Account();
        acc.Name = 'Testing Account';
        acc.ShippingStreet = 'Street Test';
        acc.ShippingPostalCode = 'PC Test';
        acc.Type = 'Consumer';
        Insert acc;    

        Order orden = new Order();
        orden.AccountId = acc.Id;
        orden.Status = 'draft';
        orden.Pricebook2Id = Test.getStandardPricebookId();
        orden.EffectiveDate = Date.today();
        Insert orden;
        ordId = orden.Id;

        Product2 product = new Product2();
        product.Name = 'TEST';
        product.ProductCode = 'Card';
        insert product;

        PricebookEntry price = new PricebookEntry();
        price.UnitPrice = 5000.0;
        price.Pricebook2Id = Test.getStandardPricebookId();
        price.Product2Id = product.Id;
        price.isActive = true;
        insert price;

        OrderItem orderItems = new OrderItem();
        orderItems.Product2Id = product.Id;  
        orderItems.OrderId = orden.Id;
        orderItems.Quantity = 1; 
        orderItems.UnitPrice= price.UnitPrice;
        orderItems.PricebookEntryId = price.Id;
        insert orderItems;
    }

    @isTest
    private static void UpdateOrderStatusTestSuccess() {
        Order ord = [SELECT Id FROM Order LIMIT 1];
        System.debug('ord: ' + ord);
        Test.startTest();
        Boolean resultMethod = cmpOrderClass.UpdateOrderStatus(ord.Id);
        Test.stopTest();
        System.assertEquals(true, resultMethod);

    }


}
