/** 
 * A custom wrapper class used to simply the representation and use of Monash Student Management System (SMS) information.
 * <p>
 * All attributes align to those returned in the JSON response received 
 * when requesting Application information via a callout to the API.Monash web service
 * for a given person id.
 * <p>
 * Used to represent responses about courses, applications,encumbrances, citizenship or person notes
 * <p>
 * See https://api-dev.monash.edu/static/api for service details
 * 
 * 
 */

public class API_ResultWrapper {
    
    public integer statusCode {get;private set;}
    public string status {get;private set;}
    
    public list<API_StudentCourseAttempt> courseAttempts {get;set;}
    public API_StudentEncumbrance encumbrance {get;set;}
    public list<API_ApplicantCourse> applications {get;set;}
    public list<API_StudentPersonNote> notes {get;set;}
    public API_StudentCitizenship citizenship {get;set;}
    
    /** instantiator pattern receiving student citizenship response 
     * @param resp the HTTPResponse returned by the webservice callout
     * @param result the wrapper class passed in that contains citizenship information
     */
    public API_ResultWrapper(HttpResponse resp, API_StudentCitizenship result){
        this.statusCode = resp.getStatusCode();
        this.status = resp.getStatus();
        this.citizenship = result;
    }
    
    /** instantiator pattern receiving student course attempt response 
     * @param resp the HTTPResponse returned by the webservice callout
     * @param result the wrapper class passed in that contains course attempt information
     */
    public API_ResultWrapper(HttpResponse resp, list<API_StudentCourseAttempt> results){
        this.statusCode = resp.getStatusCode();
        this.status = resp.getStatus();
        this.courseAttempts = results;
        
    }
    
    /** instantiator pattern receiving student person notes response 
     * @param resp the HTTPResponse returned by the webservice callout
     * @param result the wrapper class passed in that contains student person note information
     */
    public API_ResultWrapper(HttpResponse resp, list<API_StudentPersonNote> results){
        this.statusCode = resp.getStatusCode();
        this.status = resp.getStatus();
        this.notes = results;
    }
    
    /** instantiator pattern receiving student encumbrance response 
     * @param resp the HTTPResponse returned by the webservice callout
     * @param result the wrapper class passed in that contains encumbrance information
     */
    public API_ResultWrapper(HttpResponse resp, API_StudentEncumbrance result){
        this.statusCode = resp.getStatusCode();
        this.status = resp.getStatus();
        this.encumbrance = result;
    }
    
    /** instantiator pattern receiving applicant information response 
     * @param resp the HTTPResponse returned by the webservice callout
     * @param result the wrapper class passed in that contains applicant information
     */
    public API_ResultWrapper(HttpResponse resp, List<API_ApplicantCourse> results){
        this.statusCode = resp.getStatusCode();
        this.status = resp.getStatus();
        this.applications = results;
        
    }
    
    /** instantiator pattern with no params passed in */
    public API_ResultWrapper(){
        this.statusCode = 0;
        this.status = '';
        this.courseAttempts = new List<API_StudentCourseAttempt>();
        this.encumbrance = new API_StudentEncumbrance();
        this.applications = new List<API_ApplicantCourse>();
        this.notes = new list<API_StudentPersonNote>();
        this.applications = new list<API_ApplicantCourse>();
    }
}