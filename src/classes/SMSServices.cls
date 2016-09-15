/*
 * A sms integration services class.
 * Centralises the various real time callouts to the Api.Monash web service, 
 * and then returns a purpose built custom wrapper class containing the results
 * <p>
 * credentials and endpoint are managed in editable custom metadata
 * @see https://api-dev.monash.edu/static/api
 * @author PwC
*/
public class SMSServices {
  
	public static final string STUDENT_COURSE_ATTEMPTS_ENDPOINT = '/rest/unicrm/getStudentCourseAttempts/v1?personId=';
    public static final string STUDENT_ENCUMBRANCE_ENDPOINT = '/rest/unicrm/getStudentEncumbrance/v1?personId=';
    public static final string APPLICANT_COURSE_ENDPOINT = '/rest/unicrm/getApplicantCourse/v1?personId=';
    public static final string STUDENT_PERSON_NOTES_ENDPOINT = '/rest/unicrm/getStudentPersonNotes/v1?personId=';
    public static final string STUDENT_CITIZENSHIP_ENDPOINT = '/rest/unicrm/getStudentCitizenshipType/v1?personId=';
    
    public static HttpResponse invokeCallout( String studentNumber, String endpoint){
    	
    	Credential__mdt credentials = [select label,
                                       		  username__c,
                                       		  password__c,
                                       	  	  Base_URL__c from Credential__mdt where label = 'MonashAPI' limit 1 ];
    	
    	HTTP h = new HTTP();
        HTTPRequest r = new HTTPRequest();
        
        r.setEndpoint(credentials.Base_URL__c + endpoint + studentNumber);
        r.setTimeout(1000 * 20);
        Blob headerValue = Blob.valueOf(credentials.username__c + ':' + credentials.password__c);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        r.setHeader('Authorization', authorizationHeader);
        r.setMethod('GET');
        datetime startDT = datetime.now();
        HTTPResponse resp = h.send(r);
        SYSTEM.DEBUG('** ENDPOINT '+credentials.Base_URL__c+endpoint+studentNumber);
        SYSTEM.DEBUG('** RESP ='+resp);
        
        return resp;
    	
    	
    }
    
    public static HttpResponse mockPersonNotesResponse(){
         return buildResponse('[{ "personId":"123445","referenceNumber":"1233","peNoteType":"notetype","noteText":"noteText"}]');
    }
    
    public static HttpResponse mockPersonCitizenshipResponse(){
         return buildResponse('{ "personId":"123445", "citizenshipType":"AUSTRALIAN" }');
    }
    
    public static HttpResponse mockEncumbranceResponse(){
         return buildResponse('{ "personId":"123445", "encumbered":"Y" }');
    }
    
    public static HttpResponse mockStudentCourseAttemptsResponse(){
         return buildResponse('[{ "personId":"123445", "courseCode":"123","versionNum":"1","courseAttemptStatus":"COMPLETED","locationCode":"lc","attendanceMode":"FT","attendanceType":"FT","courseTitle":"testCourse","courseShortTitle":"BSc","responsibleOrgUnitCode":"UC","managingFaculty":"mf","homeCampus":"Caulfield","attendanceModeDesc":"FT","attendanceTypeDesc":"FT","title":"title" }]');
    }
    
    public static HttpResponse mockApplicantCourseResponse(){
        return buildResponse('[{ "personId":"123445", "preferenceNumber":"123","nominatedCourseCd":"1","courseCd":"COMPLETED","title":"lc","versionNumber":"2"}]');
    }
    
    private static HttpResponse buildResponse(string body){
        HttpResponse resp = new HttpResponse();
        resp.setBody(body);
        resp.setStatus('OK');
        resp.setStatusCode(200);
        return resp;
    }
    
}