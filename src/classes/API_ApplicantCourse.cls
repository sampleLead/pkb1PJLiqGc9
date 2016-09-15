/** 
 * A custom wrapper class used to simply the representation and use of Monash Student Management System (SMS) information.
 * <p>
 * All attributes align to those returned in the JSON response received 
 * when requesting Application information via a callout to the API.Monash web service
 * for a given person id.
 * <p>
 * See https://api-dev.monash.edu/static/api for service details
 * 
 */

public class API_ApplicantCourse {
    
    public String personId {get;set;}
    public String preferenceNumber {get;set;}
    public String nominatedCourseCd {get;set;}
    public String courseCd {get;set;}
    public String title {get;set;}
    public String versionNumber {get;set;}
    public String responsibleOrgUnitCd {get;set;}
    public String managingFaculty {get;set;}
    public String locationCode {get;set;}
    public String attendanceMode {get;set;}
    public String attendanceModeDesc {get;set;}
    public String attendanceType {get;set;}
    public String attendanceTypeDesc {get;set;}
    public String admOfferRespStatus {get;set;}
    public String sAdmOutcomeStatus {get;set;}
    public DateTime commencementDate {get;set;}
    public DateTime submissionDate {get;set;}
    public String courseId {get;set;}

    public API_ApplicantCourse(){
        this.personId = '';
        this.preferenceNumber = '';
        this.nominatedCourseCd = '';
        this.courseCd = '';
        this.title = '';
        this.versionNumber = '';
        this.responsibleOrgUnitCd = '';
        this.managingFaculty = '';
        this.locationCode = '';
        this.attendanceMode = '';
        this.attendanceModeDesc = '';
        this.attendanceType = '';
        this.attendanceTypeDesc = '';
        this.admOfferRespStatus = '';
        this.sAdmOutcomeStatus = '';
        this.commencementDate = null;
        this.submissionDate = null;
        this.courseId = null;
    }
}