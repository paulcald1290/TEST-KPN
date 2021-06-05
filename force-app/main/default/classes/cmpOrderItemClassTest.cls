@isTest
public with sharing class cmpOrderItemClassTest {
    
    private static String ordId;
    private static String ordPricebook2Id;
    private static String prod2Id;
    private static Decimal pbeUnitPrice;
    private static Decimal itemQuantity; 
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
        ordPricebook2Id = orden.Pricebook2Id;

        Product2 product = new Product2();
        product.Name = 'TEST';
        product.ProductCode = 'Card';
        insert product;
        prod2Id = product.Id;

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
        itemQuantity = orderItems.Quantity;
    }

    @isTest
    private static void checkExistenceProductsTestSuccess() {
        Order ord = [SELECT Id,Pricebook2Id FROM Order LIMIT 1];
        Product2 prod2 = [SELECT Id FROM Product2 LIMIT 1];
        PricebookEntry pbe = [SELECT Id ,UnitPrice FROM PricebookEntry WHERE Product2Id=:prod2.Id LIMIT 1];

        Test.startTest();
        Boolean resultMethod = cmpOrderItemClass.checkExistenceProduct(ord.Id,pbe.Id);
        Test.stopTest();
        System.assertEquals(true, resultMethod);
        // Asserts
    }
    
    @isTest
    private static void insertOrderItemTestSuccess() {
        Order ord = [SELECT Id,Pricebook2Id FROM Order LIMIT 1];
        Product2 prod2 = [SELECT Id FROM Product2 LIMIT 1];
        PricebookEntry pbe = [SELECT Id ,UnitPrice FROM PricebookEntry WHERE Product2Id=:prod2.Id LIMIT 1];
    
        Test.startTest();
        Boolean resultMethod = cmpOrderItemClass.insertOrderItem(ord.Id, pbe.UnitPrice ,pbe.Id, prod2.Id);
        Test.stopTest();
        System.assertEquals(true, resultMethod);
    }

    @isTest
    private static void getAllOrderItemsTestSuccess() {
        Order ord = [SELECT Id FROM Order LIMIT 1];
        List<OrderItem>  listOrderItemTest = [SELECT Id ,Product2.Name ,Quantity ,UnitPrice ,TotalPrice  FROM OrderItem WHERE OrderId =:ord.Id ORDER BY Product2.Name ASC];

        Test.startTest();
        List<OrderItem> listOrderItemMethod = cmpOrderItemClass.getAllOrderItems(ord.Id);
        Test.stopTest();
        System.assertEquals(listOrderItemTest.size(), listOrderItemMethod.size());
    }

    @isTest
    private static void updateOrderitemTestSuccess() {
        Order ord = [SELECT Id FROM Order LIMIT 1];
        Product2 prod2 = [SELECT Id FROM Product2 LIMIT 1];

        Test.startTest();
        Boolean resultMethod = cmpOrderItemClass.updateOrderitem(ord.Id,prod2.Id);
        Test.stopTest();
        System.assert(resultMethod == true);
    }
}
