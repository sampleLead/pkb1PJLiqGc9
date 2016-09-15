/**
 * called from the RoundServices.class
 * purpose is to generate Montrack related tasks for a cohort of Campaign Members when a Round record is
 * created.
 * @author PwC
 */


global  class mt_createTaskBatch implements Database.Batchable<sObject> {
    
    global final String Query; // used to define scope of batch job
    global  String RoundNumber; // used in email post batch completion
    global  String RoundName; // used in email post batch completion
    global Boolean errorOccured;
    
    global Set<ID> cohortID = new set<ID>();
    global map<ID, Round__c> rMap= new map<ID, Round__c>();
    
    global mt_createTaskBatch(list<Round__c> roundList){ 
    	
    	// constructor builds map for use in query scope
        
        Set<Id> roundIds = new Set<Id>();
        for(Round__c round : roundList) roundIds.add(round.id);
        
        // retrieve cohort details not passed in 
        
        for(Round__c round:[ select id, 
        							Round_Number__c, 
        							Cohort__r.Name, 
        							Cohort__c,
        							Name from Round__c where id in:roundIds]){
            rMap.put(round.Cohort__c, round);
            RoundNumber=round.Round_Number__c;
            RoundName=round.Cohort__r.Name;
        }
        
        cohortID=rMap.keyset();
        
        
        Query='SELECT SSA__c,Cohort__c, ContactId,Contact.MonTrack_Opt_Out__c FROM CampaignMember WHERE Cohort__c IN:cohortID AND Contact.MonTrack_Opt_Out__c=False';       
    	
    	errorOccured = false;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
      return Database.getQueryLocator(Query);
    }
    
    global void execute(Database.BatchableContext BC,  List<CampaignMember> scope){
        
        Id recTypeId = CommonServices.recordTypeId('Task',RoundServices.MONTRACK_RECORDTYPE_NAME);
        
        list<Task> tasks= new list<Task>();
        
        for(CampaignMember s : scope){
        
            Task newTask= new Task( whatId=rMap.get(s.Cohort__c).Id, 
                                    whoId=s.contactID,
                                    OwnerId=s.SSA__c,
                                    Subject='MonTRACK Call',recordtypeid=recTypeID);
            tasks.add(newTask);
        }
        
        if(!tasks.isEmpty()){
        	try{
        		insert tasks;
        	} catch (Exception ex){
        		errorOccured = true;
        		ExLog.add('Round insert', 'Task', 'mt_createTaskBatch', ex); // log to stored error logs for review
        	}
        }  
    }
    
    global void finish (Database.BatchableContext BC)
    {
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
        
        mail.setToAddresses(new String[] { UserInfo.getUserEmail() });
        mail.setSenderDisplayName('MonTRACK'); 
        mail.setSubject('Processing for Call Round ' + RoundNumber + ', Cohort '+ RoundName + ' results');  
        if(!errorOccured){
        	mail.setPlainTextBody('You can now access the Call List through the MonTRACK Call List tab.');
        } else {
        	mail.setPlainTextBody('Errors have occured while setting up Montrack tasks, please notify your system administrator. Error logs have been generated for assessment.');
        }
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        
    }

}