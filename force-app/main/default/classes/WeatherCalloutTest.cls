@isTest
private class WeatherCalloutTest {

    @isTest
    static void testGetWeatherByCity() {
        Test.setMock(HttpCalloutMock.class, new WeatherCalloutMock());

        Test.startTest();
        Map<String, Object> weatherData = WeatherCallout.getWeatherByCity('Madrid');
        Test.stopTest();

        Assert.areEqual(22.5, weatherData.get('temperature'), 'La temperatura debe ser 22.5°C');
        Assert.areEqual('Cielo despejado', weatherData.get('description'), 'La descripción del clima debe ser "Cielo despejado"');
    }
}