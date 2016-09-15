/**
 * This class contains unit tests for validating the behavior of UserServices methods
 * these methods are part of the testing framework implemented throughout UniCRM
 * 
 */
@isTest
private class UserServices_Test {

    static testMethod void testUserInfoClearout(){
        
        User usr = TestHelper.createTestUsers('Base Profile',1)[0];
        usr.Queue__c = 'test';
        usr.Location__c = 'test';
        usr.Enquiry_Role__c = 'test';
        update usr;
        
        System.runAs(usr){
            UserServices.resetMyInformation();
        }
        
        usr = [select id,queue__c,location__c,enquiry_role__c from User where id =:usr.id limit 1];
        
        system.assertEquals(null, usr.queue__c);
        system.assertEquals(null, usr.Location__c);
        system.assertEquals(null, usr.Enquiry_Role__c);
    }
    
}