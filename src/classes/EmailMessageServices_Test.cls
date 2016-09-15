/**
 * This class contains unit tests for validating the behavior of EmailMessageServices methods
 * these methods are part of the testing framework implemented throughout UniCRM
 * 
 */
@isTest
private class EmailMessageServices_Test {

    static testMethod void confirmEmailMapping(){
        
        List<Contact> testContacts = TestHelper.createStudentContacts(2, null);
	        
        insert testContacts;
        
        system.assertEquals(2,[select COUNT() from Contact],'test contacts not inserted');
        
        Set<Id> testContactIds = new Set<Id>();
        for(Contact testContact : testContacts) testContactIds.add(testContact.Id);
        
        List<case> cases = new List<case>();
        for(integer i=0; i<2; i++){
        cases.add(new case(SuppliedName = 'testName',
                          SuppliedPhone = '0400000000',
                          SuppliedEmail = 'testformEmail@monash.edu',
                          Type = 'Web',
                          Origin = 'Email - System',
                          Case_type__c = 'Standard Enquiry',
                          ContactId = null,
                          AccountId = null,
                          Course_code__c = '0',
                          Status = 'Closed'));
        }
        
        insert cases;
        cases[0].Origin = 'Email'; // telephony forces default to phone. need to use update
        cases[1].Origin = 'Email - System'; // telephony forces default to phone. need to use update

		update cases;
        
		List<EmailMessage> emails = new List<EmailMessage>();
        
        For(case c : cases)
        	emails.add(new EmailMessage( ParentId = c.id,
                                       	 FromAddress = 'testfrom@testmonash.edu',
                                         FromName = 'testSender',
                                         Subject = 'testSubject',
                                         TextBody = 'test body',
                                         ToAddress = 'testEndpoint@monash.edu',
                                         Incoming = true));    
        
        insert emails;
        
        system.assertEquals(false,[select id,IsClosed from case where id =:cases[0].id limit 1].IsClosed,'inbound should have opened case'); // non system
        system.assertEquals(true,[select id,IsClosed from case where id =:cases[1].id limit 1].IsClosed,'inbound should not have reopened case'); // system 
        
        EmailMessage em = new EmailMessage(ParentId = cases[1].id,
                                       	 FromAddress = 'testfrom@testmonash.edu',
                                         FromName = 'testSender',
                                         Subject = 'testSubject',
                                         TextBody = 'test body',
                                         ToAddress = 'testEndpoint@monash.edu',
                                          Incoming = true);
        insert em;
        system.assertEquals(false,[select id,IsClosed from case where id =:cases[1].id limit 1].IsClosed,'inbound should have opened case'); // system 2nd inbound email
        Set<id> caseIds = new Set<id>();
        
    }
    
}