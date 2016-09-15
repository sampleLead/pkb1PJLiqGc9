/**
 * This class contains unit tests for validating the behavior of CaseServices methods
 * these methods are part of the testing framework implemented throughout UniCRM
 * 
 */
@isTest
private class CaseServices_Test {

    
    /**
     * confirm web form links case to course correctly 
     */
        static testMethod void confirmCourseLinkingLogic(){
            
	         
	        List<course__c> courses = TestHelper.createCourses(10);
            courses[0].name = 'F2002';
            courses[0].course_code__c = '';
            courses[1].name = 'F2002';
            courses[1].course_code__c = 'F2002F20022';
            courses[2].name = 'F2002';
            courses[2].course_code__c = 'F2002F20021';
            insert courses;
	        
            
            // so have one course with specialisation, the other without and both have same name
	        List<case> cases = TestHelper.webToCaseForms(10);
	        for(integer i=0; i<cases.size(); i++){
                cases[i].Subject = 'test form'; 
	        	cases[i].SuppliedEmail = 'testEmail@testing.monash.edu';
	        	cases[i].Course_Specialisation__c = '';
                cases[i].Course_Code__c = String.valueOf(i);
            }
            cases[0].Course_Specialisation__c = '';
            cases[0].Course_code__c = 'F2002';
	        
            cases[1].Course_Code__c = 'F2002';
            cases[1].Course_Specialisation__c = 'F20022';
            
            cases[2].Course_Code__c = 'F2002';
            cases[2].Course_Specialisation__c = 'F20021';
            
	        Test.startTest();
            insert cases;
            
            case result0 = [ select course__c,course__r.name,course__r.specialisation__c from case where id =:cases[0].id limit 1];
            case result1 = [ select course__c,course__r.name,course__r.specialisation__c from case where id =:cases[1].id limit 1];
            case result2 = [ select course__c,course__r.name,course__r.specialisation__c from case where id =:cases[2].id limit 1];
            
            
            system.assertEquals(courses[0].id, result0.course__c,'should have matched to course code only');
            system.assertEquals(courses[1].id, result1.course__c,'should have matched to course + specialty # 1');
            system.assertEquals(courses[2].id, result2.course__c,'should have matched to course + specialty # 2');
            
            
            
            Test.stopTest();
        }
    
    
    
    
    //
    // confirm that inbound cases are linked to existing contacts where available as expected
    //
	    static testMethod void confirmCheckForAndLinkToContacts() {
	        
	        // setup so that half of cases to be inserted have existing contact, and half dont
	        // some will use monash email address, and some the personal email address
	        
	        List<Contact> testContacts = TestHelper.createStudentContacts(200, null);
	        
	        TriggerCommon.disableTrigger('Contact'); // have set up own alternate email addresses etc, so wont
	        insert testContacts;
	        TriggerCommon.enableTrigger('Contact');
	        
	        system.assertEquals(200,[select COUNT() from Contact],'test contacts not inserted');
	        
	        Set<Id> testContactIds = new Set<Id>();
	        for(Contact testContact : testContacts) testContactIds.add(testContact.Id);
	        
	        List<Case> webToCaseForms = TestHelper.webToCaseForms(10);
	        
	        
	        // set 5 forms to match monash email address
	        
	        for(integer index = 0; index < 5; index++){
	        	webToCaseForms[index].SuppliedEmail = testContacts[index].Monash_Email_Address__c;
	        }
	        for(integer index = 5; index < 10; index++){
	        	webToCaseForms[index].SuppliedEmail = testContacts[index].Applicant_Email_Address__c;
	        }
	        
	        Test.startTest();
	        
	        insert webToCaseForms;
	        
	        Set<Id> newFormIds = new Set<Id>();
	        for(Case caseObj : webToCaseForms) newFormIds.add(caseObj.id);
	        List<Case> updatedForms = [select id, suppliedName, contactId from Case where id in:newFormIds];
	        
	        Test.stopTest();
	        
	        // confirm 100 cases were matched 
	        system.assertEquals(10,
	        					[select COUNT() from Case where contactId != null and contactId in:testContactIds ],
	        					'incorrect linking of cases to existing contacts');
	        
	        	    }
	    
    
    //
    // validates that when a web-to-case form is passed into UniCRM, its record type can be set by a string field
    //
	    static testMethod void confirmConvertStringRecordTypeNameToAnId() {
	        
	        
	        List<Case> webToCaseForms = TestHelper.webToCaseForms(210);
	        
	        // set the forms to School Visit
	        
	        for(Case webCase : webToCaseForms) webcase.Case_Type__c = CaseServices.CASE_RECORDTYPENAME_SCHOOLENQUIRY;
	        
	        Test.startTest();
	        
	        insert webToCaseForms;
	        
	        Id schoolEnquiryTypeId = CommonServices.recordTypeId('Case', CaseServices.CASE_RECORDTYPENAME_SCHOOLENQUIRY);
	        
	        system.assertNotEquals(null, schoolEnquiryTypeId,'Record type not found');
	        
	        // confirm all the forms had their record type set to the appropriate value
	        
	        system.assertEquals(webToCaseForms.size(),
	        					[select COUNT() from Case where recordTypeId =:schoolEnquiryTypeId],
	        					'expected all inserted web forms to be of the correct record type');
	        
	        Test.stopTest();
	    }
    
    
    	static testMethod void otherTests(){
        	List<Contact> testContacts = TestHelper.createOrphanContactRecords(2);
            insert testContacts;
            
           	List<Case> cases = TestHelper.webToCaseForms(1);
            cases[0].Latest_Inbound_Email__c = datetime.now();
            insert cases;
            update cases; // to fire uniqueid logic
            
            List<course__c> courses = TestHelper.createCourses(10);
            insert courses;
            
            Test.startTest();
            
            CaseServices.clearCurrentCourseFields(cases[0]);
            CaseServices.populateCurrentCourseFields(cases[0], courses[0].name);
            
            
            
            // email flag clearing logic
            // 
            task t = new task( subject = 'test', whoId = cases[0].contactId, whatId = cases[0].id, activityDate = date.today(), status = 'Completed');
            insert t;
            
            system.assertEquals(null,
                                [select id, Latest_Inbound_Email__c from case where id =:cases[0].id limit 1].Latest_Inbound_Email__c,
                                'inbound email flag didnt clear as expected');
        
        
        	// run the ex log @future
        	CaseServices.storeExLog('a','b','c','test msg');
            
            Test.stopTest();
        }
    
    //
    // test business hours calcs against cases
    // 
        static testMethod void testQueueHours(){
            List<Contact> testContacts = TestHelper.createOrphanContactRecords(2);
            insert testContacts;
            
           	List<Case> cases = TestHelper.webToCaseForms(1);
            insert cases;
            
            Test.startTest();
            
            system.assertNotEquals(0,
                                [select count() from queueHours__c where case__c =:cases[0].id],
                                'No queue hours records have been setup');
            
            
            // confirm calcs working as expected
            
            string ownerId = [select id,ownerId from case where id =:cases[0].id].ownerId;
            queueHours__c qh = [select id,
                                		minutes__c,
                                		last_updated__c 
                                		from queueHours__c 
                                		where case__c =:cases[0].id and ownerIdString__c =:ownerId];
            system.assertNotEquals(null, qh.id, 'no queue hours record found');
            
            qh.minutes__c = 0;
            qh.Last_Updated__c = datetime.now().addHours(-20);
            update qh;
            
            Decimal timePassed = (BusinessHours.diff([select id from BusinessHours limit 1].id, datetime.now().addHours(-20), datetime.now())) / CaseServices.BUSINESS_HRS_MS_CONVERT_FACTOR;
            
		    id newQueueId = [select id from Group where Type = 'Queue' limit 1].id;
            cases[0].ownerId = newQueueId;
            update cases[0];
            
            system.assertEquals(timePassed,
                                [select minutes__c from queueHours__c where id =:qh.id limit 1].minutes__c,
                                'mins calc did not result as expected');
            
            // look at change in status only - from a clock stop status to a normal status. Time added should be zero
           	
            List<BH_Stop_Status__mdt> stopStatusLabels = new List<BH_Stop_Status__mdt>([SELECT Id, Label FROM BH_Stop_Status__mdt]);
            
            string originalStatus = cases[0].Status;
            
            cases[0].Status= stopStatusLabels[0].Label; // switch to a 'clock stop' status, where no time added i.e.'Awaiting response'
            update cases[0];
            
            // reset queue hours to 20 hours ago
            qh.minutes__c = 0;
            qh.Last_Updated__c = datetime.now().addHours(-20);
            update qh;
           
            cases[0].status = originalStatus;
            update cases[0];
            
            system.assertEquals(0,
                                [select minutes__c from queueHours__c where id =:qh.id limit 1].minutes__c,
                                'hours calc did not leave hours at zero as expected');
            
            
            Test.stopTest();
        }
    
    	static testMethod void reopenCaseScenario(){
        	List<Contact> testContacts = TestHelper.createOrphanContactRecords(2);
            insert testContacts;
            
           	List<Case> cases = TestHelper.webToCaseForms(1);
            insert cases;
            
            
            CaseStatus cs = [select id,masterlabel from casestatus where IsClosed = true limit 1];
            cases[0].Status = cs.masterlabel;
            cases[0]. Managing_Faculty__c  = 'someFaculty'; // to bypass validation rule
            update cases;
           
            cs = [select id,masterlabel from casestatus where IsClosed = false limit 1];
            cases[0].Status = cs.masterlabel;
            update cases;
            
            system.assertEquals(0,
                                [select count() from case where Enquiry_Reopened__c = null],
                                'field not set on reopening of case');
        }
}