public class CountryDataScheduler implements Schedulable {
    public void execute(SchedulableContext sc) {
        System.enqueueJob(new CountryDataJob());
    }
}