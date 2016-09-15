/** test coverage for API_StudentCourseAttempt custom class 
 * @author PwC
 */ 
@isTest
private class API_StudentCourseAttempt_Test {
	
    static testMethod void coverCustomClass(){
        API_StudentCourseAttempt att = new API_StudentCourseAttempt();
        system.assertNotEquals(null, att, 'att not instantiated as expected');
            
    }
}