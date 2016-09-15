@isTest
private class CourseServices_Test {

    static testMethod void testCourseCheckLogic(){
        
        List<API_ApplicantCourse> applList = new List<API_ApplicantCourse>();
        for(integer i=0; i<5; i++){
            API_ApplicantCourse c = new API_ApplicantCourse();
            c.courseCd = 'course'+String.valueOf(i);
            c.managingFaculty = 'test faculty';
            applList.add(c);
        }
        
        CourseServices.checkForAndAddCourseRecords(applList);
        system.assertEquals(5, [select count() from course__c],'wrong number of courses created');
    
    
    	applList = new List<API_ApplicantCourse>();
         for(integer i=0; i<5; i++){
            API_ApplicantCourse c = new API_ApplicantCourse();
            c.courseCd = 'course'+String.valueOf(i);
            c.managingFaculty = 'test faculty';
            applList.add(c);
        }
        
        CourseServices.checkForAndAddCourseRecords(applList);
        
        system.assertEquals(5, [select count() from course__c],'wrong number of courses created');
    
    	// check other utility
    	
        Map<String,Course__c> courses = CourseServices.CourseInfoByName;
        system.assert(!courses.isEmpty(),'course map should not be empty');
    }
    
    
}