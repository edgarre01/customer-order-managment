trigger OrderTrigger on Order__c (before insert, before update, before delete, after insert, after update, after delete) {
    new OrderTriggerHandler().run();
}