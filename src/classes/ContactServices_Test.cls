/**
 * This class contains unit tests for validating the behavior of ContactServices methods
 * these methods are part of the testing framework implemented throughout UniCRM
 * 
 */
 
@isTest
private class ContactServices_Test {

    
    static testMethod void checkFieldMappingLogic(){
        list<Contact> testContacts = TestHelper.createOrphanContactRecords(1);
        testContacts[0].HasOptedOutOfEmail = false;
        testContacts[0].Country_of_Residence__c = 'AU';
        insert testContacts;
        system.assertNotEquals(null, testContacts[0].id,'contacts didnt insert as expected');
        
        // now create a case with mappings to pass to contact
        // 
        case c = new case(contactId = testContacts[0].id,
                          supplied_Email_Opt_out__c = true,
                          Supplied_Country_of_Residence__c = 'NZ');
        ContactServices.copyMappedFieldsToCaseContacts(new list<case>{ c });
        
        contact contactResult = [select id,HasOptedOutOfEmail,Country_of_Residence__c from contact where id =:testContacts[0].id limit 1];
        
        
    }
    
    
    static testMethod void testMontrackMethods(){
        
        list<Contact> testContacts = TestHelper.createOrphanContactRecords(1);
        insert testContacts;
        system.assertNotEquals(null, testContacts[0].id,'contacts didnt insert as expected');
        
        testContacts[0].MonTrack_Opt_Out__c = true;
        testContacts[0].MonTrack_Opt_Out_Reason__c = 'testing';
        ContactServices.updateMontrackFields(testContacts[0]);
        
        system.assertEquals('testing', 
                            [select id, MonTrack_Opt_Out_Reason__c from Contact where id =:testContacts[0].id].MonTrack_Opt_Out_Reason__c,
                            'contact didnt update as expected');
        
    }
    
    
    /**
    * confirm that on new contact insertion, if no account provided a new Individual Account is established
    * test bulk insert including duplicate contact names
    * test deletion performs cleanup
    */
    static testMethod void basicIndividualInsertionAndDeletion() {
        
        list<Contact> testContacts = TestHelper.createOrphanContactRecords(300);
        
        Test.startTest();
        
        insert testContacts;
        
        system.assertEquals(testContacts.size(),
                            [select COUNT() from Account where RecordTypeId =:CommonServices.RecordTypeId('Account',AccountServices.ACCOUNT_INDIVIDUAL_TYPE)],
                            'incorrect number of accounts with rtype individual created');
        
        
        delete TestContacts;
        
        system.assertEquals(0,
                            [select COUNT() from Account where RecordTypeId =:CommonServices.RecordTypeId('Account',AccountServices.ACCOUNT_INDIVIDUAL_TYPE)],
                            'incorrect number of accounts with rtype individual remain after deletion');
        
        Test.stopTest();
    }
    
    
    static testMethod void basicUpdate() {
        
        list<Contact> testContacts = TestHelper.createOrphanContactRecords(300);
        
        Test.startTest();
        
        insert testContacts;
        
        system.assertEquals(testContacts.size(),
                            [select COUNT() from Account where RecordTypeId =:CommonServices.RecordTypeId('Account',AccountServices.ACCOUNT_INDIVIDUAL_TYPE)],
                            'incorrect number of accounts with rtype individual created');
        
        for(integer i=0; i<testContacts.size(); i++){
            testContacts[i].firstname = 'different';
            testContacts[i].lastname ='test';
        }
        update testContacts;
        
        Test.stopTest();
        
        system.assertEquals(testContacts.size(),
                            [select COUNT() from Account where name = 'different test' ],
                            'incorrect update of account name');
        
        
    }
    
    
    /**
    * confirm that on new contact insertion, if error during insertion error handled correctly.
    * test bulk insert including duplicate contact names
    * test deletion handles error correctly
    */
    static testMethod void basicIndividualInsertionAndDeletionErrorHandling() {
        
        list<Contact> testContacts = TestHelper.createOrphanContactRecords(300);
        
        TestHelper.setupError('accountInsert'); // induces a one off error condition within the logic being tested
        
        Test.startTest();
        
        Database.SaveResult[] saveResults = Database.insert(TestContacts, false); // provide for partial inserts in bulk
        
        system.assertEquals(testContacts.size()-1,
                            [select COUNT() from Contact],
                            'incorrect number of contacts inserted');
            
        system.assertEquals(testContacts.size() - 1,
                            [select COUNT() from Account where RecordTypeId =:CommonServices.RecordTypeId('Account',AccountServices.ACCOUNT_INDIVIDUAL_TYPE)],
                            'incorrect number of accounts with rtype individual created');
        
        TestHelper.setupError('accountDelete'); // induces a one off error condition within the logic being tested
        system.assertEquals(true,TestHelper.throwError('accountDelete'));
        system.assertEquals(false,TestHelper.throwError('accountDelete'));
        TestHelper.setupError('accountDelete');
        
        List<Contact> contactsToDelete = new List<Contact>([select id from Contact]); // refresh list for next test
        delete contactsToDelete;
        
        system.assertEquals(1,
                            [select COUNT() from Exception_Log__c where Function_Name__c = 'ContactServices.cleanUpOrphanAccounts'],
                            'no error logged to Exception logs');
        
        Test.stopTest();
    }
    
    static testMethod void verifyMultipleEmailAddressBehaviour(){
        
        list<Contact> testContacts = TestHelper.createOrphanContactRecords(1);
        
        // prep for test use cases
        for(Contact testRecord : testContacts){
            testRecord.Applicant_Email_Address__c = '';
            testRecord.Monash_Email_Address__c = '';
        }
        
        Test.startTest();
        insert testContacts;
        
        
        
                            
        testContacts = TestHelper.retrieveContactRecords(); // pull in the updated records for further testing
        
        for(integer recCount = 0; recCount < testContacts.size(); recCount++) 
            testContacts[recCount].Email = String.valueOf(recCount) + 'nonmonash@somedomain.com.au';
            
        update testContacts;
        
        for(contact c : [select id,Email_Addresses__c from Contact])
            system.assert(c.Email_Addresses__c != null,
                            'expected all contact records to have email address history field set');
        
        
        
        
        
                
        // test deletion of contacts - should also have accounts removed
        
        Set<id> accountIds = new Set<Id>();
        for(contact c : testContacts) accountIds.add(c.accountId);
        delete testContacts;
        system.assertEquals(0,
                            [select count() from Account where id in:accountIds],
                            'should not be any accounts left');
        
        Test.stopTest();
    }
    
    
}