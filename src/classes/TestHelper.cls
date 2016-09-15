/**
 *	Utility class that provides test data creation methods
 * @author PwC
 */

public with sharing class TestHelper {
    
    
    /**
    * apply named permission sets to user supplied, names concatenated with ;
    * @param names names of permission sets, concatenated using semi-colon
    * @param usr the id of the user to apply the permissions to
    * @return void
    */
    public static void applyPermissionSets(String names, user usr){
        Set<string> psNames = new Set<string>();
        for(string nm : names.split(';')) psNames.add(nm);
        List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>();
        for(PermissionSet ps : [select id from PermissionSet where name in:psNames]){
            psaList.add(new PermissionSetAssignment(PermissionSetId = ps.id, AssigneeId = usr.id));
        }
        insert psaList;
    }
    
    /**
     * generate a list of emailmessage records
     * @param EmailMessage number of email messages to create
     * @param parentId the id of object to parent the messages
     * @param fromName the string containing 'from' for the email message
     * @param fromAddress the string containing from email address for the message
     * @param ToAddress the address that the email message is to be sent to
     * @return list of emailmessage records
     */ 
    public static list<EmailMessage> createEmailMessages(integer EmailMessage, 
                                                 id parentId, 
                                                 String fromName, String fromAddress, 
                                                 String ToAddress){
        list<EmailMessage> emails = new list<EmailMessage>();
        for(integer index=0; index < EmailMessage; index++){
            emails.add(new EmailMessage( subject = 'test email',
                                		parentId = parentId,
                                        textBody = 'test email body',
                                        htmlBody = '<p>test email body</p>',
                                        fromName = fromName,
                                        fromAddress = fromAddress,
                                        toAddress = ToAddress,
                                        MessageDate = Date.today().addDays(-10 * index)
                                        ));
        }
        return emails;
    }
    
    
    /**
    * generate a list of task records
    * @param numberOfTasks the number of task records to create
    * @param whoId the id of the contact to link the tasks to
    * @param whatId the id of another object to link the tasks to
    * @return list of task records
    */ 
    public static list<task> createTasks(integer numberOfTasks, id whoId, id whatId){
        list<task> tasks = new list<task>();
        for(integer index=0; index < numberOfTasks; index++){
            tasks.add(new Task( subject = 'test task',
                                activitydate = Date.today().addDays(-60).addDays(index),
                                description = 'test description',
                                whoId = whoId,
                                whatId = whatId,
                                Status = 'Completed',
                               Type = 'Other'));
        }
        return tasks;
    }
    
    /**
    * generate a list of attachments
    * @param numberOfAttachments the number of attachment records to create
    * @param parentId the id of the parent object for the attachments
    * @return list of attachment records
    */ 
    public static list<attachment> createAttachments(integer numberOfAttachments, id parentId){
        list<attachment> attachments = new list<attachment>();
        for(integer index=0; index<numberOfAttachments; index++){
            attachments.add(new attachment(name = 'att_'+String.valueOf(index),
                                           parentId = parentId,
                                           body = Blob.valueOf('testAttachment')));
        }
        return attachments;
    }
    
    /**
    * generate a list of course records
    * @param numberOfCourses the number of course__c records to setup
    * @return a list of course__c records
    */ 
    public static list<Course__c> createCourses(integer numberOfCourses){
        list<course__c> courses = new list<course__c>();
        for(integer index=0; index<numberOfCourses; index++){
            courses.add(new course__c(name = String.valueOf(index), 
                                      course_description__c = 'test course',
                                      specialisation__c = String.valueOf(index)+'specialty'));
        }
        return courses;
    }
    
    
    /**
    * generate test contact records that have no parent account record, so automation
    * will create the account records for them.
    * @param numberOfContacts the number of contact records to setup
    * @return list of contact records with no account id
    */
	    public static list<Contact> createOrphanContactRecords(integer numberOfContacts){
	    	return createStudentContacts(numberOfContacts,null);
	    }
    
    
    
    /**
    * ? redundant logic to generate PAs
    * <p>Can likely be factored out of logic layer altogether, once solution stable
    * @param numberOfStudents the number of student records to setup
    * @return list of account records that ? represent person accounts
    */
	    public static list<Account> createStudent(integer numberOfStudents){
	        
	        list<Account>  accounts = new  list<Account>();
	        Schema.DescribeSObjectResult descSobject =Account.SObjectType.getDescribe();
	        
	        Map<String,Schema.RecordTypeInfo> recordTypeInfoByName = descSobject.getRecordTypeInfosByName();
	        
	        Id recTypeID = recordTypeInfoByName.get('Individual').getRecordTypeId();
	        
	        // ? need an assert in here to confirm we get the record type, given its hardcoded ?
	        // need to refactor hardcoded string values over to helper/service classes
	        
	        for(integer studentNumber = 0; studentNumber < numberOfStudents; studentNumber++){
	            Account newAccount= new Account( 
	                                         Name='Account'+studentNumber,                                         
	                                         recordtypeid=recTypeID
	                                         );
	                accounts.add(newAccount);
	        }
	        return accounts;       
	    }
    
    
    /**
    * retrieve the test contact records
    * @return the contact records that have been inserted during test setup
    */
    	public static list<Contact> retrieveContactRecords(){
    		
    		return new list<Contact>([select id,
											firstName,
											lastName,
											Email,
											Monash_Email_Address__c,
											Applicant_Email_Address__c
											from Contact limit 500]);
    	}
    
    
    /**
    * builds a list of student contact records - ? redundant logic from the original UniCRM v1.
    * @param numberOfContacts the number of records to setup
    * @param accounts a list of accounts that student records are to be setup for on a 1:1 basis
    * @return list of contact records each having a parent account id prior to insert
    */
	    public static list<Contact> createStudentContacts(integer numberOfContacts, List<Account> accounts){
	       
	        list<Contact> newContacts = new  list<Contact>();
	        for(integer contactNumber =0; contactNumber < numberOfContacts; contactNumber++){
	            Id accountId = (accounts == null) ? null : accounts[contactNumber].Id;
	            Contact newContact= new contact( 
	                                         FirstName='Cruz'+ contactNumber,
	                                         LastName='John',                                         
	                                         AccountId= accountId,
	                                         MonTrack_Opt_Out__c=false,
	                                         Email = String.valueOf(contactNumber) + 'testemailAddress@monash.edu',
	                                         Monash_Email_Address__c = String.valueOf(contactNumber) + 'monashstudenttest@monash.edu',
	                                         Applicant_Email_Address__c = String.valueOf(contactNumber) + 'personaldomaintest@monash.edu'
	                                         );
	                                     
	                newContacts.add(newContact);
	        }
	        return newContacts;
	    }
    
    
    /**
    * creates a specific type of user (SSA) for Montrack testing purposes
    * @return a user record that has the SSA custom field set to true
    */
	    public static User ssaUser(){
	        	
        	User ssaUser = createTestUsers('System Administrator',1)[0];
        	ssaUser.SSA__c = true;
        	update ssaUser;
	        	
	        return ssaUser;
	    
	    }
    
    
    /**
    * create a list of campaign records for testing
    * @param numberOfCampaigns the number of campaign records to setup
    * @return a list of campaign records
    */
	    public static list<Campaign> createCampaign(integer numberOfCampaigns){
	        list<Campaign> newCampaigns = new list<Campaign>();
	        for(integer campaignNumber = 0; campaignNumber < numberOfCampaigns; campaignNumber++){
	            Campaign newCampaign = new Campaign(Name='My Campaign ' + campaignNumber);
	            newCampaigns.add(newCampaign);
	        }
	        return newCampaigns;
	    
	    }
    
    
    /**
    * creates a list of cohort records for testing
    * @param numberOfCohorts the number of cohort records to setup
    * @return a list of cohort records
    */
	    public static list<Cohort__c> createCohort(integer numberOfCohorts){
	        list<Cohort__c> newCohorts = new list<Cohort__c>();
	        for(integer cohortNumber = 0; cohortNumber < numberOfCohorts; cohortNumber++){
	            Cohort__c newCohort = new Cohort__c(Name='2014-1' + cohortNumber);
	            newCohorts.add(newCohort);
	        }
	        return newCohorts;
	    
	    }
	 
	    
    /**
    *	creates campaign member records that map to a specific cohort and ssa for testing
	* @param ssaID the Id of an existing SSA user
	* @param cohortID the Id of an existing cohort record
	* @param CampaignID the Id of an existing campaign record
	* @param contactIds a set of contact ids of existing records that need to be linked to cohort etc for testing
	* @return a list of campaign member records setup to support MonTrack testing
    */
	    public static list<CampaignMember> createCampaignMember(ID ssaID, 
	                                                            ID cohortID, 
	                                                            ID CampaignID,
	                                                            Set<ID> contactIds){
	        
	        list<CampaignMember> newCampaignMembers = new list<CampaignMember>();
	        for(ID contactId:contactIds){
	            CampaignMember newCampaignMember = new CampaignMember(Cohort__c=cohortID,
					                                                  SSA__c=ssaID,
					                                                  CampaignID=CampaignID,
					                                                  ContactID=contactId);
	                        newCampaignMembers.add(newCampaignMember);
	        }
	        return newCampaignMembers;
	    }
    
    
    /**
    *	create a list of round records for testing MonTrack functionality
	* @param cohortId the id of an existing cohort to link the round to
	* @param CampaignID the id of an existing campaign to link the round to
	* @param ctr the number of rounds to setup
	* @return a list of round records all linked to cohort,campaign etc as required
    */
	    public static list<Round__c> createRounds(ID cohortID, 
	                                              ID CampaignID,
	                                              Integer ctr){
	        
	        List<Round__c> newRounds = new list<Round__c>();
	        for(Integer i=0;i<ctr;i++){
	            Round__c newRound= new Round__c(Campaign__c=CampaignID,
	                                     		Cohort__c=cohortID,
	                                     		Round_Number__c=String.valueof(i+1) );
	            
	            newRounds.add(newRound);   
	        
	        }                                         
	        return newRounds;                                             
	                                              
	    }
    
    
    /**
    *  create topics records for testing purposes
    *  @param roundId the id of an existing round record to link to
    *  @param SSAId the id of an existing SSA user to link to 
    *  @param contactId the id of a Montrack test contact record
    *  @param numberOfTopics the number of topic records to return
    *  @return a list of topic records all linked as required for Montrack testing
    */
	    public static list<Topic__c> createTopics(ID roundID,
	                                            ID SSAID,
	                                            ID contactID,
	                                            Integer numberOfTopics){
	        list<Topic__c> topics = new List<Topic__c>();
	        for(Integer topicNumber =0; topicNumber < numberOfTopics; topicNumber++){
	            Topic__c newTopic= new Topic__c(Round__c=roundID, 
	                                            SSA_Identified__c=SSAID, 
	                                            Type__c='General', 
	                                            Description__c='Other',
	                                            Student__c=contactID);
	            topics.add(newTopic);
	        }       
	        return topics;                             
	    }


	/**
    * insert a custom setting record used to mute a trigger
    * @param username the name of user to insert trigger mute setting for
    * @param triggerString a string of triggers to be muted, concatenated via ','
    */
	    public static void createTriggerMutingCustomSetting(String username, String triggersString){
	    	TriggerMuteRequest__c request = new TriggerMuteRequest__c(Name = username,
	    															  TriggersList__c = triggersString);
	    	insert request;														  
	    }
	    
    
    /**
    /* setup Test user data
     * @param profileName a string containing the profile to use for the new users
     * @param numberOfusers the number of user records to setup
     * @return a list of user records that have been inserted, so have ids ready for use
    */ 
	    public static List<User> createTestUsers( String profileName , integer numberOfUsers){
	        Id profileId = [select id from Profile where name =:profileName limit 1].Id;
	        system.assertNotEquals(null,profileId,'No user profile found for user setup');
	        
	        List<User> users = new List<User>();
	        
	        for(Integer userCount = 0; userCount < numberOfUsers; userCount++){
		        Integer rnd = Integer.valueOf(Math.random()*9999);
		        users.add(new User(Alias = String.valueOf(rnd)+ 'usr', 
		                        Email= String.valueOf(rnd) +'testuser@monash.edu', 
		            			EmailEncodingKey='UTF-8', 
		                        LastName='TestingUser', 
		                        LanguageLocaleKey='en_US', 
		            			LocaleSidKey='en_GB', 
		                        ProfileId = profileId, 
		            			TimeZoneSidKey='Australia/Sydney', 
		                        UserName= String.valueOf(rnd) +'testuser@monash.edu'));
	        }
	        insert users;
	        return users;
	    }
	
	
	/**
	* static map of simulated errors to throw during testing
	* <p>if dev wants to simulate errors in testing, then can incorporate this logic into codebase.
	* @return a set of custom error types described as strings.
	*/
		private static Set<string> errorsToThrow {
			get{
				if(errorsToThrow == null) errorsToThrow = new Set<string>();
				return errorsToThrow;
			}
			private set;
		}
	
	/**
	* store an error simulation request
	* @param errorType the name of the error that dev wants to test
	* @ return void
	*/
		public static void setupError(String errorType){
			errorsToThrow.add(errorType);
		}
	
	/**
	* confirm if error simulation should go ahead or not
	* @param errorType string value for dev custom error that is to be checked for
	* @return boolean of true if error is to be thrown, otherwise false
	*/
		public static Boolean throwError(String errorType){
			if(Test.isRunningTest() && errorsToThrow.contains(errorType)){
				errorsToThrow.remove(errorType); // only permit error to fire once per time it is set
				return true;
			} else {
				return false;
			}
		}
	
	/**
	* create a list of simple web to case forms
	* @param numberOfForms the number of web form cases to setup
	* @return a list of case records
	*/
		public static List<Case> webToCaseForms(Integer numberOfForms){
			
			List<Case> cases = new List<Case>();
			
			for(integer formNumber = 0; formNumber < numberOfForms ; formNumber++){
				cases.add(new Case( SuppliedName = 'testName',
									SuppliedPhone = '0400000000',
									SuppliedEmail = String.valueOf(formNumber) + 'testformEmail@monash.edu',
									Type = 'Web',
									Case_type__c = '',
									ContactId = null,
									AccountId = null,
                                    Course_code__c = '0'));
			}
			
			return cases;
		}
	
	
		
}