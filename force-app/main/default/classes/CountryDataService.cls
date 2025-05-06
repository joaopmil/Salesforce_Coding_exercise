public class CountryDataService {
    private static final String API_URL = 'https://api.countrylayer.com/v2/all';
    private static final String API_KEY = '9b6a0cf93477ea3535d71bfeb47ab97f';

    public void fetchAndUpdateCountryData() {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(API_URL + '?access_key=' + API_KEY);
        request.setMethod('GET');

        HttpResponse response = http.send(request);

        if (response.getStatusCode() == 200) {
            List<Country__c> countries = parseResponse(response.getBody());
            updateCountryRecords(countries);
        } else {
            System.debug('API response error: ' + response.getStatus());
        }
    }

    // Parses the API response and builds a list of Country__c records
    private List<Country__c> parseResponse(String responseBody) {
        List<Country__c> countries = new List<Country__c>();
        List<Object> countryList = (List<Object>) JSON.deserializeUntyped(responseBody);

        for (Object obj : countryList) {
            Map<String, Object> countryMap = (Map<String, Object>) obj;

            Country__c country = new Country__c();
            country.Name = (String) countryMap.get('name');
            country.Alpha2Code__c = (String) countryMap.get('alpha2Code');
            country.Alpha3Code__c = (String) countryMap.get('alpha3Code');
            country.CapitalCity__c = (String) countryMap.get('capital');
            country.Region__c = (String) countryMap.get('region');

            // Extracts regional bloc acronyms if available
            if (countryMap.containsKey('regionalBlocs') && countryMap.get('regionalBlocs') != null) {
                country.RegionalBloc__c = extractBlocAcronyms((List<Object>) countryMap.get('regionalBlocs'));
            }

            countries.add(country);
        }

        return countries;
    }

    // Extracts acronyms from the regional blocs list
    private static String extractBlocAcronyms(List<Object> blocs) {
        List<String> acronyms = new List<String>();
        for (Object bloc : blocs) {
            Map<String, Object> b = (Map<String, Object>) bloc;
            if (b.containsKey('acronym') && b.get('acronym') != null) {
                acronyms.add((String) b.get('acronym'));
            }
        }
        return String.join(acronyms, '; ');
    }

    // Updates or inserts records, only if data has changed
    private void updateCountryRecords(List<Country__c> newCountries) {
        Map<String, Country__c> existingCountriesMap = new Map<String, Country__c>();
        for (Country__c c : [
            SELECT Id, Name, Alpha2Code__c, Alpha3Code__c, CapitalCity__c, Region__c, RegionalBloc__c
            FROM Country__c
        ]) {
            existingCountriesMap.put(c.Alpha2Code__c, c);
        }

        List<Country__c> toUpsert = new List<Country__c>();

        for (Country__c country : newCountries) {
            Country__c existing = existingCountriesMap.get(country.Alpha2Code__c);

            // If country does not exist or any field has changed, prepare to upsert
            if (existing == null ||
                existing.Name != country.Name ||
                existing.Alpha3Code__c != country.Alpha3Code__c ||
                existing.CapitalCity__c != country.CapitalCity__c ||
                existing.Region__c != country.Region__c ||
                existing.RegionalBloc__c != country.RegionalBloc__c) {

                if (existing != null) {
                    country.Id = existing.Id;
                }

                toUpsert.add(country);
            }
        }

        if (!toUpsert.isEmpty()) {
            upsert toUpsert;
        }
    }
}