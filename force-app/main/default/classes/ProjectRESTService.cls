@RestResource(urlMapping='/project/*')
global class ProjectRESTService {

    @HttpPost
    global static String postProjectData(
        String projectRef,
        String projectName,
        String oppId,
        Date startDate,
        Date endDate,
        Double amount,
        String status
    ){
        Savepoint sp = Database.setSavepoint();

        try{
            // Create Project
            Project__c prj = new Project__c(
                ProjectRef__c = projectRef,
                Name = projectName,
                Opportunity__c = oppId,
                Start_Date__c = startDate,
                End_Date__c = endDate,
                Billable_Amount__c = amount,
                Status__c = status
            );
            upsert prj;

            //Create Opportunity
            Opportunity opp = new Opportunity(
                Id = oppId,
                DeliveryInstallationStatus__c = 'In progress'
            );
            update opp;

            return 'OK';
        } catch(Exception ex){
            Database.rollback(sp);
            return ex.getMessage();
        }
    }
}