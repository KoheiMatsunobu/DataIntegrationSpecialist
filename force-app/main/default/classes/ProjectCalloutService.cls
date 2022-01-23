public class ProjectCalloutService {
    // Const
    public static final String PROJECT_SERVICE_TOKEN_NAME = 'ProjectServiceToken';

    // Classes
    public class QueueablePMSCall implements Queueable, Database.AllowsCallouts {
        List<Id> oppIdsToProcess;

        public QueueablePMSCall(List<Id> oppIds){
            oppIdsToProcess = oppIds;
        }

        public void execute(QueueableContext context){
            collectDataAndCallOut(oppIdsToProcess);
        }
    }

    public class CalloutInformationWrapper {
        String oppId;
        String oppName;
        String accName;
        String closeDate;
        Decimal amount;

        public CalloutInformationWrapper(Opportunity opp){
            this.oppId = opp.Id;
            this.oppName = opp.Name;
            this.accName = opp.Account.Name;
            this.closeDate = String.valueOf(opp.CloseDate);
            this.amount = opp.Amount;
        }

    }

    // Methods
    //invocableMethodアノテーションを付与することで、プロセスビルダーのアクションからApexクラスを呼び出せる
    //プロセスビルダーから呼び出せるメソッドは、postOpportunityToPMSメソッド
    @InvocableMethod
	public static void postOpportunityToPMS(List<Id> oppIds){
        if(oppIds.size() > 0){
            System.enqueueJob(new QueueablePMSCall(oppIds));
        }
    }

    public static void collectDataAndCallOut(List<Id> oppIds){
        List<Opportunity> lstOppToProcess = [
            SELECT
                Id,
                Name,
                Account.Name,
                CloseDate,
                Amount
            FROM Opportunity
            WHERE Id IN :oppIds
        ];

        if(lstOppToProcess.size() > 0){
            makeCallOut(
                lstOppToProcess[0],
                ServiceTokens__c.getInstance(PROJECT_SERVICE_TOKEN_NAME).Token__c
            );
        }
    }

    public static void makeCallOut(Opportunity opp, String prjServiceToken){
        HttpRequest request = new HttpRequest();

        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('token', prjServiceToken);
        request.setEndpoint('callout:ProjectService');
        request.setBody(JSON.serialize(new CalloutInformationWrapper(opp)));

        HttpResponse response = new Http().send(request);

        if(response.getStatusCode() == 201 && response.getStatus() == 'OK'){
            opp.StageName = 'Submitted Project';
        } else if(response.getStatusCode() == 500){
            opp.StageName = 'Resubmit Project';
        }

        update opp;
    }

}