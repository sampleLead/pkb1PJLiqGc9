/** 
 * A custom wrapper class used to simply the representation and use of Monash Student Management System (SMS) information.
 * <p>
 * All attributes align to those returned in the JSON response received 
 * when requesting course attempt information via a callout to the API.Monash web service
 * for a given person id.
 * <p>
 * See https://api-dev.monash.edu/static/api for service details
 * 
 */
public class API_StudentCourseAttempt {
    public string personId {get;set;}
    public string courseCode {get;set;}
    public string versionNum {get;set;}
    public string courseAttemptStatus {get;set;}
    public string locationCode {get;set;}
    public string attendanceMode {get;set;}
    public string attendanceType {get;set;}
    public string courseTitle {get;set;}
    public string courseShortTitle {get;set;}
    public string responsibleOrgUnitCode {get;set;}
    public string managingFaculty {get;set;}
    public string homeCampus {get;set;}
    public string attendanceModeDesc {get;set;}
    public string attendanceTypeDesc {get;set;}
    public string title {get;set;}
    
    public string courseId {get;set;}
    
    public API_StudentCourseAttempt(){
        this.personId = '';
        this.courseCode = '';
        this.versionNum = '';
        this.courseAttemptStatus = '';
        this.locationCode = '';
        this.attendanceMode = '';
        this.attendanceType = '';
        this.courseTitle = '';
        this.courseShortTitle = '';
        this.responsibleOrgUnitCode = '';
        this.managingFaculty = '';
        this.homeCampus = '';
        this.attendanceModeDesc = '';
        this.attendanceTypeDesc = '';
        this.title = '';
        this.courseId = '';
    }
    
}