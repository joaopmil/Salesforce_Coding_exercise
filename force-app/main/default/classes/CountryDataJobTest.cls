@IsTest
public class CountryDataJobTest {
    @IsTest
    static void testExecute() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        CountryDataJob job = new CountryDataJob();
        Test.startTest();
        job.execute(null);
        Test.stopTest();

        List<Country__c> updatedCountries = [SELECT Id, Name, Alpha2Code__c, Alpha3Code__c, CapitalCity__c, Region__c, RegionalBloc__c FROM Country__c];
        System.assertEquals(1, updatedCountries.size());

        Country__c updatedCountry = updatedCountries[0];
        System.assertEquals('Test Country', updatedCountry.Name);
        System.assertEquals('TC', updatedCountry.Alpha2Code__c);
        System.assertEquals('TCC', updatedCountry.Alpha3Code__c);
        System.assertEquals('Test City', updatedCountry.CapitalCity__c);
        System.assertEquals('Region A', updatedCountry.Region__c);
        System.assertEquals('ACB', updatedCountry.RegionalBloc__c);
    }

    // MockHttpResponseGenerator class to simulate HTTP response for testing
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('[{"name": "Test Country", "alpha2Code": "TC", "alpha3Code": "TCC", "capital": "Test City", "region": "Region A", "regionalBlocs": [{"acronym": "ACB"}]}]');
            response.setStatusCode(200);
            return response;
        }
    }
}