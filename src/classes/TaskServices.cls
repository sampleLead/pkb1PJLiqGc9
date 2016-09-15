/**
 * Services class to provide Task sObject centric logical support
 * 
 * @author Carl Vescovi, PwC
 * 
 */
public without sharing class TaskServices {
    
    public static final String FIRST_ATTEMPT = 'First Attempt';
    public static final String SECOND_ATTEMPT = 'Second Attempt';
    public static final String THIRD_ATTEMPT = 'Third Attempt';
    public static final String MONTRACK_CALL_SUBJECT = 'MonTRACK Call Attempt';
    public static final String COMPLETED = 'Completed';
    public static final String NOT_APPLICABLE = 'Not Applicable';
    public static final String NOT_STARTED = 'Not Started';
    
    /** update task records without sharing restrictions 
	 * @param tsks list of task records to update
	 */
    
    public static void updateTaskRecords(List<Task> tsks){
        update tsks;
    }
    
    /** delete task records without sharing restrictions 
 	 * @param tsks list of tasks to delete
	 */
    
    public static void deleteTaskRecords(List<Task> tsks){
        delete tsks;
    }
    
    /** copy fields from contact record over to Task, if Task is of a specific record type. 
	 * This is used specifically where standard reporting cannot aggregate information from multiple objects i.e.
	 * MonTrack Round - to Task - to Contact.
	*/
    public class considerTaskFieldMappings implements Triggers.Handler {
        public void run(){
            // copy mapped fields from Contact to task record depending on task record type
            List<Contact_to_Task_Field_Mapping__mdt> fieldMappings = 
                new List<Contact_to_Task_Field_Mapping__mdt>([ SELECT Id, 
                                                                      Contact_field_API_name__c, 
                                                                      Task_field_API_name__c,
                                                              		  Task_Record_Type__c
            														  FROM Contact_to_Task_Field_Mapping__mdt limit 400]);
			
            // build a map of task record type ids 
            Map<id,string> recordTypeIds = new Map<id,string>();
            for(Recordtype rt : [select id, developerName from RecordType where SObjectType = 'Task' limit 50]) 
                recordTypeIds.put(rt.id,rt.developername.tolowercase());
            
            // build a query string to ensure retrieval of all fields that may be wanted from contact if mapping to be done
			string qry = 'select ';
            for(Contact_to_Task_Field_Mapping__mdt fld : fieldMappings) qry += fld.Contact_field_API_name__c + ',';
            qry += 'Id from contact where id in:contactIds limit 200';    
            
            
            // retrieve contacts linked to tasks via whoId
            Set<id> contactIds = new Set<id>();
            for(task tsk : (List<Task>)Trigger.new) { if(tsk.whoId != null) contactIds.add(tsk.whoId); }
            
            Map<id,Contact> contacts = new Map<id,contact>();
            for(Contact c : Database.query(qry)) contacts.put(c.id,c);
            
			// loop through tasks, consider record type and if there are mappings then map
            for(Task tsk : (List<Task>)Trigger.new){
                if(tsk.whoId != null && contacts.containsKey(tsk.whoId) ){
                    // check mappings for possibles
                    for(Contact_to_Task_Field_Mapping__mdt mapping : fieldMappings){
                        if(recordTypeIds.get(tsk.recordTypeId) == mapping.Task_Record_Type__c.tolowercase()) 
                            tsk.put(mapping.Task_field_API_Name__c,contacts.get(tsk.whoId).get(mapping.Contact_field_API_Name__c));
                        
                    }
                }
            }
        }
    }	
    
    /** if is a wrap up task (inserted by workflow action) then set the Type to 'Wrap up' 
	 * This is done via trigger so that can insert a normally unavailable value into picklist field - cannot be achieved via config
	*/
    public class considerWrapUpTasks implements Triggers.Handler {
        public void run(){
            for(Task tsk : (List<task>)Trigger.new){
                if(tsk.Subject == 'Wrap Up Task' && tsk.Description == 'Enquiry wrapped up') tsk.Type = 'Wrap Up';
            }
        }
    }
}