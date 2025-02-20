trigger OrderItemTrigger on OrderItem__c (before insert, before update, before delete, after insert, after update, after delete) {
    new OrderItemTriggerHandler().run();
}