/** 
 * A non specific 'global' class containing methods that can be leveraged by multiple domains
 * @author PwC
 */

public class CommonServices {
   
    public static string ORGWIDE_ADDRESS_MONASH = 'Monash University';
    
    /* 
	 * returns an id of a record type, provided an sobject name and record type name
	 * @param sObjName  the name of the sobject that uses the record type
	 * @param recordTypeName the label of the record type - salesforce method does not use developer name unfortunately
	 */
    public static Id recordTypeId( String sObjName, String recordTypeName ){
        try{
            return Schema.getGlobalDescribe().get(sObjName).getDescribe().getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
        } catch (exception e){
            return null; // not found
        }
    }
    
    /*
     * returns an id of an org wide email address
     * @param displayName the name of the email address that we want an id for
     */
    public static Id orgWideAddressId(String displayName){
        
            for(OrgWideEmailAddress owa : [select id, DisplayName from OrgWideEmailAddress]){
                if(owa.displayName.contains(displayName)) return owa.id;
            }
            return null;
        
    }
    
    /*
     * return boolean describing if in sandbox
     */
    public static Boolean isSandbox {
        get{
            if(isSandbox == null){
                isSandbox = [SELECT Id, IsSandbox FROM Organization LIMIT 1].IsSandbox;
            }
            return isSandbox;
        }
        set;
    }
    
}