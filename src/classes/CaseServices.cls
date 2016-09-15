/**
 * Services class to provide Case sObject centric logical support
 * 
 * @author Carl Vescovi, PwC
 * 
 */
public class CaseServices {
    
    public static final boolean POPULATE_ENQUIRY_INTEREST_COUNT = true; 
    private static final String MONASH_CONNECT_OFFICER = 'Monash Connect Officer';
    public static final String CASE_RECORDTYPENAME_SCHOOLENQUIRY = 'School Enquiry';
    private static final String FORCE_SIGN_IN = 'true';
    private static final String FACE_TO_FACE = 'Face to Face';
    private static final String CUSTOMER_QUEUE_DETAILS_EXCEPTION = 'CustomerQueueDetailsException';
    
    public static final Integer BUSINESS_HRS_MS_CONVERT_FACTOR = 60000; // converts ms to mins
    public static final String CASE_MONASH_CONNECT_RECORDTYPE = 'Standard Enquiry';
    
    public static final String CURRENT_COURSE = 'Current Course';
    public static final String FUTURE_COURSE = 'Future Course';
    
    private static Set<string> stopStatusLabels;
    
    private static Id businessHoursId {
        get{
            if(businessHoursId == null){
                businessHoursId = [select id from BusinessHours limit 1].id;
            }
            return businessHoursId;
        }
        set;
    }
    
    /**
     * populates a field pre update, that is used for validation purposes at enquiry update. 
     * If functionality disabled, then the value 99 is used so can be ignored at validation rule execution
     */ 
    public class performValidation implements Triggers.Handler {
        public void run(){
            
				Map<id,Case> cases = (Map<id,Case>)Trigger.newMap;
                for( case cse : [select id,(select id from enquiry_interests__r limit 1) from case where id in:cases.keySet()]){
                    system.debug('** adding enquiry interest count **'
                    );
                    ((Map<id,Case>)Trigger.newMap).get(cse.id).Enquiry_Interest_Count_at_Update__c = (POPULATE_ENQUIRY_INTEREST_COUNT) ? cse.enquiry_interests__r.size() : 99 ;
                }
            
        }
    }
    
    
    
    /** 
     * future method to log errors from console web service callouts, 
     * to prevent 'you have work pending' issues on subsequent callouts
     *
     * @param proc describes the process that was in progress
     * @param cls  name of the class that the error occured in
     * @param meth name of the method that the error occured in
     * @param msg the message that the exception returned
     */
        @future 
        public static void storeExLog(string proc, string cls, string meth, string msg){
            system.debug('** Err logged - '+proc+':'+cls+':'+meth+':'+msg);
            ExLog.write(proc, cls, meth, msg);
        }
    
    
    /**
     * if a case has had a contact linked to it AND the 'copy info over' flag is set on contact, 
     * then time to copy fields over to contact record
     *
     */ 
        public class copyCaseFieldsOverToLinkedContact implements Triggers.Handler {
            public void run(){
                
                Map<id,case> caseMap = (Map<id,case>)Trigger.newMap;
                list<contact> contactUpdates = copyMappedFieldsToCaseContact(caseMap.keySet());
                if(!contactUpdates.isEmpty()){
                    update contactUpdates;
                    
                }
            }
        }
    
    
    /**
     * copy mapped fields from case to contact.
     * <p>
     * Used when console user wants to create a new contact from an inbound web enquiry
     * with fields copied over to the new contact record such as email address and name.
     * only cases that have the 'Copy from Enquiry' field set to true are considered.
     * <p> 
     * Leverages custom metadata to determine mappings (Case_to_User_Field_Mapping__mdt)
     * 
     * @param caseIds a set of case Ids defining scope of activity
     * @return list of contact records that have had fields copied over from cases
     * @see checkForAndLinkToContacts
     *
     */
        public static list<contact> copyMappedFieldsToCaseContact( Set<id> caseIds){
            List<contact> contacts = new List<contact>();
            
            // copy mapped fields from Case to contact record
            List<Case_to_Contact_Field_Mapping__mdt> fieldMappings = 
                new List<Case_to_Contact_Field_Mapping__mdt>([ SELECT Id, 
                                                                      Case_API_name__c, 
                                                                      Contact_Field_API_name__c  
            														  FROM Case_to_Contact_Field_Mapping__mdt limit 400]);
            
            // query all case records in scope, ensuring we retrieve the fields of interest, 
            // and only records where contact wants info copied over
            
            string qry = 'select ';
            for(Case_to_Contact_Field_Mapping__mdt mapping : fieldMappings) qry += mapping.Case_API_name__c + ',';
            qry += 'Id,contactId from case where id in:caseIds and contact.Copy_from_Enquiry__c = true';
            
            // get cases
            
            for(case cse : Database.query(qry)){
                string errMsg = '';
                contact c = new contact(id = cse.contactid, Copy_from_Enquiry__c = false);
                for(Case_to_Contact_Field_Mapping__mdt fieldMapping : fieldMappings){
                    try{
                        if(cse.get(fieldMapping.Case_API_name__c) != null) {
                            c.put(fieldMapping.Contact_Field_API_name__c , cse.get(fieldMapping.Case_API_name__c));
                        }
                    } catch (exception ex){
                        errMsg = ex.getMessage(); 
                    }
                }    
                if(errMsg != '') {
                    Exlog.write('ContactServices','copyMappedFieldsToCaseContact','mapping to contact','This case couldnt be mapped to contact:'+ errMsg + ' -> ' + JSON.serialize(cse));
                } else {
                    contacts.add(c);
                }               
            }    
            return contacts;
        }
    
    /**
     * if is an inbound case via webform - as defined by suppliedName != null - then add a course interest record
     * <p>
     * Addresses the need to have all course interests represented consistently
     * ie. via a course interest record.
     */
        public class addCourseInterests implements Triggers.Handler {
            public void run(){
                List<Enquiry_Interest__c > interests = new List<Enquiry_Interest__c >();
                Set<id> caseIds = new Set<id>();
                caseIds = ((Map<id,Case>)Trigger.newMap).keySet();
                for(Case cse : [select id,
                                origin,
                                contactid,
                                course__c,
                                course__r.Managing_Faculty__c,
                                course__r.Faculty_Code__c,
                                Supplied_Area_of_Interest__c,
                                Supplied_Name_of_Institution__c,
                                Commencement_Year__c,
                                Level_of_Study__c
                                from Case where 
                                (id in:caseIds and suppliedName != null) and
                                (course__c != null or managing_faculty__c > '' or Supplied_Area_of_Interest__c > '')]){
                       string managingFaculty = (cse.course__r.Managing_Faculty__c > '') ? cse.course__r.Managing_Faculty__c  :'';
                       string facultyCode = (cse.course__r.Faculty_Code__c > '') ? cse.course__r.Faculty_Code__c : '';
                       string suppliedInterest = (cse.Supplied_Area_of_Interest__c > '') ? cse.Supplied_Area_of_Interest__c : '';
                       string commencementYear = (cse.Commencement_Year__c > '') ? cse.Commencement_Year__c : '';
                       string nameOfInstitution = (cse.Supplied_Name_of_Institution__c > '') ? cse.Supplied_Name_of_Institution__c : '';
                       
                       if(cse.origin != null && cse.origin.indexOf('Email') == -1){ // exclude the inbound email variants   
                          interests.add(
                            new Enquiry_Interest__c(Course__c = cse.Course__c,
                                                    Case__c = cse.id,
                                                    Person__c = cse.contactId,
                                                    Study_Area__c = suppliedInterest,
                                                    Managing_Faculty__c = managingFaculty,
                                                    Managing_Faculty_Code__c = facultyCode,
                                                    Level_of_Study__c = cse.Level_of_Study__c,
                                                    commencement_year__c = commencementYear,
                                                    Name_of_Institution__c = nameOfInstitution));
                       }
                }
                if(!interests.isEmpty()) insert interests;
            }
        }   
    
    
    
    /**
     * returns the number of business minutes passed since record was last updated
     * @param qh queue business hours record
     * @return decimal business mins passed between now and last update 
     */
        private static Decimal addBusinessHrs(queueHours__c qh){
            // return hours in bh between last modified and now
            return (qh.Last_Updated__c == null) ? 0 : Integer.valueOf(BusinessHours.diff(businessHoursId, qh.Last_Updated__c, datetime.now()) / BUSINESS_HRS_MS_CONVERT_FACTOR );
        }
    
    
    
    /**
     * generate a new queue hours record for a specific case
     * @param cse case that new record is to be linked to
     * @return new queue hours record
     */
        private static queueHours__c newQueueHoursRecord(case cse){
            string userRole = (UserServices.userRoleName.containsKey(cse.ownerId)) ? UserServices.userRoleName.get(cse.ownerId) : '';
            return new queueHours__c( Case__c = cse.id,
                                        OwnerIdString__c  = cse.ownerId,
                                        Last_Updated__c = datetime.now(),
                                        Minutes__c = 0,
                                        UniqueId__c = (string)cse.id + (string)cse.ownerId,
                                        Owner_Name__c = UserServices.userOrGroupName.get(cse.ownerId),
                                        User_Role__c = userRole);
        }
    
    /**
     * confirms if clock should be ticking or not depending on case status
     * @param cse case record to be checked
     * 
     */
        private static boolean shouldIncrement(case cse){
            return !(stopStatusLabels.contains(cse.status));
        }
    
    
    /**
     * at case update, update business hours calcs
     *<p>
     * passed a set of case records that have changed , 
     * logic reviews change of status, owner or both and maintains
     * associated queue business hour records accordingly
     * 
     *
     */
        public class maintainBusinessHours implements Triggers.Handler {
            public void run(){
                
                // retrieve possible 'stop statuses' from custom metadata
                // 
                stopStatusLabels = new Set<string>();
                for(BH_Stop_Status__mdt status : [SELECT Id, Label FROM BH_Stop_Status__mdt limit 50]) 
                    stopStatusLabels.add(status.Label);
                
                
                Set<id> caseIds = new Set<id>();
                Map<string, queueHours__c> hours = new Map<string,queueHours__c>();
                
                // loop thru cases, if change owner or status then process accordingly
                // 
                Map<id,Case> newCases = (Map<id,Case>)Trigger.newMap;
                Map<id,Case> oldCases = (Map<id,Case>)Trigger.oldMap;
                
                for(id cid : newCases.keySet()){
                    case newc = newCases.get(cid);
                    case oldc = oldCases.get(cid);
                    if(fieldHasChanged('Status', newc, oldc) || fieldHasChanged('OwnerId', newc, oldc)){
                        caseIds.add(newc.id);
                    }
                }
                
                if(!caseIds.isEmpty()){
                    
                    // retrieve and store all bh records that are within scope of the case records being updated
                    // 
                    for(queueHours__c qh : [select id, 
                                                uniqueId__c, 
                                                ownerIdString__c,
                                                minutes__c,
                                                last_updated__c,
                                                owner__c,
                                                owner_name__c,
                                                case__c from queueHours__c where case__c in:caseIds]){
                        hours.put(qh.uniqueId__c, qh); 
                    }
                    
                    // process each affected case in turn. 
                    // In this loop all have either changed status, changed owner or both
                    // 
                    for(id cid : caseIds){
                        
                        case newc = newCases.get(cid); 
                        case oldc = oldCases.get(cid); 
                        string newKey = (string)newc.id + (string)newc.OwnerId ;
                        string oldKey = (string)oldc.id + (string)oldc.OwnerId ;
                        
                        
                        queueHours__c newOwnerQH = (hours.containsKey(newKey)) ? hours.get(newKey) : newQueueHoursRecord(newc);
                        queueHours__c oldOwnerQH = (hours.containsKey(oldKey)) ? hours.get(oldKey) : newQueueHoursRecord(oldc); 
                        if(oldOwnerQH.minutes__c == null) oldOwnerQH.minutes__c = 0;
                        if(newOwnerQH.minutes__c == null) newOwnerQH.minutes__c = 0;
                        
                        // 3 scenarios (excluding no change to owner or status)
                        // 1 - change owner and status
                        if(newKey != oldKey && newc.Status != oldc.Status){
                            oldOwnerQH.minutes__c += (shouldIncrement(oldc)) ? addBusinessHrs(oldOwnerQH) : 0; // maintain the previous owners QH record
                            oldOwnerQH.Last_Updated__c = datetime.now();
                            newOwnerQH.Last_Updated__c = datetime.now(); // start clock from now
                        } else
                        // 2 - change owner not status
                        if(newKey != oldKey && newc.Status == oldc.Status){
                            oldOwnerQH.minutes__c += (shouldIncrement(oldc)) ? addBusinessHrs(oldOwnerQH) : 0; // maintain the previous owners QH record
                            oldOwnerQH.Last_Updated__c = datetime.now();
                            newOwnerQH.Last_Updated__c = datetime.now(); // start clock from now
                        } else
                        // 3 - change status not owner
                        if(newKey == oldKey && newc.Status != oldc.Status){
                            oldOwnerQH.minutes__c += (shouldIncrement(oldc)) ? addBusinessHrs(oldOwnerQH) : 0; // maintain the previous owners QH record
                            oldOwnerQH.Last_Updated__c = datetime.now();
                            
                        } 
                        if(oldOwnerQH.Owner_Name__c == null) oldOwnerQH.Owner_Name__c = UserServices.userOrGroupName.get(oldOwnerQH.OwnerIdString__c);
                        if(newOwnerQH.Owner_Name__c == null) newOwnerQH.Owner_Name__c = UserServices.userOrGroupName.get(newOwnerQH.OwnerIdString__c);
                        
                        
                        hours.put(oldOwnerQH.UniqueId__c, oldOwnerQH);
                        if(newKey != oldKey) hours.put(newOwnerQH.UniqueId__c, newOwnerQH); // only need this record if ownership has changed.
                          
                        
                        
                    }
                    upsert hours.values() uniqueId__c;
                }
            }
        }
    
    
    /**
     * sets up business hours records at case insert
     * <p>
     * uses upsert process to prevent duplication
     *
     */  
        public class setupBusinessHours implements Triggers.Handler {
            public void run(){
                List<queueHours__c> hours = new List<queueHours__c>();
                // webforms pass a different string than the name of the standard enquiry record type
                string recTypeName = 'Monash Connect Enquiry';
                for(Case cse : (List<Case>)Trigger.new){
                    if(cse.RecordTypeId == CommonServices.recordTypeId('Case', CASE_MONASH_CONNECT_RECORDTYPE )) hours.add(newQueueHoursRecord(cse));
                }
                upsert hours uniqueId__c;
            }
        }
    
    
    
    /**
     * map course code text to a course code record on insert.
     * if specialisation has been passed in, then use that field over basic course code
     * 
     */
        public class mapCourseCode implements Triggers.Handler {
            public void run(){
                Set<String> courses = new Set<String>();
                for(Case cse : (List<Case>)Trigger.new) {
                    if(cse.Course_Code__c > '') courses.add(cse.Course_Code__c); // eg D6001
                    if(cse.Course_Specialisation__c > '' && cse.Course_Specialisation__c > '') courses.add(cse.Course_Code__c + cse.Course_Specialisation__c); // eg D6001D60013
                }
                if(!courses.isEmpty()){
                    Map<string,course__c> courseInfo = new Map<string,course__c>();
                    for(course__c course : [select id,
                                                    name, 
                                                    course_code__c  
                                                    from course__c 
                                                where name in:courses or Course_Code__c in:courses limit 4000 ]) {
                        string courseCode = course.name.tolowercase();
                        string specialisation = (course.Course_Code__c > '' ) ? course.Course_Code__c.tolowercase() : '';
                        if(specialisation > '') courseInfo.put(specialisation, course);
                        if(specialisation == '') courseInfo.put(courseCode, course);
                    }
                   
                    // loop checks preferentially for specialisation first if it exists, then major                     
                    
                    for(Case cse : (List<Case>)Trigger.new){
                        
                        if(cse.course__c == null && (cse.course_code__c > '' || cse.course_specialisation__c > '')){
                            // look for a match on specialisation alone first - would be a course code that covers off specialisation
                            string spec = (cse.course_specialisation__c > '') ? cse.Course_Specialisation__c.tolowerCase() : '';
                            string course = (cse.course_code__c > '') ? cse.Course_Code__c.tolowerCase() : '';
                            if(spec > '' && courseInfo.containsKey(course + spec)) { cse.course__c = courseInfo.get(course + spec).id; } // eg F2002F20021
                            else
                            // look for course code only, with no specialisation
                            if(courseInfo.containsKey(course)) cse.course__c = courseInfo.get(course).id; // eg F2002
                                
                            
                        }
                    }
                }
            }
        }
    
    
    
    /**
     * monitors case changes for case closed to case open, and sets datetime if occurs
     *
     */
        public class manageReopenedDateTime implements Triggers.Handler {
            public void run(){
                Map<id,case> oldCases = (Map<id,Case>)Trigger.oldMap;
                Map<id,case> newCases = (Map<id,Case>)Trigger.newMap;
                List<case> cases = new List<case>();
                for(id cid : newCases.keySet()){
                    if(oldCases.get(cid).IsClosed == true && newCases.get(cid).IsClosed == false){
                        cases.add(new case(id = cid, Enquiry_Reopened__c = datetime.now()));
                    }
                }
                if(!cases.isEmpty()){
                    TriggerCommon.disableTrigger('Case'); // to prevent recursion
                    update cases;
                    TriggerCommon.enableTrigger('Case');
                }
            }
        }
    
    
    /**
     * clear the 'Last Email Received' field on open cases that have just had a task logged to them
     *
     */ 
        public class clearLastEmailReceived implements Triggers.Handler {
            public void run(){
                Set<Id> caseIds = new Set<Id>();
                for(Task tsk : (List<Task>)Trigger.new) caseIds.add(tsk.WhatId);
                
                List<Case> cases = new List<Case>([select id,
                                                            Latest_Inbound_Email__c 
                                                            from Case
                                                            where ( id in:caseIds 
                                                            and Latest_Inbound_Email__c != null
                                                            and isClosed = false )]);
                if(!cases.isEmpty()){
                    for(Case cse : cases) cse.Latest_Inbound_Email__c = null;
                    TriggerCommon.disableTrigger('Case'); // avoid unnecessary processing
                    update cases;
                    TriggerCommon.enableTrigger('Case');
                }
            }
        }
    
    
    
    /**
     * if MC Officer user is working in console
     * and has not yet set their defaults which are mandatory. 
     * need to prevent them adding or updating cases
     *
     */ 
        public class checkDefaultsSet implements Triggers.Handler {
            public void run(){
                Set<Id> userIds = new Set<Id>();
                User usr = UserServices.contextUser;
                if(usr.id != null && 
                   UserServices.MonashConnectOfficerUsers.contains(usr.id) &&
                   usr.My_Information_LastUpdate__c < date.today()){
                    for(Case cse : (List<Case>)Trigger.new) cse.addError(Label.CASE_console_settings_error);
                }
            }
        }
    
    /** 
     * at update, maintain the last queue owner field if the current owner is a queue
     */
        public class maintainLastQueueOwner implements Triggers.Handler {
            public void run(){
                for(case cse : (List<case>)Trigger.new){
                    if(String.valueOf(cse.ownerId).startsWith('00G')) cse.Latest_Unassigned_Queue_OwnerId__c = cse.ownerId;
                }
            }
        }
    
    
    /**
     * purpose is to intercept new web cases and see if there is an email address we can link case to.
     * query uses SOSL so one query per case after efficient check done, but is only done for inbound web cases 
     * that couldnt match via more efficient SOQL query first, so extremely unlikely to exceed limit
     *
     */
        public class checkForAndLinkToContacts implements Triggers.Handler {
            
            public void run(){
                
                List<Case> matchedCases = new List<Case>(); // where match found, use this list to manage mapping of case > contact info
                Set<String> emailAddresses = new Set<String>();
                Map<String, Case> casesMap = new Map<String, Case>();
                
                // need to wash inbound emails against the list of known faculty email addresses, stored in custom metadata
                // this prevents the inbound case linking to a contact that uses system email addresses 
                // known data issue from unicvrm v1.
                Set<string> facultyEmailAddresses = new Set<String>();
                for(Off_System_Email_Address__mdt addr : [select label,
                                                      Email_Address__c 
                                                      from Off_System_Email_Address__mdt Order by label ASC limit 200]){
            		facultyEmailAddresses.add(addr.Email_Address__c);                                           
            	}
                
                for (Case caseObj:(List<Case>)Trigger.new) {
                    if (caseObj.ContactId== null &&
                        caseObj.SuppliedEmail > '' ){
                            if(!facultyEmailAddresses.contains(caseObj.SuppliedEmail)){
                       			 emailAddresses.add(caseObj.SuppliedEmail); // to define scope of contact query
                        		 casesMap.put(caseObj.SuppliedEmail, caseObj); // store with email as key for quick reference later
                            }
                    }
    
                }
                
                // now map contacts with these addresses; considers system, monash and personal email address fields
                
                Map<String, Contact> existingContacts = new Map<String, Contact>();
                if(!emailAddresses.isEmpty()){
                    for(Contact existingContact : [Select Id, 
                                                    AccountId, 
                                                    Email,
                                                    Monash_Email_Address__c,
                                                    Applicant_Email_Address__c
                                                    from Contact 
                                                    where (
                                                        Monash_Email_Address__c in:emailAddresses 
                                                        OR Applicant_Email_Address__c in:emailAddresses
                                                        OR Email in:emailAddresses
                                                    )  limit 10000]){
                        
                        if(existingContact.Monash_Email_Address__c > '') existingContacts.put(existingContact.Monash_Email_Address__c, existingContact);
                        if(existingContact.Applicant_Email_Address__c > '') existingContacts.put(existingContact.Applicant_Email_Address__c, existingContact);
                        if(existingContact.Email > '') existingContacts.put(existingContact.Email, existingContact);
                        
                    }
                }
                // now link inbound cases to existing Contacts where possible
                
                for(Case caseObj:casesMap.values()){
                    
                    // split the supplied name field out
                    if(caseObj.suppliedName != null && caseObj.suppliedName.indexOf(' ') != -1){
                        caseObj.Supplied_First_Name__c = caseObj.suppliedName.split(' ')[0];
                        caseObj.Supplied_Last_Name__c = caseObj.suppliedName.split(' ')[1];
                    }
                    
                    if(existingContacts.containsKey(caseObj.SuppliedEmail)){
                        
                        // contact exists, so link the case to the existing contact record
                        
                        caseObj.ContactId = existingContacts.get(caseObj.SuppliedEmail).Id;
                        matchedCases.add(caseObj);
                        casesMap.put(caseObj.SuppliedEmail, caseObj);
                        
                        // TODO - get list of case fields to map to contact
                        // map to contact
                        // store in bulk update contact update list
                        
                        
                    
                    } else {
                        
                        // no contact matched with map of emails, 
                        // so check using SOSL query in case is an email registered in contact text field
                        // test coverage inserts web cases in batch, so using limits class to avoid issues during testing.
                        // during normal production run web enquiries are not loaded in bulk
                        // 
                        if(Limits.getSoslQueries() < Limits.getLimitSoslQueries() ){
                            if(caseObj.suppliedEmail > ''){
                                try{
                                    string emailAddr = caseObj.suppliedEmail + ';'; // limits result to matches in the email hx field
                                    List<List<sobject>> soslContacts = [FIND :caseObj.SuppliedEmail in ALL Fields returning Contact limit 1];
                                    caseObj.ContactId = ((Contact[])soslContacts[0])[0].id;
                                    matchedCases.add(caseObj);
                                } catch (exception e){
                                    ExLog.add('CaseServices - on Insert',
                                                          'Case',
                                                          'CaseServices.checkForAndLinkToContacts',
                                                          e.getMessage());
                                }
                            }
                        }
                    }
                }
                
                // if matched cases, then process mapping of case fields to contact records.
                if(!matchedCases.isEmpty()) {
                    TriggerCommon.disableTrigger('Contact');
                    ContactServices.copyMappedFieldsToCaseContacts(matchedCases);
                    TriggerCommon.enableTrigger('Contact');
                }
            }
        }
    
    
    /**
     * purpose is to map provided Record Type Name into an Id if possible, 
     * and only if is empty at insert (usually from a web form)
     *
     */
        public class convertStringRecordTypeNameToAnId implements Triggers.Handler {
            
            public void run(){
                
                for(Case inboundCase : (List<Case>)Trigger.new){
                    
                    if(inboundCase.Case_Type__c > '' ){
                        try{
                            inboundCase.RecordTypeId = CommonServices.recordTypeId('Case', inboundCase.Case_Type__c );
                        } catch (Exception e){
                            ExLog.add('CaseServices','Case','convertStringRecordTypeNameToAnId - passed \''+inboundCase.Case_Type__c+'\'', e); // log error for attention without interupting inbound flow
                        }
                    }
                }
                
            }
        }
    
    
        
    /**
     * retrieve a case having been provided a list of IDs
     * @param Ids list of ids to use to retrieve case records
     */
        public static list<case> retrieveCases(List<String> Ids){
            return [select id,
                            Enquiry_Type__c,
                            Course_Code__c,
                            Course_Title__c,
                            Current_Course_Faculty__c,
                            Location_Code__c,
                            Commencement_Date__c,
                            Attendance_Type__c,
                            Attendance_Mode__c,
                            Course_Attempt_Status__c,
                            Course__c
                            from Case where id in:Ids ];
        }
    
    
    /** 
     * clear out current course specific fields on case record
     * @param cs case record to clear parameters on
     */
        public static void clearCurrentCourseFields(Case cs){
            cs.Course_Code__c = null;
            cs.Course_Title__c = null;
            cs.Current_Course_Faculty__c = null;
            cs.Location_Code__c = null;
            cs.Commencement_Date__c = null;
            cs.Attendance_Type__c = null;
            cs.Attendance_Mode__c = null;
            cs.Course_Attempt_Status__c = null;
            cs.Course__c = null;
        }


    /**
     * populate current course specific fields on case
     *
     * @param cs case to populate fields on
     * @param courseCode course code that will be used to retrieve course specific information 
     */
        public static void populateCurrentCourseFields(Case cs, String courseCode){
            
            Course__c course = CourseServices.CourseInfoByName.get(courseCode);
            cs.Course_Code__c = course.Name;
            cs.Course_Title__c = course.Course_Description__c;
            cs.Course__c = course.id;   
            
        }

    /**
     * if case contact changes, then clear the case account field to overcome known issue in console presently
     */
        public class clearAccountFieldOnContactChange implements Triggers.Handler {
            public void run(){
                List<Case> TriggerOld = (List<Case>)Trigger.old;
                List<Case> TriggerNew = (List<Case>)Trigger.new;
                for(integer index = 0; index < TriggerNew.size(); index++){
                    Case oldCase = TriggerOld[index];
                    Case newCase = TriggerNew[index];
                    if(oldCase.ContactId != null 
                       && oldCase.ContactId != newCase.ContactId) newCase.AccountId = null;
                }
            }
        }

    /**
     * set default values on a new case if a user has valid defaults in place (service console user)
     */ 
        public class setDefaultsOnNewCases implements Triggers.Handler {
            public void run(){
                User usr = UserServices.contextUser;
                Boolean userHasDefaults = (usr.Queue__c != null && 
                                           usr.Location__c != null && 
                                           usr.Enquiry_Role__c != null && 
                                           usr.My_Information_LastUpdate__c == date.today());
                if(userHasDefaults){
                    // place defaults onto new case records
                    for(Case cse : (List<Case>)Trigger.new){
                        
                        // map queue to case enq type field
                        if(usr.Queue__c == UserServices.CURRENT_STUDENT) cse.Enquiry_Type__c = UserServices.CURRENT_STUDENT_VALUE;
                        if(usr.Queue__c == UserServices.FUTURE_STUDENT) cse.Enquiry_Type__c = UserServices.FUTURE_STUDENT_VALUE;
                        
                        // set location managed onto enquiry
                        cse.Location_Code__c = usr.Location__c;
                        
                        // set case origin based on default
                        if(usr.Enquiry_Role__c.indexOf('Face') != -1) cse.Origin = UserServices.FACE_TO_FACE_ORIGIN;
                        if(usr.Enquiry_Role__c.indexOf('Phone')!= -1) cse.Origin = UserServices.PHONE_ORIGIN;
                    }
                }
            }
        }
    
    
                    
    /**
     * utility to confirm if field has changed
     * @param fieldName name of field to check for change
     * @param newObj sObject that the field is on
     * @param oldObj sObject that the field is on
     */
        private static Boolean fieldHasChanged(String fieldName, SObject newObj, SObject oldObj){
            try{
                return (newObj.get(fieldName) != oldObj.get(fieldName)) ? true : false;
            } catch (exception e){
                return false; // if passed a null array 
            }
        }
}