/** test coverage for API_ResultWrapper custom class 
 * @author PwC
 */ 
@isTest
private class API_ResultWrapper_Test {

    static testMethod void coverCustomClasses(){
        API_ResultWrapper tst = new API_ResultWrapper();
        API_StudentCourseAttempt sc = new API_StudentCourseAttempt();
        API_StudentPersonNote pn = new API_StudentPersonNote();
        API_StudentEncumbrance se = new API_StudentEncumbrance();
        API_ApplicantCourse ac = new API_ApplicantCourse();
        API_StudentCitizenship citizen = new API_StudentCitizenship();
        
        system.assertNotEquals(null, tst, 'tst not instantiated as expected');
        system.assertNotEquals(null, sc, 'sc not instantiated as expected');
        system.assertNotEquals(null, pn, 'pn not instantiated as expected');
        system.assertNotEquals(null, se, 'se not instantiated as expected');
        system.assertNotEquals(null, ac, 'ac not instantiated as expected');
        system.assertNotEquals(null, citizen, 'citizen not instantiated as expected');
        
    	HttpResponse resp = new HttpResponse();
        tst = new API_ResultWrapper(resp, new list<API_StudentCourseAttempt>());
        tst = new API_ResultWrapper(resp, new list<API_StudentPersonNote>());
        tst = new API_ResultWrapper(resp, new API_StudentEncumbrance());
        tst = new API_ResultWrapper(resp, new list<API_ApplicantCourse>());
        tst = new API_ResultWrapper(resp, new API_StudentCitizenship());
    }
    
    
    
}