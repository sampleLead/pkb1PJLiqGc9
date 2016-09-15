/**
 * This class contains unit tests for validating the behavior of SMSServices methods
 * these methods are part of the testing framework implemented throughout UniCRM
 * @see SingleRequestMock.cls
 */
@isTest
private class SMSServices_Test {
    
    
    
    static testMethod void basicTestCoverage(){
        
        List<contact> contacts = TestHelper.createOrphanContactRecords(1);
        insert contacts;
        system.assertNotEquals(null, contacts[0].id, 'contact not inserted as expected');
        
        Test.startTest();
        
            SingleRequestMock fakeResponse = new SingleRequestMock(200,
                                                     'Complete',
                                                     '[{ "personId":"19535554", "courseCode":"0316", "versionNum":"4", "courseAttemptStatus":"DISCONTIN", "locationCode":"CAULFIELD", "attendanceMode":"IN", "attendanceType":"FT", "courseTitle":"Bachelor of Business (Management)", "courseShortTitle":"BBus(Mgt)", "responsibleOrgUnitCode":"50000563", "managingFaculty":"FACULTY OF BUSINESS AND ECONOMICS", "homeCampus":"CAULFIELD", "attendanceModeDesc":"INTERNAL MODE OF ATTENDANCE", "attendanceTypeDesc":"FULL TIME", "title":"" },{ "personId":"19535554", "courseCode":"3154", "versionNum":"2", "courseAttemptStatus":"COMPLETED", "locationCode":"CAULFIELD", "attendanceMode":"IN", "attendanceType":"FT", "courseTitle":"Bachelor of Business (Law)", "courseShortTitle":"BBus(Law)", "responsibleOrgUnitCode":"50000563", "managingFaculty":"FACULTY OF BUSINESS AND ECONOMICS", "homeCampus":"CAULFIELD", "attendanceModeDesc":"INTERNAL MODE OF ATTENDANCE", "attendanceTypeDesc":"FULL TIME", "title":"Business law" },{ "personId":"19535554", "courseCode":"3158", "versionNum":"1", "courseAttemptStatus":"DISCONTIN", "locationCode":"CAULFIELD", "attendanceMode":"IN", "attendanceType":"FT", "courseTitle":"Bachelor of Business (Risk Management)", "courseShortTitle":"BBus(RiskMgt)", "responsibleOrgUnitCode":"50000563", "managingFaculty":"FACULTY OF BUSINESS AND ECONOMICS", "homeCampus":"CAULFIELD", "attendanceModeDesc":"INTERNAL MODE OF ATTENDANCE", "attendanceTypeDesc":"FULL TIME", "title":"" },{ "personId":"19535554", "courseCode":"3650", "versionNum":"1", "courseAttemptStatus":"COMPLETED", "locationCode":"MUFY-SUN", "attendanceMode":"IN", "attendanceType":"FT", "courseTitle":"Monash University Foundation Year", "courseShortTitle":"MUFY", "responsibleOrgUnitCode":"50000253", "managingFaculty":"OFFICE OF THE DVC (GLOBAL ENGAGEMENT)", "homeCampus":"SUNWAY COLLEGE, KUALA LUMPUR, MALAYSIA", "attendanceModeDesc":"INTERNAL MODE OF ATTENDANCE", "attendanceTypeDesc":"FULL TIME", "title":"" }]',
                                                     null);
            Test.setMock(HttpCalloutMock.class, fakeResponse);
            HttpResponse result = SMSServices.invokeCallout( String.valueOf(contacts[0].id) ,'student_course_attempts');
            
        Test.stopTest();
    }
}