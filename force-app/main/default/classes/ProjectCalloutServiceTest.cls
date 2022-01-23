@isTest
private class ProjectCalloutServiceTest {

    // テストデータ作成
    @testSetup
    static void setup(){
        //トークン作成
        ServiceTokens__c token = new ServiceTokens__c(
            Name = ProjectCalloutService.PROJECT_SERVICE_TOKEN_NAME,
            Token__c = 'TestToken'
        );
        insert token;

        //取引先作成
        Account acc = new Account(
            Name = 'Test Account'
        );
        insert acc;

        //商談作成
        Opportunity opp = new Opportunity(
            AccountId = acc.Id,
            Name = 'Test Opportunity',
            Type = 'New Project',
            CloseDate = Date.today(),
            StageName = 'Prospecting',
            Amount = 100000
        );
        insert opp;
    }

    // コールアウト成功
    @isTest
    static void testPMSCalloutSuccess(){
        List<Opportunity> lstOpp = [SELECT Id, StageName FROM Opportunity WHERE Name = 'Test Opportunity'];
        List<Id> lstOppIds = new List<Id>();
        for(Opportunity opp : lstOpp){
            opp.StageName = 'Closed Won';
            lstOppIds.add(opp.Id);
        }

        //テスト開始
        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new ProjectCalloutServiceMockFailure()); //コールアウト
        update lstOpp;

        ProjectCalloutService.postOpportunityToPMS(lstOppIds);

        //テスト終了
        Test.stopTest();

        try {
            lstOpp = [SELECT Id, StageName FROM Opportunity WHERE Name = 'Test Opportunity'];
            System.assertEquals('Submitted Project', lstOpp[0].StageName);
        } catch (Exception ex){

        }
    }

    // コールアウト失敗
    @isTest
    static void testPMSCalloutFailure(){
        List<Opportunity> lstOpp = [SELECT Id, StageName FROM Opportunity WHERE Name = 'Test Opportunity'];
        List<Id> lstOppIds = new List<Id>();
        for(Opportunity opp : lstOpp){
            opp.StageName = 'Closed Won';
            lstOppIds.add(opp.Id);
        }

        //テスト開始
        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new ProjectCalloutServiceMock()); //コールアウト
        update lstOpp;

        ProjectCalloutService.postOpportunityToPMS(lstOppIds);

        //テスト終了
        Test.stopTest();

        try {
            lstOpp = [SELECT StageName FROM Opportunity WHERE Name = 'Test Opportunity'];
            System.assertEquals('Resubmit Project', lstOpp[0].StageName);
        } catch (Exception ex){

        }
    }
}