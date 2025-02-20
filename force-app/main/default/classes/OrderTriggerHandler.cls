public with sharing class OrderTriggerHandler extends TriggerHandler {

    private Boolean isNotAsyncProcess = !System.isBatch() && !System.isFuture() && !System.isQueueable() && !System.isScheduled();

    public OrderTriggerHandler() {
        this.setMaxLoopCount(5);
    }

    public override void afterInsert() {
        List<Order__c> records = Trigger.new;
        validateAllAfters(records, null);
    }

    public override void afterUpdate() {
        List<Order__c> records = Trigger.new;
        Map<Id, Order__c> oldRecords = (Map<Id, Order__c>)Trigger.oldMap;
        validateAllAfters(records, oldRecords);
        
    }

    public override void afterDelete() {
        List<Order__c> records = Trigger.old; // set old values, because new values in after delete not exist
        validateAllAfters(records, null);
        
    }

    private void validateAllAfters(List<Order__c> records, Map<Id, Order__c> oldRecords) {
        Set<Id> orderIdsChangeAddress = new Set<Id>();
        for(Order__c record : records){
            
            if(!Trigger.isDelete && String.isNotEmpty(record.ShippingAddress__c) && (oldRecords == null || record.ShippingAddress__c != oldRecords.get(record.Id).ShippingAddress__c)){
                orderIdsChangeAddress.add(record.Id);
            }
        }

        if(!orderIdsChangeAddress.isEmpty() && orderIdsChangeAddress.size() < 100 && isNotAsyncProcess){
            OrderService.updateWeatherForOrders(orderIdsChangeAddress);
        }
    }
    
}