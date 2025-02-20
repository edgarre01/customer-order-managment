

Map<String, Object> mapResponse = WeatherCallout.getWeatherByCity('Ciudad de México');
System.debug(mapResponse);



Set<Id> orderIds = new Set<Id>{'a02Kk000002BZieIAG'};
OrderService.updateWeatherForOrders(orderIds);