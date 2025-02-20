public with sharing class OrderItemTriggerHandler extends TriggerHandler {

    public OrderItemTriggerHandler() {
        this.setMaxLoopCount(5);
    }

    public override void afterInsert() {
        List<OrderItem__c> records = Trigger.new;
        validateAllAfters(records, null);
    }

    public override void afterUpdate() {
        List<OrderItem__c> records = Trigger.new;
        Map<Id, OrderItem__c> oldRecords = (Map<Id, OrderItem__c>)Trigger.oldMap;
        validateAllAfters(records, oldRecords);
        
    }

    public override void afterDelete() {
        List<OrderItem__c> records = Trigger.old; // set old values, because new values in after delete not exist
        validateAllAfters(records, null);
        
    }

    private static void validateAllAfters(List<OrderItem__c> records, Map<Id, OrderItem__c> oldRecords) {
        Set<Id> orderIdsTotalAmount = new Set<Id>();
        for(OrderItem__c record : records){
            // validation when TotalPrice__c change or is new or is deleted
            if(record.TotalPrice__c != 0 && (oldRecords == null || record.TotalPrice__c != oldRecords.get(record.Id).TotalPrice__c)){
                orderIdsTotalAmount.add(record.Order__c);
            }
        }

        if(!orderIdsTotalAmount.isEmpty()){
            OrderService.updateOrderTotals(orderIdsTotalAmount);
        }

    }


    

    
}