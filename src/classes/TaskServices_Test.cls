/**
 * This class contains unit tests for validating the behavior of TaskServices methods
 * these methods are part of the testing framework implemented throughout UniCRM
 * 
 */
@isTest
private class TaskServices_Test {
	
    static testMethod void testMapping(){
        List<Contact_to_Task_Field_Mapping__mdt> fieldMappings = 
                new List<Contact_to_Task_Field_Mapping__mdt>([ SELECT Id, 
                                                                      Contact_field_API_name__c, 
                                                                      Task_field_API_name__c,
                                                              		  Task_Record_Type__c
            														  FROM Contact_to_Task_Field_Mapping__mdt 
                                                             		  where Task_Record_Type__c = 'Montrack' and
                                                             		  Contact_field_API_name__c = 'LastName']);
        system.assert(!fieldMappings.isEmpty(),'No field mappings to test with');
        
        List<Contact> testContacts = TestHelper.createStudentContacts(1, null);
        insert testContacts;
        
        id taskRecordType = [select id from RecordType where SObjectType = 'Task' and DeveloperName = 'Montrack' limit 1].id;
        
        Task t = new task(recordtypeId = taskRecordType,
                         subject = 'test',
                         whoId = testContacts[0].id,
                         last_name__c = '');
        insert t;
        system.assertEquals(testContacts[0].lastname,
                           [select last_name__c from task where id =:t.id limit 1].last_name__c,
                           'last name didnt map to task as expected');
        
        
        TaskServices.updateTaskRecords(new list<task>{ t });
        
        TaskServices.deleteTaskRecords(new list<task>{ t });
    }
}