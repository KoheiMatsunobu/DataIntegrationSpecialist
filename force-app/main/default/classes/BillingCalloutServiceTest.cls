@isTest
private class BillingCalloutServiceTest {

    @testSetup
    static void setup(){
        // Create ServiceCredentials__c
        ServiceCredentials__c credential = new ServiceCredentials__c(
            Name = BillingCalloutService.BILLING_SERVICE_CREDENTIAL_NAME,
            Username__c = 'test username',
            Password__c = 'test password'
        );
        insert credential;

        // Create Account
        Account acc = new Account(
            Name = 'Test Account'
        );
        insert acc;

        // Create Opportunity
        Opportunity opp = new Opportunity(
            AccountId = acc.Id,
            Name = 'Test Opp',
            Type = 'New Project',
            CloseDate = Date.today(),
            StageName = 'Prospecting',
            Amount = 100000
        );
        insert opp;

        // Create Project__c
        Project__c prj = new Project__c(
            Name = 'test project',
            ProjectRef__c = 'test project ref 123xyz',
            Billable_Amount__c = 100000,
            Status__c = 'Running',
            Opportunity__c = opp.Id
        );
        insert prj;
    }

    @isTest 
    static void testBillingCalloutSuccess(){
        List<Project__c> lstPrj = [SELECT Id FROM Project__c WHERE Name = 'test project'];

        for(Project__c prj : lstPrj){
            prj.Status__c = 'Billable';
        }

        Test.startTest();

        Test.setMock(WebServiceMock.class, new BillingCalloutServiceMock());
        update lstPrj;

        Test.stopTest();

        lstPrj = [SELECT Status__c FROM Project__c WHERE Name = 'test project'];
        System.assertEquals('Billed', lstPrj[0].Status__c);
    }

    @isTest
    static void testBillingCalloutFailure(){
        List<Project__c> lstPrj = [SELECT Id FROM Project__c WHERE Name = 'test project'];

        for(Project__c prj : lstPrj){
            prj.Status__c = 'Running';
        }

        Test.startTest();

        Test.setMock(WebServiceMock.class, new BillingCalloutServiceMockFailure());
        update lstPrj;

        Test.stopTest();

        lstPrj = [SELECT Status__c FROM Project__c WHERE Name = 'test project'];
        System.assertEquals('Running', lstPrj[0].Status__c);
    }
}