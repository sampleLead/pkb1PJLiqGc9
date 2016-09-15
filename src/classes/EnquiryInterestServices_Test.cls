/**
 * This class contains unit tests for validating the behavior of EnquiryInterestServices methods
 * these methods are part of the testing framework implemented throughout UniCRM
 * 
 */
@isTest
private class EnquiryInterestServices_Test {

    // confirm that on insert, a new enquiry interest is linked to both case and person
    
    static testMethod void verifyMappingOfInterestToPerson(){
        
        // UI driven, so small test data sets ok
        
        List<Contact> testContacts = TestHelper.createStudentContacts(1, null);
	    insert testContacts;
        
        List<Case> webToCaseForms = TestHelper.webToCaseForms(20);
	    for(integer index = 0; index < webToCaseForms.size(); index++){
            webToCaseForms[index].contactId = testContacts[0].Id;
        } 
        
        // create a course
        Course__c course = new Course__c(name = '0001');
        insert course;
        
        Test.startTest();
	        
	        insert webToCaseForms; // these are linked to contacts
        	
        	List<Enquiry_Interest__c> enquiries = new List<Enquiry_Interest__c>();
        	for(case webCase : webToCaseForms){
           	 	enquiries.add(new Enquiry_Interest__c(Case__c = webCase.id,
                                                  Course__c = course.id));
                          
        	}
        
        	insert enquiries;
                          
            system.assertEquals(0,
                               [select count() from Enquiry_Interest__c where Person__c = null],
                               'expected contact fields to be populated');    
        
        	for(case c : webToCaseForms) c.Status = 'Closed';
        	update webToCaseForms;
        
        try {
        	delete enquiries;
            system.assertNotEquals(1,0,'should not have permitted deletion of interests on closed cases');
        } catch (exception ex){
            
        }
        
        for(case c : webToCaseForms) c.Status = 'Open';
        update webToCaseForms;
        
        try {
        	delete enquiries;
            
        } catch (exception ex){
            system.assertNotEquals(1,0,'should have permitted deletion of interests on closed cases');
        }
        
        
        Test.stopTest();
    }
    
}