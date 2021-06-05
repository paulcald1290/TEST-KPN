/******************************************************************************************************
File Name : JSONHelperClass
Description: This class creates its Json and send it to requestCatcher
*******************************************************************************************************/
global with sharing class JSONHelperClass {

    @AuraEnabled
    public static Integer sendOrderByPOST(String orderId,String products) {
        
        
        String JsonToSend = JSONCreation(orderId, products);
        System.debug('JSON To Send '+ JsonToSend);
        String endpoint = 'https://testkpn.requestcatcher.com/test';
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setbody(JsonToSend);
        Http http = new Http();
        HTTPResponse response = http.send(req);

        return response.getStatusCode();
    }
    
    public static String JSONCreation(String orderId,String products){
        
        String JsonOutput;
        try {
            Order ord = [SELECT Id ,Type ,AccountId ,OrderNumber ,Status FROM  Order WHERE Id=:orderId]; 
            Account acc = [SELECT Id ,Type ,AccountNumber FROM  Account WHERE Id=:ord.AccountId]; 
            List<Map<String,String>> deserializedList = (List<Map<String,String>>)JSON.deserialize(products, List<Map<String,String>>.class);
            
            JSONGenerator gen = JSON.createGenerator(true); 
            gen.writeStartObject();        
            gen.writeStringField('accountNumber', acc.AccountNumber);
            gen.writeStringField('orderNumber',ord.OrderNumber);
            gen.writeStringField('type',ord.Type);
            gen.writeStringField('status',ord.Status);
            gen.writeFieldName('orderProducts');
            gen.writeStartArray();
                    
            for (Map<String, String> PlanQuan : deserializedList) {
                gen.writeStartObject();
                gen.writeStringField('name',PlanQuan.get('Name'));
                gen.writeStringField('code', PlanQuan.get('productCode'));
                gen.writeNumberField('unitPrice', Integer.valueof(PlanQuan.get('unitPrice')));
                gen.writeNumberField('quantity', Integer.valueof(PlanQuan.get('quantity')));
                gen.writeEndObject();
            }
            gen.writeEndArray();       
            gen.writeEndObject();    
            JsonOutput = gen.getAsString();
        } catch(Exception e) {
            System.debug(e.getMessage());
            System.debug(e.getLineNumber());
            System.debug(e.getStackTraceString());
        }
        return JsonOutput;
    }
}