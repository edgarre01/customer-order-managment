public with sharing class WeatherCallout {
    
    private static final String CALLOUT_NAME = 'WeatherApi';

    /**
     * Obtiene la configuración del servicio desde CalloutSetting__mdt
     */
    private static CalloutSetting__mdt getCalloutSettings() {
        return CalloutSetting__mdt.getInstance(CALLOUT_NAME);
    }

    /**
     * Obtiene la temperatura y descripción del clima en una ciudad dada.
     * @param cityName Nombre de la ciudad.
     * @return Mapa con 'temperature' (Decimal) y 'description' (String).
     */
    public static Map<String, Object> getWeatherByCity(String cityName) {
        if (String.isEmpty(cityName)) {
            return null;
        }

        Map<String, Object> weatherData = new Map<String, Object>();

        try {
            CalloutSetting__mdt settings = getCalloutSettings();
            if (settings == null) {
                System.debug('Error: No se encontró la configuración de CalloutSetting__mdt');
                return null;
            }

            String url = settings.Endpoint__c+ '?q=' + EncodingUtil.urlEncode(cityName, 'UTF-8') + '&units=metric' + '&lang=sp' + '&appid=' + EncodingUtil.urlEncode(settings.Token__c, 'UTF-8');

            HttpRequest req = new HttpRequest();
            req.setEndpoint(url); // Usa Named Credential
            req.setMethod(settings.Method__c); // GET por defecto, configurable

            Http http = new Http();
            HttpResponse res = http.send(req);

            if (res.getStatusCode() == 200) {
                Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                
                // Obtener temperatura
                Map<String, Object> mainData = (Map<String, Object>) responseMap.get('main');
                weatherData.put('temperature', (Decimal) mainData.get('temp'));

                // Obtener descripción del clima
                List<Object> weatherList = (List<Object>) responseMap.get('weather');
                if (!weatherList.isEmpty()) {
                    Map<String, Object> weatherInfo = (Map<String, Object>) weatherList[0];
                    weatherData.put('description', (String) weatherInfo.get('description'));
                }
            }else{
                // register error log or exception or response with error
            }
        } catch (Exception e) {
            System.debug('Error en WeatherCallout: ' + e.getMessage());
        }

        return weatherData;
    }
}