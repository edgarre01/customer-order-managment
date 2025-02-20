@isTest
private class OrderItemTriggerHandlerTest {

    @testSetup
    static void setupTestData() {
        Customer__c customer = new Customer__c(Email__c = 'test@example.com', Phone__c = '1234567890');
        insert customer;

        Order__c order = new Order__c(Customer__c = customer.Id, DueDate__c = Date.today().addDays(7), ShippingAddress__c = '123 Main St');
        insert order;
    }

    @isTest
    static void testTriggerOnInsert() {
        // Obtener la orden creada
        Order__c order = [SELECT Id FROM Order__c LIMIT 1];

        // Insertar un OrderItem
        OrderItem__c item = new OrderItem__c(Order__c = order.Id, ItemName__c = 'Item 1', Quantity__c = 2, UnitPrice__c = 15);
        insert item;

        // Verificar que el trigger actualizó el total correctamente
        order = [SELECT Id, TotalAmount__c FROM Order__c WHERE Id = :order.Id];
        Assert.areEqual(30, order.TotalAmount__c, 'El total de la orden debe actualizarse a 30');
    }

    @isTest
    static void testTriggerOnUpdate() {
        // Obtener la orden creada
        Order__c order = [SELECT Id FROM Order__c LIMIT 1];

        // Insertar un OrderItem
        OrderItem__c item = new OrderItem__c(Order__c = order.Id, ItemName__c = 'Item 1', Quantity__c = 1, UnitPrice__c = 10);
        insert item;

        // Actualizar el item
        item.Quantity__c = 3;
        update item;

        // Verificar que el trigger actualizó el total correctamente
        order = [SELECT Id, TotalAmount__c FROM Order__c WHERE Id = :order.Id];
        Assert.areEqual(30, order.TotalAmount__c, 'El total de la orden debe actualizarse a 30');
    }

    @isTest
    static void testTriggerOnDelete() {
        // Obtener la orden creada
        Order__c order = [SELECT Id FROM Order__c LIMIT 1];

        // Insertar dos OrderItems
        List<OrderItem__c> items = new List<OrderItem__c>{
            new OrderItem__c(Order__c = order.Id, ItemName__c = 'Item 1', Quantity__c = 2, UnitPrice__c = 10),
            new OrderItem__c(Order__c = order.Id, ItemName__c = 'Item 2', Quantity__c = 1, UnitPrice__c = 20)
        };
        insert items;

        // Verificar total después del insert (2 * 10 + 1 * 20 = 40)
        order = [SELECT Id, TotalAmount__c FROM Order__c WHERE Id = :order.Id];
        Assert.areEqual(40, order.TotalAmount__c, 'El total de la orden debe ser 40');

        // Eliminar un item
        delete items[0];

        // Verificar que el trigger actualizó el total correctamente (solo queda 1 * 20 = 20)
        order = [SELECT Id, TotalAmount__c FROM Order__c WHERE Id = :order.Id];
        Assert.areEqual(20, order.TotalAmount__c, 'El total de la orden debe actualizarse a 20');
    }
}