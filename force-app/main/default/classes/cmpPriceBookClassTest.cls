@isTest
public with sharing class cmpPriceBookClassTest {
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

        Contact cont = new Contact();
        cont.FirstName = 'First Name Test';
        cont.LastName = 'Last Name Test';
        cont.Salutation = 'Mr';
        cont.AccountId = acc.Id;
        cont.Email = 'emailTest@yopmail.com';
        insert cont;

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
    private static void getProductsByOrderIdTestSuccess() {
        Order ord = [SELECT Id, Pricebook2Id FROM Order LIMIT 1];
        Test.startTest();
        List<PricebookEntry> listPriceMethod = cmpPriceBookClass.getProductsByOrderId(ord.Id);
        Test.stopTest();
        System.assert(listPriceMethod != null);
        // Asserts
    }
}
