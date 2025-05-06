trigger LeadCountryInfoTrigger on Lead (before insert, before update) {
    for (Lead lead : Trigger.new) {
        if (String.isNotBlank(lead.Country)) {
            List<Country__c> results = [SELECT Id FROM Country__c WHERE Name = :lead.Country LIMIT 1];
            if (!results.isEmpty()) {
                lead.Country__c = results[0].Id;
            }
        }
    }
}