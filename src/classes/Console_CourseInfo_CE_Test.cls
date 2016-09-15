/**
 * Test class for the Console_CourseInfo_CE custom controller extension class.
 * These methods are part of the testing framework implemented throughout UniCRM
 */
@isTest
private class Console_CourseInfo_CE_Test {
	
    @testSetup 
    static void setupTestData(){
    	// if test data required, establish here	
    	
        List<contact> contacts = TestHelper.createOrphanContactRecords(10);
        integer offset = 1;
        for(contact c : contacts) { 
            c.birthdate = date.newInstance(1975,1,1);
            c.Person_Id_unique__c = String.valueOf(12345+offset);
        	offset++;
        }
        insert contacts;
        system.assertNotEquals(null, contacts[0].id,'contacts didnt insert as expected');
        
        // add some person notes
        List<Person_Note__c> notes = new List<Person_note__c>();
        for(contact c : contacts) notes.add(new Person_note__c(contact__c = c.id, type__c = 'type', important__c = true, notes__c = 'test note'));
        insert notes;
        system.assertNotEquals(null, notes[0].id,'notes didnt insert as expected');
        
        List<Case> cases = TestHelper.webToCaseForms(1);
        cases[0].contactId = contacts[0].id;
        cases[0].Enquiry_Type__c = CaseServices.CURRENT_COURSE;
    	insert cases;
        
        // append some enquiry interests
        List<course__c> courses = TestHelper.createCourses(2);
        courses[0].name = '123445';
        insert courses;
        system.assertNotEquals(null, courses[0].id,'courses didnt insert as expected');
        
        List<Enquiry_Interest__c> interests = new List<Enquiry_Interest__c>();
        for(contact c : contacts){
            for(course__c course : courses){
                for(case cse : cases)
                    interests.add(new Enquiry_Interest__c(course__c = course.id, person__c = c.id, case__c = cse.id));
            }
        }
        
        insert interests;
        system.assertNotEquals(null, interests[0].id,'interests didnt insert as expected');
    }
    
    static testMethod void testCourseInfoLogic(){
        
        PageReference pg = Page.Console_courseInfo_v2;
        Test.setCurrentPage(pg);
        
        Case cse = [select id from case where case.contact.Person_ID__c != null limit 1];
        ApexPages.StandardController stdCase = new ApexPages.StandardController(cse);
        
        Console_CourseInfo_CE con = new Console_CourseInfo_CE(stdCase);
        
        con.initalLoad();
        system.assertNotEquals(null, con.courseAPIResult, 'initial load did not initiate as expected');
        
        Boolean res = con.renderTable;
        con.unlinkFromCase();
        
        course__c crse = [select id,name from course__c where name = '123445' limit 1];
        con.courseIdSelected = crse.name + ':' + crse.id;
        con.linkToCase();
        
        
    }
    
}