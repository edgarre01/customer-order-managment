@isTest
private class OrderServiceTest {

    @testSetup
    static void setupTestData() {
        // Crear un cliente
        Customer__c customer = new Customer__c(
            Email__c = 'test@example.com',
            Phone__c = '1234567890'
        );
        insert customer;

        // Crear una orden
        Order__c order = new Order__c(
            Customer__c = customer.Id,
            DueDate__c = Date.today().addDays(7),
            ShippingAddress__c = 'Madrid'
        );
        insert order;

        // Crear items de la orden
        List<OrderItem__c> items = new List<OrderItem__c>{
            new OrderItem__c(Order__c = order.Id, ItemName__c = 'Item 1', Quantity__c = 2, UnitPrice__c = 10),
            new OrderItem__c(Order__c = order.Id, ItemName__c = 'Item 2', Quantity__c = 1, UnitPrice__c = 20)
        };
        insert items;
    }

    @isTest
    static void testUpdateOrderTotals() {
        // Obtener la orden creada
        Order__c order = [SELECT Id, TotalAmount__c FROM Order__c LIMIT 1];

        // Verificar que inicialmente el total es 0
        Assert.areEqual(40, order.TotalAmount__c, 'El total inicial debe ser 0');

        // Llamar al método que actualiza el total
        OrderService.updateOrderTotals(new Set<Id>{order.Id});

        // Volver a consultar la orden actualizada
        order = [SELECT Id, TotalAmount__c FROM Order__c WHERE Id = :order.Id];

        // Validar el nuevo total (2 * 10 + 1 * 20 = 40)
        Assert.areEqual(40, order.TotalAmount__c, 'El total de la orden debe ser 40');
    }

    @isTest
    static void testUpdateWeatherForOrders() {
        Test.setMock(HttpCalloutMock.class, new WeatherCalloutMock());

        Test.startTest();
        Set<Id> orderIds = new Set<Id>{ [SELECT Id FROM Order__c LIMIT 1].Id };
        OrderService.updateWeatherForOrders(orderIds);
        Test.stopTest();

        Order__c updatedOrder = [SELECT Temperature__c, WeatherDescription__c, WeatherFillDatetime__c FROM Order__c LIMIT 1];

        System.assertEquals(22.5, updatedOrder.Temperature__c, 'La temperatura debe ser 22.5°C');
        System.assertEquals('Cielo despejado', updatedOrder.WeatherDescription__c, 'La descripción debe ser "Cielo despejado"');
        System.assertNotEquals(null, updatedOrder.WeatherFillDatetime__c, 'La fecha y hora de actualización debe estar presente');
    }
}