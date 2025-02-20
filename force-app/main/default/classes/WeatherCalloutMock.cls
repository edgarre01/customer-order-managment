@isTest
global class WeatherCalloutMock implements HttpCalloutMock {
    global HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        res.setBody('{"main": {"temp": 22.5}, "weather": [{"description": "Cielo despejado"}]}');
        return res;
    }
}