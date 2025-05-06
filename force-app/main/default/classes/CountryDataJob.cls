public class CountryDataJob implements Queueable, Database.AllowsCallouts {
    public void execute(QueueableContext context) {
        CountryDataService service = new CountryDataService();
        service.fetchAndUpdateCountryData();
    }
}