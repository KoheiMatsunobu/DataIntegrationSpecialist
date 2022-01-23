public class BillingCalloutService {
    
    public static final String BILLING_SERVICE_CREDENTIAL_NAME = 'BillingServiceCredential';
    static final ServiceCredentials__c credential = ServiceCredentials__c.getInstance(BILLING_SERVICE_CREDENTIAL_NAME);

    public static void callBillingService(List<Project__c> newProjects, Map<Id, Project__c> oldProjectsMap){
        List<Project__c> lstProjectToSync = new List<Project__c>();

        for(Project__c prj : newProjects){
            Project__c oldProject = oldProjectsMap.get(prj.Id);

            if(prj.Status__c == 'Billable' && prj.Status__c != oldProject.Status__c){
                lstProjectToSync.add(prj);
            }
        }

        if(lstProjectToSync.size() > 0){
            makeCallout(JSON.serialize(lstProjectToSync));
        }
    }

    @future(callout=true)
    static void makeCallout(String serializedProject){
        List<Project__c> lstPrj = (List<Project__c>)JSON.deserialize(serializedProject, List<Project__c>.class);
        List<Project__c> lstUpdPrj = new List<Project__c>();

        for(Project__c prj : lstPrj){
            BillingServiceProxy.InvoicesPortSoap11 invoicePort = new BillingServiceProxy.InvoicesPortSoap11();
            BillingServiceProxy.project extPrj = setAndGetExternalProject(prj);
            String response = invoicePort.billProject(extPrj);

            if(response == 'OK'){
                prj.Status__c = 'Billed';
                lstUpdPrj.add(prj);
            }
        }

        if(lstUpdPrj.size() > 0){
            update lstUpdPrj;
        }
    }

    static BillingServiceProxy.project setAndGetExternalProject(Project__c prj){
        BillingServiceProxy.project extPrj = new BillingServiceProxy.project();
        extPrj.projectId = prj.ProjectRef__c;
        extPrj.billAmount = prj.Billable_Amount__c;
        extPrj.username = credential.Username__c;
        extPrj.password = credential.Password__c;

        return extPrj;
    }
}