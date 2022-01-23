@isTest
private class ProjectRESTServiceTest {
    @testSetup
    static void setup(){
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
    }

    @isTest
    static void testProjectRestServiceSuccess(){
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'Test Opp'];

        RestRequest request = new RestRequest();
        request.httpMethod = 'POST';
        request.requestURI = '/services/apexrest/project';

        Test.startTest();

        String response = ProjectRESTService.postProjectData(
            'Test Ref 123',
            'Test Project',
            opp.Id,
            Date.today(),
            Date.today().addDays(1),
            110000,
            'Running'
        );

        Test.stopTest();

        opp = [SELECT DeliveryInstallationStatus__c FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals('OK', response);
    }

    @isTest
    static void testProjectRestServiceFailure(){
        RestRequest request = new RestRequest();

        request.httpMethod = 'POST';
        request.requestURI = '/services/apexrest/project';

        Test.startTest();

        String response = ProjectRESTService.postProjectData(
            'Test Ref 123',
            'Test Project',
            'test opp id',
            Date.today(),
            Date.today().addDays(1),
            110000,
            'Running'
        );

        Test.stopTest();

        System.assertEquals('Invalid id: test opp id', response);
    }
}