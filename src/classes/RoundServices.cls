/*
 * A services class specific to Round__c sObject
 *@author PwC
*/

public class RoundServices {
    
    
    public static String MONTRACK_RECORDTYPE_NAME = 'MonTrack';
    
    
    //
    // executes a batch job that sets up future task records for montrack functionality
    //
    	public class createMontrackTasks implements Triggers.Handler {
	    	public void run(){
	    		
	    		Id batchInstanceId = Database.executeBatch(new mt_createTaskBatch((List<Round__c>)trigger.new)); 
	    	}
	    }
}