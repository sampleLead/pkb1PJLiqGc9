/**
 * Services class to provide CampaignMember sObject centric logical support
 * 
 * @author Carl Vescovi, PwC
 * 
 */


public class CampaignMemberServices {

	
	/**
	* MONTRACK specific logic
	* <p>this class removes tasks related to a now redundant cohort if a montrack campaign member changes cohorts
	* 
	*/
	
	
	
		public class manageChangesOfCohort implements Triggers.Handler {
			
			public void run(){
				
			  List <campaignmember> cmList = new list<campaignmember>();
	          set<id> cohortSet = new set<id>();
	          set<id> contactIds = new set<id>();
		          
	          for(campaignmember cm : (List<CampaignMember>)Trigger.new){
	            
	            campaignmember oldValue = (CampaignMember)Trigger.oldMap.get(cm.id);
	            
	            if(oldValue.Cohort__c != null && cm.Cohort__c != null){
	              if(cm.Cohort__c != oldValue.Cohort__c){
	                  cmList.add(cm);
	                  cohortSet.add(oldValue.cohort__c);
	                  contactIds.add(cm.contactId);
	              }
	            }
	          }
	        
	          // get all the round records for all the changing cohorts
	          
	          if(!cohortSet.isEmpty()){ // this condition handles that this is only done for Montrack campaigns
		          
		          list<Round__c> roundIds = new list<Round__c>([select id from Round__c where cohort__c in: cohortSet]);
		          
		          if(!roundIds.isEmpty()){
			          for(List<task> tasksToDelete : [select id, whoid, whatid from Task where whoid in:contactIds AND 
			                        whatid in: roundIds AND Subject='MonTRACK Call' AND status ='Not Started']){ 
		          
		          	  		delete tasksToDelete; 
			          }
		          }
	      	  }
		           
	        
			}
		}
    
}