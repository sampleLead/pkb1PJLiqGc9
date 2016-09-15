/**
 * @description Test class for the ExLog class
 */
@isTest
private class ExLog_Test {

    static testMethod void exLogTest() {
        
        String sourceType = 'pw_TaskUtilities';
        String objName = 'Email';
        String funcName = 'sendFacultyActionEmail';
        Exception e;
        List<recordtype>  rt = [select id,developername from recordtype]; 
        Id recordID = rt[0].Id;
        
        String Msg = '';
        String StatusCode = '';
        
        Account[] accts = new List<Account>{
        new Account(Name='Account1'),
        new Account()};
        
        Database.SaveResult[] srList = Database.insert(accts, false);
        
        for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Successfully inserted account. Account ID: ' + sr.getId());
            }
            else {
                // Operation failed, so get all errors                
                for(Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred.');                    
                    StatusCode  = 'Status Code: ' + err.getStatusCode();
                    Msg = 'Error Message: ' + ': ' + err.getMessage();
                    System.debug('Account fields that affected this error: ' + err.getFields());
                    ExLog.write('accunt', 'Account', 'insert', err);
                }
            }
        }
        
        ExLog.add(sourceType, objName, funcName, e, recordID);
        ExLog.add(sourceType, objName, funcName, e);
        ExLog.add(sourceType, objName, funcName, Msg);
        
        system.assertNotEquals(0,
                           [select count() from Exception_Log__c ],
                           'exlog records didnt get created as expected');
        
    }
}