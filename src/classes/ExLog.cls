/**
 * @description: Class to log system exceptions.
 *               Invoke using ExLog.add(<Trigger || Class>, Object name, Function Name, exception object) 
 *               in the catch block of functions
 *               For example: ExLog.add('Trigger', 'Account', 'SomeFunction', e);
 * 
 */

public class ExLog {
  
    //No record ID required
    public static void add(String sourceType, String objName, String funcName, Exception e) {
        try {
            write(sourceType, objName, funcName, e, '');
        } catch(Exception ex) {
            write('Class', 'ExLog', objName + '.' + funcName, ex, '');
        }
    }
    
    //This one accepts a record ID
    public static void add(String sourceType, String objName, String funcName, Exception e, string recordID) {
        try {
            write(sourceType, objName, funcName, e, recordID);
        } catch(Exception ex) {
            write('Class', 'ExLog', objName + '.' + funcName, ex, recordID);    
        }
    }

    //This one accepts an error message
    public static void add(String sourceType, String objName, String funcName, String errorMsg) {
        try {
            write(sourceType, objName, funcName, errorMsg);
        } catch(Exception ex) {
            write('Class', 'ExLog', objName + '.' + funcName, errorMsg);    
        }
    }

  
    //Write the exception, accepting input from method overloading above
    public static void write(String sourceType, String objName, String funcName, Exception e, string recordID) {
        try {
            Exception_Log__c exLog = new Exception_Log__c();

            exLog.Source_Type__c = sourceType;
            exLog.Object_Name__c = objName;
            exLog.Function_Name__c = funcName;
            exLog.RecordId__c = recordID;
            exLog.Exception_Type__c = e.getTypeName();
            exLog.Message__c = e.getMessage();
            exLog.Stack_Trace__c = e.getStackTraceString();
          
            insert exLog;
      
        } catch(Exception ex) {
                throw(ex);      //ouch
        }    
    }
    
    //Takes in a Database.SaveResult object.
    public static void write(String sourceType, String objName, String funcName, Database.Error e) {
        try {
            Exception_Log__c exLog = new Exception_Log__c();
          
            exLog.Source_Type__c = sourceType;
            exLog.Object_Name__c = objName;
            exLog.Function_Name__c = funcName;
            exLog.Exception_Type__c = 'DML Database Error';
            exLog.Message__c = 'Status Code: ' + e.getStatusCode() + '\nError Message: ' + e.getMessage();
            exLog.Stack_Trace__c = 'Status Code: ' + e.getStatusCode() + '\nError Message: ' + e.getMessage();
          
            insert exLog;
      
        } catch(Exception ex) {
                throw(ex);      
        }    
    }

    //Takes in a message.
    public static void write(String sourceType, String objName, String funcName, String errorMsg) {
        try {
            Exception_Log__c exLog = new Exception_Log__c();
          
            exLog.Source_Type__c = sourceType;
            exLog.Object_Name__c = objName;
            exLog.Function_Name__c = funcName;
            exLog.Exception_Type__c = 'Timeout Error';
            exLog.Message__c = errorMsg;
            exLog.Stack_Trace__c = 'Timeout Error';
          
            insert exLog;
      
        } catch(Exception ex) {
                throw(ex);      
        }    
    }

}