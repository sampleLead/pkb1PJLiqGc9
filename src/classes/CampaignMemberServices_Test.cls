/**
 * This class contains unit tests for validating the behavior of Service level class methods
 * these methods are part of the testing framework implemented throughout UniCRM
 * 
 */
@isTest
private class CampaignMemberServices_Test {

    static testMethod void confirmTaskCleanUpAtCohortChange() {
        
        //create user
        
        User u= TestHelper.ssaUser();
        
        //create account
        
        List<Account>acct= TestHelper.createStudent(10);
        insert acct;
        
        List<Contact> conList= TestHelper.createStudentContacts(10, acct);
        
        insert conList;
        
        Set<ID>accountID = new Set<ID>();
        
        for(Account a:acct){
            accountID.add(a.ID);
        }
        
        //create Campaign
        
        List<Campaign> camp=  TestHelper.createCampaign(1);
        insert camp;
        
        //create Cohorts
        
        List<Cohort__c> cohorts = TestHelper.createCohort(2);
        insert cohorts;
        
        set<ID> contactID= new Set<ID> ();
        for(Contact con : conList){
            contactID.add(con.Id);
        }
        list<CampaignMember> cm= TestHelper.createCampaignMember(u.Id, cohorts[0].id, camp[0].Id,contactID );
        insert cm;
        
        list<CampaignMember> tmpCM= new List<CampaignMember>();
        tmpCM=[SELECT ID,contactID,cohort__c,CampaignID FROM CampaignMember WHERE Cohort__c=:cohorts[0].ID AND CampaignID=:camp[0].Id ];
        
        Test.startTest();
        
        list<Round__c> rList= TestHelper.createRounds(tmpCM[0].Cohort__c, tmpCM[0].CampaignId, 4); 
        insert rList;
        
        Set<id> roundIds = new Set<Id>();
        for(Round__c round : rList) roundIds.add(round.id);
        
        Test.stopTest();
        
        List<Task> taskList = [select id,whoid,whatid from Task where whatid in:roundIds ];
        system.assertNotEquals(0,
        					   taskList.size(),
        					   'Tasks were not setup');
        					   
        system.debug('**tasks '+taskList);		   
        system.assertNotEquals(0, tmpCM.size(),'no campaign members to test on');
        
        integer roundTasksCount = taskList.size();
        
        // change a cohort on campaign member
        
        tmpCM[0].Cohort__c = cohorts[1].Id;
        
        update tmpCM[0];
        
        system.assertNotEquals(roundTasksCount,
					  [select COUNT() from Task where whatid in:roundIds ],
					  'expected task count to drop due to move away from cohort');
        
        
    }
}