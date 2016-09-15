/*
 * A services class specific to Course__c sObject
 * @author PwC
 * 
 */
public class CourseServices {
    
	/** returns a map of course information that is indexed by course code */
    
    public static Map<String,Course__c> CourseInfoByName {
        get{
            if(CourseInfoByName == null){
                CourseInfoByName = new Map<String,Course__c>();
                for(List<Course__c> courses: [select id,
                                               name,
                                               Course_Description__c
                                       		   from Course__c limit 2000]){
                     for(Course__c course : courses) CourseInfoByName.put(course.name, course);
                }
            }
            return CourseInfoByName;
        }
        private set;
    }
    
    /**
     * checks for existence of a course code in course table, and if not there 
     * add a new course record.  This addresses the issue of application records being
     * retrieved that there is no course record in crm for, which in turn
     * prevents closure of the enquiry.
     */
    
    public static void checkForAndAddCourseRecords(List<API_ApplicantCourse> applications){
        Set<string> courseCodes = new Set<string>();
        for(API_applicantCourse application : applications) courseCodes.add(application.courseCd);
        Map<string,course__c> courses = new Map<string,course__c>();
        for(course__c course : [ select id,name from course__c where name in :courseCodes]) courses.put(course.name, course);
        list<course__c> newCourses = new list<course__c>();
       
        for(API_ApplicantCourse application : applications){
            // need to add a course record if it doesnt exist in case service console user wants to link to it
            if(!courses.containsKey(application.courseCd)) 
                newCourses.add(new course__c(name = application.courseCd, 
                                             Managing_Faculty__c = application.managingFaculty,
                                             Depreciated__c = true)); // approved assumption is that we're adding old courses
        }
        
        // if we have new course records then insert them
        try{
            insert newCourses;
        } catch (exception ex){ Exlog.write('DML error', 'CourseServices', 'checkForAndAddCourseRecords', ex.getMessage()); }
        
    }
}