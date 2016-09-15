/**
 * Supports the 'loosely coupled' account-contact individual model.
 * 
 * @author Carl Vescovi, PwC
 * 
 */
public with sharing class AccountRedirect_CE {
    
    
    private Account acct;
    
    public AccountRedirect_CE(ApexPages.StandardController stdController) {
        this.acct = (Account)stdController.getRecord();
    }
    						  
    
   /**
	* Redirect Individual accounts to their contact record view.
	* 
	* @param   standardcontroller	to enable use in account record context
	* @return  pageReference  the associated contact detail view
	* 
	*/
    public PageReference IndividualRedirect(){
    	
    	PageReference pageRef = new ApexPages.StandardController(this.acct).View(); // default
        
    	Map<string,string> paramsMap = Apexpages.currentPage().getParameters();
    	
    	Account account = [select id,
    						  RecordTypeId, 
    						  (select id from contacts limit 1)
    						  from Account
    						  where id=:acct.id limit 1];
    	
    	
    	if(account.RecordtypeId == CommonServices.recordTypeId('Account',AccountServices.ACCOUNT_INDIVIDUAL_TYPE) && 
    		account.contacts.size() == 1 ){
    		
    		// redirect to contact view
    		
    		pageRef = new ApexPages.StandardController(account.contacts[0]).view(); // redirect to standard contact view
    	} else {
    		paramsMap.put('nooverride','1'); // to prevent cyclic redirect
    	}
    	
    	for(String key : paramsMap.keySet()) pageRef.getParameters().put(key, paramsMap.get(key)); // reappend all params that were passed on initial url
    	pageRef.setRedirect(true);
    	
    	return pageRef;
    	
    }
    
}