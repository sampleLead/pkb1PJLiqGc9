/*
 * A services class specific to Enquiry Interest custom sObject
 * @author PwC
 * 
 */
public with sharing class EnquiryInterestServices {
    
    /**
    * when an interest is created against a case record, also link it to the person the case is linked to 
    * this event happens in console, which is not where we want this additional logic implemented
    */
	    public class linkInterestsToPerson implements Triggers.Handler {
	    	public void run(){
	    		
	    		Set<Id> caseIds = new Set<Id>();
	    		for(Enquiry_Interest__c interest : (List<Enquiry_Interest__c>)Trigger.new){
	    			if(interest.Case__c != null) caseIds.add(interest.Case__c);
	    		}
	    		
	    		Map<id,Case> cases = new Map<id,Case>([select id,
							    								contactId 
							    								from Case 
							    								where contactId != null and id in:caseIds]);
	    		
	    		// now for any enquiry interests that link to a case that has a person linked to it, link
	    		// the enquiry interest directly to the person as well.
	    		
	    		for(Enquiry_Interest__c interest : (List<Enquiry_Interest__c>)Trigger.new){
	    			if(interest.Case__c != null && interest.Person__c == null && cases.containskey(interest.case__c)){
	    				interest.Person__c = cases.get(interest.case__c).contactId;
	    			} 
	    		}
	    		
	    	}
	    	
	    }
    
    /** 
     * prevent deletion of enquiry interest by users when on closed cases, except by system admin users
     */
    public class preventDeletionOnClosedCases implements Triggers.Handler {
        public void run(){
            Set<id> caseIds = new Set<id>();
            for(Enquiry_Interest__c interest : (List<Enquiry_Interest__c>)Trigger.old) caseIds.add(interest.case__c);
            Map<id,case> cases = new Map<id,case>([select id,IsClosed from case where id in:caseIds]);
            for(Enquiry_Interest__c interest : (List<Enquiry_Interest__c>)Trigger.old){
                if(cases.get(interest.case__c).IsClosed) interest.addError('Not permitted to delete enquiry interests from closed cases.');
            }
        }
    }
}