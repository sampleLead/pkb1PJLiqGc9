/**
 * Custom Controller Extension for use in custom service console component(s).
 * Specifically, the component that surfaces person notes, citizenship and interests
 *
 * @author Carl Vescovi, PwC
 */
public with sharing class Console_components_CE {
    
    public Case c {get; private set;}
    public Id caseId {get; private set;}
    public Id contactId {get; private set;}
    public string studentId {get; private set;}
    public Boolean encumbered {get;private set;}
    public Boolean under18 {get; private set;}
    public String notesLabel {get;private set;}
    public String tab {get;set;} // used to retain tab context across refreshes of tabbed view
    public string APIResultString {get; set;}
    public string courseIdSelected {get;set;}
    public List<Person_Note__c> personNotes {get; private set;} // used in tabbed console component
    public Contact caseContact {get; private set;}
    public API_ResultWrapper APIResult { get;private set;}
    public boolean loadingAttempted {get;set;}
    public boolean encumbranceChecked {get;set;}
    public boolean encumbranceError {get;set;}
    public boolean httpError {get;set;}
    public string rid {get; private set;}
    
  	/** 
  	 * formats the current datetime into a string
  	 * @return string representing current date time
  	 */
  
    public string formattedDateTime {
        get{
            string res = c.createddate.format();
            if(c.createddate.date() == date.today()) { return 'Today at '+res.substringAfter(' '); } else
            if(c.createddate.date() == date.today().addDays(-1)){ return 'Yesterday at '+res.substringAfter(' '); } else
            { return String.valueOf(c.createddate.date().daysBetween(date.today())) + ' days ago at '+ res.substringAfter(' '); }
                
        }
    }
    
    /** 
     * retrieves the stored styles that could potentially be applied to person notes
     * @return map of styles to strings that might be used in notes
     */
    
    public Map<string, Person_Note_Style__c> noteStyles {
        get{
            if(noteStyles == null) noteStyles = Person_Note_Style__c.getAll();
            return noteStyles;
        }
        private set;
    }
  
  
    /** checks via realtime callout to api.monash for encumbrance information */
     
    public pageReference checkForEncumbrances(){
        httpError = false;
        loadingAttempted = false;
        encumbered = false; // default
        encumbranceError = false; // default
        // check for encumbered status in SMS via webservice callout
        // 
        if(studentId > ''){
            try{
                API_ResultWrapper encResult = retrieveEncumbrance();
                
                // if student is encumbered then note in the person notes to be surfaced in UI
                // 
                if(encResult.statusCode == 200){
                    if(encResult.encumbrance.encumbered == 'Y') encumbered = true;
                    if(encResult.encumbrance.encumbered == 'N') encumbered = false;
                    encumbranceError = false;
                } else {
                    encumbranceError = true;
                    CaseServices.storeExLog('Monash API callout', 'Console_components_CE', 'retrieve Encumbrance', encResult.status);
                }
                
            } catch (exception ex){
                // error occured, so flag this in person notes also
                //
                CaseServices.storeExLog('callout','Console_components_CE','populate lists - retrieve student encumbrance', ex.getMessage());
                httpError = true;
                encumbranceError = true;
            }
        } 
        encumbranceChecked = true;
        return null;
    }
    
    /** step in the page startup process, to attempt course and application list refreshes */
     
    public pageReference refreshLists(){
        httpError = false;
        loadingAttempted = false;
        populateLists();
        loadingAttempted = true;
        
        if(tab.indexOf('__item') != -1){
            tab = tab.subStringBetween('tab-default-','__item');
        } else {
            tab = '1' ; // default person notes tab
        }
        
        return null;
    }
    
    
    /** 
     * retrieves information from CRM relating to case being looked at, linked contact
     * information, and person notes information
     */
    
    private void populateLists(){
        
                
        under18 = false; 
        notesLabel = '';
        personNotes = new List<Person_Note__c>();
        caseContact = new contact();
        
        try{
            if(caseId != null){
                c = [select id,
                     Enquiry_Type__c,
                     contactId,
                     IsClosed,
                     Course_Code__c,
                     Course__c,
                     contact.Person_Id__c,
                     Citizenship_at_Enquiry__c,
                     CreatedDate,
                         (select id,
                          name,
                          course__c,
                          course__r.Name,
                          course__r.Course_Description__c,
                          specialisation__c,
                          specialisation_f__c,
                          Study_Area__c,
                          Detailed_Study_Area__c,
                          createdbyid
                          from Enquiry_Interests__r)
                     from Case 
                     where id =:caseId limit 1];
                if(c != null && c.contactId != null) contactId = c.contactId; // using case context, so source contactid from case record
            
                studentId = (c.contact.Person_Id__c != null) ? c.contact.Person_Id__c : '';
            } 
        
            
                    
            if(contactId != null){
                Date todaysDate = date.today(); // used in filter to exclude expired person notes
                caseContact = [select birthdate, 
                                       Person_ID__c,
                                       (select id,
                                        name,
                                        type__c,
                                        notes__c,
                                        Style_Text__c,
                                        important__c from Person_Notes__r
                                        where ( Expires__c >:todaysDate or Expires__c = null )),
                                       (select id,
                                        casenumber,
                                        subject,
                                        priority,
                                        createddate,
                                        status from Cases Order by CreatedDate DESC limit 30)
                                       from contact where id =:contactId limit 1];
                studentId = (caseContact.Person_Id__c != null)? casecontact.Person_Id__c : '';
            }
            
            if(!caseContact.person_notes__r.isEmpty()) personNotes = caseContact.person_notes__r;
            
            // if student is encumbered (from previous callout) then note in the person notes to be surfaced in UI
            // 
            if(encumbranceError){
                personNotes.add(new Person_Note__c(Notes__c = 'Error retrieving Encumbrance status', Type__c = 'MSG', Important__c = true, Style_Text__c = ''));    
            } else {
                if(encumbered) personNotes.add(new Person_Note__c(Notes__c = 'Encumbered', Important__c = true,Style_Text__c = ''));
                if(!encumbered && studentId > '') personNotes.add(new Person_Note__c(Notes__c = 'No Encumbrances',Style_Text__c = ''));
            }
            
            
            // assess for being under 18 yo
            
            if(caseContact.birthdate != null ){
                integer yrs = date.today().year() - caseContact.birthdate.year();
                yrs += (caseContact.birthdate.day() > date.today().day() && caseContact.birthdate.month() > date.today().month() ) ? 1 : 0;
                under18 = (yrs < 18);
            }
            
            // if u18, then add a person note as important
            
            if(under18) personNotes.add(new Person_Note__c(Notes__c = 'Under 18', Important__c = true,Style_Text__c = ''));
            
            if(studentId > ''){
                // now try to append notes sourced from SMS
                // 
            
                API_ResultWrapper res = retrievePersonNotes();
                
                if(res.notes.isEmpty() && res.statusCode == 200) 
                    personNotes.add(0,new Person_Note__c(Type__c = 'MSG', Notes__c = 'No notes found on SMS',Style_Text__c = ''));
                if(res.notes.isEmpty() && res.statusCode != 200){ 
                    personNotes.add(0,new Person_Note__c(Type__c = 'MSG', Notes__c = 'Error when checking for person notes', Important__c = true,Style_Text__c = ''));
                    CaseServices.storeExLog('Monash API callout', 'Console_components_CE', 'retrieve Person Notes', res.status);
                }
                for(API_StudentPersonNote pNote : res.notes){
                    personNotes.add(new Person_Note__c(Notes__c = pNote.NoteText,
                                                       Important__c = false,
                                                       Name = pNote.referenceNumber,
                                                       Type__c = pNote.peNoteType,
                                                       Style_Text__c = ''));
                }
            
                // retrieve citizenship in RT and append to person notes
            
                API_ResultWrapper resCitizen = retrievePersonCitizenship();
                boolean updateCitizenship = false;
                if(resCitizen.statusCode == 200){
                    string result = (resCitizen.citizenship.citizenshipType > '') ? resCitizen.citizenship.citizenshipType : 'No Citizenship data available' ;
                    personNotes.add(0,new Person_Note__c(Type__c = 'MSG', Notes__c = result,Style_Text__c = ''));
                    if(c != null && c.Citizenship_at_Enquiry__c == null) { c.Citizenship_at_Enquiry__c = result; updateCitizenship = true; }
                } else {
                    personNotes.add(0,new Person_Note__c(Type__c = 'MSG', Notes__c = 'Error when checking for citizenship', Important__c = true,Style_Text__c = ''));
                    CaseServices.storeExLog('Monash API callout', 'Console_components_CE', 'retrieve Citizenship', res.status);
                    if(c != null && c.Citizenship_at_Enquiry__c == null) { c.Citizenship_at_Enquiry__c = 'Unable to retrieve'; updateCitizenship = true; }
                }
                
            }    
            // apply admin controlled css where applicable to person notes
            // if is a match on type then that is only overridden by match on notes content
            
            for(Person_Note__c pnote : personNotes){
                string baseStyle = (pnote.Important__c) ? 'background:red;color:white;' : '';
                if(noteStyles.containsKey(pnote.Type__c)) baseStyle =  noteStyles.get(pnote.Type__c).css__c;
                if(noteStyles.containsKey(pnote.Notes__c)) baseStyle = noteStyles.get(pnote.Notes__c).css__c; 
                pnote.Style_Text__c = baseStyle; 
            }
        
        } catch (exception ex){
            CaseServices.storeExLog('Console component', 'Console_comnponents_CE', 'populate lists' , ex.getMessage());
        }
    }
    
    
    /** 
     * sets up and requests citizenship information via a realtime callout to api.monash 
     * @return results wrapper custom class for further processing
     * @see SMSServices.cls
     *
     */
     
    private API_ResultWrapper retrievePersonCitizenship(){
        HttpResponse response = (Test.isRunningTest()) ? SMSServices.mockPersonCitizenshipResponse() : SMSServices.invokeCallout(studentId,SMSServices.STUDENT_CITIZENSHIP_ENDPOINT);
        API_StudentCitizenship citizenshipResult = new API_StudentCitizenship();
        
        if(response.getstatusCode() == 200) {
            citizenshipResult =  (API_StudentCitizenship)JSON.deserialize(response.getBody(),API_StudentCitizenship.class);
        } else {
            CaseServices.storeExLog('Console component', 'Console_components_CE', 'retrievePersonCitizenship' , response.getStatus());
        }
        
        return new API_ResultWrapper(response, citizenshipResult);
    }
    
    
    /** 
     * sets up and requests person note information via a realtime callout to api.monash 
     * @return results wrapper custom class for further processing
     * @see SMSServices.cls
     *
     */
     
    private API_ResultWrapper retrievePersonNotes(){
        HttpResponse response = (Test.isRunningTest()) ? SMSServices.mockPersonNotesResponse() : SMSServices.invokeCallout(studentId,SMSServices.STUDENT_PERSON_NOTES_ENDPOINT);
        List<API_StudentPersonNote> notesResult = new List<API_StudentPersonNote>();
        
        if(response.getstatusCode() == 200) {
            notesResult =  (List<API_StudentPersonNote>)JSON.deserialize(response.getBody(),List<API_StudentPersonNote>.class);
        } else {
            CaseServices.storeExLog('Console component', 'Console_components_CE', 'retrievePersonNotes' , response.getStatus());
        }
        
        return new API_ResultWrapper(response, notesResult);
    }
    
    /** 
     * sets up and requests encumbrance information via a realtime callout to api.monash 
     * @return results wrapper custom class for further processing
     * @see SMSServices.cls
     *
     */
     
    private API_ResultWrapper retrieveEncumbrance(){
        HttpResponse response = (Test.isRunningTest()) ? SMSServices.mockEncumbranceResponse() : SMSServices.invokeCallout(studentId,SMSServices.STUDENT_ENCUMBRANCE_ENDPOINT);
        API_StudentEncumbrance encResult = new API_StudentEncumbrance();
        
        if(response.getstatusCode() == 200) {
            encResult = (API_StudentEncumbrance)JSON.deserialize(response.getBody(),API_StudentEncumbrance.class);
        } else {
            CaseServices.storeExLog('Console component', 'Console_components_CE', 'retrieveEncumbrance' , response.getStatus());
        }
        
        return new API_ResultWrapper(response, encResult);
    }
    
    /** 
     * controller instantiation method 
     * @param controller standard page controller for use by extension
     */
    
    public Console_components_CE(ApexPages.StandardController controller) {
        // can be used from either case or contact context, so need to check which view is in use
        id recId = controller.getId(); // prevent xss as is cast to an id, not a string directly
        rid = (String)recId;
        
        studentId = '';
        if(rid == null) rid = '';
        
        if(rid > '' && rid.startsWith('003')){ // contact view
            contact ctmp = [select id, Person_Id__c from contact where id =:rid limit 1];
            contactId = rid;
            if(ctmp.Person_Id__c != null) studentId = ctmp.Person_Id__c;
            
        } else
        if(rid > '' && rid.startsWith('500')){ // case view
            c = [ select id, contactid, createddate, contact.Person_Id__c from Case where id =:rid limit 1];
            caseId = c.id;
            contactId = c.contactId;
            if(c.contact.Person_Id__c != null) studentId = c.contact.Person_Id__c;
            
        }
        tab = '1'; // default
        encumbered = false;
        APIResultString = '';
        APIResult = new API_ResultWrapper();
        courseIdSelected = '';
        loadingAttempted = false;
        httpError = false;
        encumbranceChecked = false;
        encumbranceError = false;
        
    }

    /** 
     * retrieves a list of picklist values from Case.Enquiry_type__c field 
     * @return list of select options
     */
    
    public list<selectOption> casetypes {
        get{
            if(casetypes == null){
                 casetypes = new list<selectOption>();
                 Schema.DescribeFieldResult fieldResult = Case.Enquiry_Type__c.getDescribe();
                   List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
                   for( Schema.PicklistEntry f : ple)
                   {
                      casetypes.add(new SelectOption(f.getLabel(), f.getValue()));
                   }              
            
            }
            return casetypes;
        }
        private set;
    }
}