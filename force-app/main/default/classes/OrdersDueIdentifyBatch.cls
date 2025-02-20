public class OrdersDueIdentifyBatch implements Database.Batchable<SObject>, Schedulable {
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([SELECT Id, DueDate__c FROM Order__c WHERE DueDate__c < TODAY]);
    }

    public void execute(Database.BatchableContext BC, List<Order__c> orders) {
        List<Order__c> ordersToUpdate = new List<Order__c>();

        for (Order__c ord : orders) {
            ord.Status__c = 'Overdue';
            ordersToUpdate.add(ord);
        }

        if (!ordersToUpdate.isEmpty()) {
            update ordersToUpdate;
        }
    }

    public void finish(Database.BatchableContext BC) {
        System.debug('Batch execution completed');
    }

    // Permite la ejecución programada del batch
    public void execute(SchedulableContext SC) {
        Database.executeBatch(new OrdersDueIdentifyBatch(), 200);
    }
}