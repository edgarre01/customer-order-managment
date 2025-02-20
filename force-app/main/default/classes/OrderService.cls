public with sharing class OrderService {

    public class OrderServiceException extends Exception {}
    
    public static void updateOrderTotals(Set<Id> orderIds) {
        if (orderIds.isEmpty()) return;

        // Calcular la nueva suma de los OrderItem
        Map<Id, Decimal> orderTotals = new Map<Id, Decimal>();
        for (AggregateResult ar : [
            SELECT Order__c Id, SUM(TotalPrice__c) total 
            FROM OrderItem__c 
            WHERE Order__c IN :orderIds 
            GROUP BY Order__c
        ]) {
            orderTotals.put((Id) ar.get('Id'), (Decimal) ar.get('total'));
        }

        // Actualizar las órdenes con el nuevo total
        List<Order__c> ordersToSave = new List<Order__c>();
        for (Id orderId : orderTotals.keySet()) {
            Decimal total = orderTotals.get(orderId) != null ? orderTotals.get(orderId) : 0;
            Order__c order = new Order__c(Id = orderId);
            order.TotalAmount__c = total;
            ordersToSave.add(order);
        }

        if (!ordersToSave.isEmpty()) {
            if(Schema.Order__c.sObjectType.getDescribe().isUpdateable() && 
            Schema.Order__c.fields.TotalAmount__c.getDescribe().isUpdateable()) {
                update ordersToSave;
            } else {
                throw new OrderServiceException('Invalid Permissions');
            }
        }
    }

    /**
     * Método @future para actualizar el clima en órdenes
     * @param orderIds Ids de las órdenes a actualizar.
     */
    @future(callout=true)
    public static void updateWeatherForOrders(Set<Id> orderIds) {
        if (orderIds.isEmpty()) return;

        List<Order__c> orders = [SELECT Id, ShippingAddress__c FROM Order__c WHERE Id IN :orderIds AND ShippingAddress__c != NULL];
        if (orders.isEmpty()) return;

        List<Order__c> ordersToUpdate = new List<Order__c>();

        for (Order__c order : orders) {
            Map<String, Object> weatherData = WeatherCallout.getWeatherByCity(order.ShippingAddress__c);

            if (weatherData != null && weatherData.containsKey('temperature')) {
                order.Temperature__c = (Decimal) weatherData.get('temperature');
                order.WeatherDescription__c = (String) weatherData.get('description');
                order.WeatherFillDatetime__c = System.now();
                ordersToUpdate.add(order);
            }
        }

        if (!ordersToUpdate.isEmpty()) {
            update ordersToUpdate;
        }
    }
}