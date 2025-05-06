@IsTest
public class LeadCountryInfoTriggerTest {
    @TestSetup
    static void setup() {
        // Create a test Country__c record
        Country__c testCountry = new Country__c(
            Name = 'Test Country',
            Alpha2Code__c = 'TC',
            Alpha3Code__c = 'TCC',
            CapitalCity__c = 'Test City',
            Region__c = 'Region A',
            RegionalBloc__c = 'ACB'
        );
        insert testCountry;
    }

    @IsTest
    static void testLeadCountryInfoTrigger() {
        // Create a test Lead record with a country name
        Lead testLead = new Lead(
            FirstName = 'Test',
            LastName = 'Lead',
            Company = 'Test Company',
            Country = 'Test Country'
        );

        Test.startTest();
        insert testLead;
        Test.stopTest();

        // Verify that the Country__c field on the Lead record is updated
        testLead = [SELECT Id, Country__c FROM Lead WHERE Id = :testLead.Id];
        Country__c testCountry = [SELECT Id FROM Country__c WHERE Name = 'Test Country' LIMIT 1];
        System.assertEquals(testCountry.Id, testLead.Country__c);
    }
}