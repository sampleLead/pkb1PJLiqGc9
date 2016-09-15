/**
 * Custom Controller Extension for use in custom service console component(s).
 * Specifically, the component that surfaces course and application information
 *
 * @author Carl Vescovi, PwC
 */
public with sharing class Console_CourseInfo_CE {

    public Case c {get; private set;}
    public String tab {get;set;} // used to retain tab context across refreshes of tabbed view
    public string courseIdSelected {get;set;}
    public API_ResultWrapper courseAPIResult { get;private set;}
    public API_ResultWrapper applicationAPIResult {get; private set;}
    public boolean httpError {get;set;}
    public boolean loadAttempted {get;set;}
    public string errMessage {get;set;}
    private string citizenship {get; private set;}    
    public boolean renderTable {
        get{
            return (courseAPIResult.courseAttempts.size() > 0 || applicationAPIResult.applications.size() > 0) ? true : false;
        }
    }
    
    /** updates case record when course linked/unlinked */
    
    private void updateCaseRecord(){
        try{
            update c;
        } catch (exception ex){
            Exlog.write('Controller Extension','Console_components_CE','updateCaseRecord',ex.getMessage());
        }
    }
    
    /** removes course references from the case record */
    
    public pageReference unlinkFromCase(){
        c.Course__c = null;
        c.Course_Code__c = null;
        updateCaseRecord();
        return null;
    }
    
    /** links a course record to case, as selected from the course and/or application information surfaced in component */
    
    public pageReference linkToCase(){
        c.Course__c = null;
        String[] params = courseIdSelected.split(':');
        if(params[0].length() > 14) c.Course__c = params[0]; // can only link if we have a record in courses
        // Also stamp current state information onto enquiry
        c.Course_Code__c = params[1];
        boolean courseMatched = false;
        if(courseAPIResult.courseAttempts == null) courseAPIResult.courseAttempts = new List<API_StudentCourseAttempt>();
        for(API_StudentCourseAttempt ca : courseAPIResult.courseAttempts){
            if(ca.courseCode == c.Course_Code__c){
                c.Location_Code__c = ca.locationCode;
                c.Attendance_Mode__c = ca.attendanceMode;
                c.Attendance_Type__c = ca.attendanceType;
                c.Managing_Faculty__c = ca.managingFaculty;
                c.Home_Campus__c = ca.homeCampus;
                c.Course_Attempt_Status__c = ca.courseAttemptStatus;
                courseMatched = true; break;
            }
        }
        if(!courseMatched ){
            if(courseAPIResult.applications == null) courseAPIResult.applications = new List<API_ApplicantCourse>();
            for(API_ApplicantCourse ca : courseAPIResult.applications){
                if(ca.courseCd == c.Course_Code__c){
                    c.Location_Code__c = ca.locationCode;
                    c.Attendance_Mode__c = ca.attendanceMode;
                    c.Attendance_Type__c = ca.attendanceType;
                    c.Managing_Faculty__c = ca.managingFaculty;
                    c.Application_Outcome_Status__c = ca.sAdmOutcomeStatus;
                    c.Application_Response_Status__c = ca.admOfferRespStatus;
                    break;
                }
            }
        }
        
        updateCaseRecord();
        return null;
    }
    
    /**
     * custom controller extension instantiation
     * @param controller standard controller
     */
    
    public Console_CourseInfo_CE(ApexPages.StandardController controller) {
        c = new case();
        id caseId = (id)controller.getId();
        try{
        	
        	c = [select id,
                 Location_Code__c,
                 Attendance_Mode__c,
                 Attendance_Type__c,
                 Managing_Faculty__c,
                 Home_Campus__c,
                 contactId,
                 contact.Person_Id__c,
                 Course_Code__c,
                 Course__c
                 from Case
                 where id =:caseId limit 1];
        } catch (exception e){
            // deleted record, or invalid id so no further work
        }
        
        tab = '1'; // default
        courseAPIResult = new API_ResultWrapper();
        applicationAPIResult = new API_ResultWrapper();
        httpError = false;
        loadAttempted = false;
        errMessage = '';
        courseIdSelected = '';
        
    }
    
    /** one of the multiple steps taken to instantiate the page information */
    
    public pageReference initalLoad(){
        if(c.Contact.Person_Id__c != null) { 
            string process = 'populateCourses'; // in case of error reporting
            try{
                populateCourses();
                process = 'populateApplications';
                populateApplications(); 
                
            } catch (exception ex){
                httpError = true; // impacts initial render
                CaseServices.storeExLog('Console_CourseInfo_CE', 'initialLoad', process , ex.getMessage());
            }
            
        }
        loadAttempted = true;
        return null;
    }
    
    /** 
     * retrieve student course information via real time callout to api.monash web service 
     * @return custom wrapper class containing course enrollment information retrieved from api.monash
     */
    
    private API_ResultWrapper retrieveStudentCourseAttempts(){
        HttpResponse response = (Test.isRunningTest()) ? SMSServices.mockStudentCourseAttemptsResponse() : SMSServices.invokeCallout(c.contact.Person_ID__c,SMSServices.STUDENT_COURSE_ATTEMPTS_ENDPOINT);
        List<API_StudentCourseAttempt> courseAttemptResult = new List<API_StudentCourseAttempt>();
        if(response.getstatusCode() == 200) {
            courseAttemptResult =  (List<API_StudentCourseAttempt>)JSON.deserialize(response.getBody(),List<API_StudentCourseAttempt>.class);
        } else {
            CaseServices.storeExLog('Console API callout','Console_CourseInfo_CE','retrieveStudentCourseAttempts',response.getStatus());
        }
        
        return new API_ResultWrapper(response, courseAttemptResult);
    }
    
    
    /** 
     * retrieve applicant information via real time callout to api.monash web service 
     * @return custom wrapper class containing application information retrieved from api.monash
     */
    
    private API_ResultWrapper retrieveApplicantCourse(){
        HttpResponse response = (Test.isRunningTest()) ? SMSServices.mockApplicantCourseResponse() : SMSServices.invokeCallout(c.contact.Person_ID__c,SMSServices.APPLICANT_COURSE_ENDPOINT);
        List<API_ApplicantCourse> applicationResult = new List<API_ApplicantCourse>();
        if(response.getstatusCode() == 200) { 
            applicationResult =  (List<API_ApplicantCourse>)JSON.deserialize(response.getBody(),List<API_ApplicantCourse>.class);
            // if is a result, then need to have it checked to ensure course records exist
            if(applicationResult.size() > 0) CourseServices.checkForAndAddCourseRecords(applicationResult);
        } else {
            CaseServices.storeExLog('Console API callout','Console_CourseInfo_CE','retrieveApplicantCourse',response.getStatus());
        }
        
        return new API_ResultWrapper(response, applicationResult);
    }
    
    /** method called during multistep data loading process at page initiation to load course information */
    
    private void populateCourses(){
        
        // retrieve course attempts
        // 
        
        courseAPIResult = retrieveStudentCourseAttempts();
        
        if(courseAPIResult.statusCode == 200){
            
            
            // prior to returning, need to include the courseId for use within UI
            
            Set<string> codes = new Set<string>();
            for(API_StudentCourseAttempt result : courseAPIResult.courseAttempts){
                if(result.courseCode > '') codes.add(result.courseCode);
            }
            if(!codes.isEmpty()){
                
                // extend the web service response with internal record id of course's, matching on course code
                
                Map<string,course__c> courses = new Map<string,course__c>();
                for(course__c course : [select id,name from course__c where name in:codes]) courses.put(course.name,course);
                for(API_StudentCourseAttempt result : courseAPIResult.courseAttempts){
                    if(result.courseCode > ''&& courses.containsKey(result.courseCode)) {
                        result.courseId = courses.get(result.courseCode).id;
                    } else {
                        // need to use course code as the lookup, as no course record found in SF
                        result.courseId = result.courseCode;
                    }
                }
                
            }
        } else {
            errMessage = 'Server error when retrieving study history.';
            httpError = true;
            loadAttempted = true;
        }
        
        
    }
    
    /** method called during multistep data loading process at page initiation to load application information */
    
    private void populateApplications(){
        
        // retrieve applications
        // 
        applicationAPIResult = retrieveApplicantCourse();
        system.debug('app result = '+applicationAPIResult);
        if(applicationAPIResult.StatusCode == 200){
           
            
            // prior to returning, need to include the courseId for use within UI
            
            Set<string> codes = new Set<string>();
            for(API_ApplicantCourse result : applicationAPIResult.applications){
                if(result.nominatedCourseCd > '') codes.add(result.nominatedCourseCd);
            }
            if(!codes.isEmpty()){
                
                // extend the web service response with internal record id of course's, matching on course code
                
                Map<string,course__c> courses = new Map<string,course__c>();
                for(course__c course : [select id,name from course__c where name in:codes]) courses.put(course.name,course);
                for(API_ApplicantCourse result : applicationAPIResult.applications){
                    if(result.nominatedCourseCd > ''&& courses.containsKey(result.nominatedCourseCd)) {
                        result.courseId = courses.get(result.nominatedCourseCd).id;
                    } else {
                        // need to use course code as the lookup, as no course record found in SF
                        result.courseId = result.nominatedCourseCd;
                    }
                }
                
            }
        } else {
            errMessage = 'Server error when retrieving application history.';
            httpError = true;
            loadAttempted = true;
        }
        
        
    }
}