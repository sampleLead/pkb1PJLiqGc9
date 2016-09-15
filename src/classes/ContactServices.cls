/*
 * A services class specific to Contact sObject
 * @author PwC
 * 
 */


public without sharing class ContactServices  {
    
	/**
	* establish a unique id on any contact records that have not been provided one
	* pre insert, populate the unique Person_Id_unique__c field if does not have a Monash provided number
	* uniqueness is established by 1) prefix with index padded to 3 chars + fast moving portion of current time in ms
	* so, total length is 10 chars, versus bona fide uni Ids of 8 characters. Also has ':' appended to also allow
	* formula to recognise legacy artificial ids or the new 10 digit variety.
	*/ 
    	public class populateNullPersonIdField implements Triggers.Handler {
            public void run(){
                List<contact> contacts = (List<contact>)Trigger.new;
                for(integer i=0; i<contacts.size(); i++){
                    if(contacts[i].Person_Id_unique__c == null){
                        string index = string.valueOf(i);
                        index = ':000'.left(3-index.length()) + index + String.valueOf(System.now().getTime()).right(7);
                        contacts[i].Person_Id_unique__c = index;
                        system.debug('index ='+index);
                    } 
                }
            }
    	}
    
    
    
    
    
	/**
	* enable copy of info from enquiry onto new contact - allows contact to be saved via global action
	* post insert, copy field level info over to contact IF Copy_from_Enquiry is checked. done via case trigger post attachment of these contact records
	*/ 
    	public class enableCopyCaseInfoToContact implements Triggers.Handler {
            public void run(){
                for(contact c : (List<contact>)Trigger.new){
                	if(c.Copy_from_Enquiry__c && c.lastname == null) c.lastname = 'temp_lastname';  // this enables contact to be stored, for post-insert processing.
                	// copy name string fields to standard fields - used in global action to bypass standard layout validation
                	if(c.First_Name__c > '') c.FirstName = c.First_Name__c;
                    if(c.Last_Name__c > '') c.LastName = c.Last_Name__c;
                }
            }
    	}
    
    
    
    
    
    
    
    /**
    * copy mapped fields from web case to contact. 
    * Leverages some custom metadata to determine mappings (Case_to_Contact_Field_Mapping__mdt)
    * @param cases list of case records to be assessed for field mapping
    */ 
    	public static void copyMappedFieldsToCaseContacts(List<case> cases){
        	list<contact> contacts = new list<contact>();
            
            // copy mapped fields from Case to a new contact record where id is set to case.contactId
            List<Case_to_Contact_Field_Mapping__mdt> fieldMappings = 
                new List<Case_to_Contact_Field_Mapping__mdt>([ SELECT Id, 
                                                               		  Case_API_name__c, 
                                                               		  Contact_Field_API_name__c 
                                                               		  FROM Case_to_Contact_Field_Mapping__mdt where Use_in_webform_mapping__c = true]);
            for(case cse : cases){
                contact cont = new contact(id = cse.contactId);
                string errMsg = '';
                for(Case_to_Contact_Field_Mapping__mdt fieldMapping : fieldMappings){
                    try{
                        if(cse.get(fieldMapping.Case_API_name__c) != null) 
                        cont.put(fieldMapping.Contact_Field_API_name__c, cse.get(fieldMapping.Case_API_name__c));
                    } catch (exception ex){
                        errMsg = ex.getMessage(); 
                    }
                }    
                if(errMsg == '') { contacts.add(cont); } else
                {  Exlog.write('ContactServices','copyMappedFieldsToCaseContacts','mapping to contact','This web case couldnt be mapped to contact:'+ errMsg + ' -> ' + JSON.serialize(cse)); }
                
            }    
            if (!contacts.isEmpty()) updateContacts(contacts);
    	}
    
    /**
    * update contacts supplied
    * @param contacts list of contact records to be updated via DML
    */ 
    	public static void updateContacts(List<contact> contacts){
        	update contacts;
    	}
    
    
    /**
    * montrack optout and reason 
    * @param con contact record that needs to be updated away from the context of sharing within the mt_controllerCC
    * @see mt_controllerCC.cls
    */ 
        public static void updateMontrackFields(contact con){
            contact conUpdate = new contact(id = con.id,
                                            MonTrack_Opt_Out__c = con.MonTrack_Opt_Out__c,
                                            MonTrack_Opt_Out_Reason__c = con.MonTrack_Opt_Out_Reason__c);
            update conUpdate;
        }	
    
    
	/**
	 * monitor email addresses for changes and store on aggregate texct field for matching purposes
	 */
	
		public class maintainEmailAddressHistory implements Triggers.Handler {
            public void run(){
                List<contact> newContacts = (List<contact>)Trigger.new;
                List<contact> oldContacts = (Trigger.isUpdate) ? (List<contact>)Trigger.old : new List<contact>();
                
                for(integer i=0; i< newContacts.size(); i++){
                    
                	Contact nw = newContacts[i];
                    Contact old = (Trigger.isUpdate) ? oldContacts[i] : new Contact();
                    
                    if((Trigger.isUpdate && fieldHasChanged('Email',nw, old) || 
                        fieldHasChanged('Monash_Email_Address__c',nw, old) || 
                        fieldHasChanged('Applicant_Email_Address__c',nw, old) || 
                        fieldHasChanged('bulkapi_Email_Addresses__c',nw,old)) ||
                        Trigger.isInsert){
                            
                        Set<string> addresses = new Set<string>();
                        // gather past addresses into a collection
                        // 
                        // stored historical addresses into a set
                        if(newContacts[i].Email_addresses__c != null && newContacts[i].Email_addresses__c.indexOf(';') != -1){ 
                            for(string address : newContacts[i].Email_addresses__c.split(';')) addresses.add(address);
                        }    
                        
                        // addresses provided by bulk api
                        if(newContacts[i].bulkapi_Email_Addresses__c != null && newContacts[i].bulkapi_Email_Addresses__c.indexOf(';') != -1){ 
                            for(string address : newContacts[i].bulkapi_Email_Addresses__c.split(';')) addresses.add(address);
                        }    
                            
                        if(newContacts[i].Email != null) addresses.add(newContacts[i].Email);
                        if(newContacts[i].Monash_Email_Address__c != null) addresses.add(newContacts[i].Monash_Email_Address__c);
                        if(newContacts[i].Applicant_Email_Address__c != null) addresses.add(newContacts[i].Applicant_Email_Address__c);
                        
                        // aggregate historical or bulk api loaded into a set of single instances of email addresses
                        if(!addresses.isEmpty()){ 
                            newContacts[i].Email_addresses__c = '';
                            for(string addr : addresses) newContacts[i].Email_addresses__c += addr + ';';
                        }
                    }
                    
                         
                    
                }
            	
            
            }
        }
    
    /**
	* monitor name for changes and store on parent accountto keep in sync
	*/ 
		public class maintainAccountName implements Triggers.Handler {
            public void run(){
                List<contact> newContacts = (List<contact>)Trigger.new;
                List<contact> oldContacts = (List<contact>)Trigger.old;
                Set<id> accountIds = new Set<id>();
                Map<id,string> accounts = new Map<id,string>();
                id accountRT = CommonServices.RecordTypeId('Account',AccountServices.ACCOUNT_INDIVIDUAL_TYPE) ;
                
                for(integer i=0; i< newContacts.size(); i++){
                    
                	Contact nw = newContacts[i];
                    Contact old = oldContacts[i];
                    if(nw.firstname != old.firstname || nw.lastname != old.lastname){
                        accounts.put(old.accountId, nw.firstname + ' ' + nw.lastname);
                        accountIds.add(old.accountId);
                    }
                }    
                    
                if(!accountIds.isEmpty()){ // only retrieve accts that are people accounts and that have a name change
            		Map<id,account> accts = new Map<id,account>([select id, recordtypeid, name from account where id in:accountIds and recordtypeId =:accountRT]);            
                    for(id key : accts.keySet()){
                        account a = accts.remove(key);
                        if(accounts.containsKey(key)) a.name = accounts.get(key);
                        accts.put(a.id, a);
                    }
                	update accts.Values();
                }
                    
                
            	
            
            }
        }
    
    
    /**
    * copy multiselect values over to free text field
    * update on 6-5-16 - only copies over the [values], not the complete label as there would have
    * been too many characters potentially to fit in 255 char field
    */ 
    	public class copyMultiselectToTextField implements Triggers.Handler {
            public void run(){
                for(Contact c : (List<Contact>)Trigger.new){
                    string v = (c.Contact_Profile__c != null) ? c.Contact_Profile__c : '';
                    c.Contact_Profiles_Selected__c = '';
                    while(v != null && v > '' && v.indexOf('[') != -1){
                         c.Contact_Profiles_Selected__c += v.substringBetween('[',']') + ';'; 
                        system.debug('v ='+v);
                        system.debug('prof='+c.Contact_Profiles_Selected__c);
                         v = v.substringAfter(']');
                    }
            	}    
                    
                
            }
    	}
    
    
    /**
    * for contacts inserted with no parent account, adds one of type 'Individual'
    */
        public class addContactAccounts implements Triggers.Handler {
            public void run(){
                
                List<Account> newAccounts = new List<Account>();
                Map<integer, integer> contactIndex = new Map<integer, integer>(); // maps new account list to original contact record
                
                List<Contact> contacts = (List<Contact>)Trigger.new;
                for(integer index = 0; index < contacts.size(); index++){
                    if(contacts[index].AccountId == null){
                        
                        // insert a new Account prior to Contact creation
                        
                        String firstName = (contacts[index].firstName == null) ? '' : contacts[index].firstName;
                        newAccounts.add(new Account(Name = firstName + ' ' + contacts[index].lastName,
                                                    RecordTypeId = CommonServices.RecordTypeId('Account',AccountServices.ACCOUNT_INDIVIDUAL_TYPE) ));
                        contactIndex.put(newAccounts.size() - 1, index); 
                    }
                }
                
                // if accounts to be added, bulk insert and then place new account ids onto new contacts prior to insertion
                
                if(!newAccounts.isEmpty()){
                    
                    // no try..catch as accommodating partial fail
                    
                    Database.SaveResult[] saveResults = Database.insert(newAccounts, false);
                    
                    for (integer index = 0 ; index < saveResults.size() ; index++) {
                        
                        if(TestHelper.throwError('accountInsert') || !saveResults[index].isSuccess() ){
                            
                            String errorMessage = '';
                            for(Database.Error err : saveResults[index].getErrors()) errorMessage += err.getMessage();
                            // append an error to affected contact record
                            contacts[contactIndex.get(index)].addError(LABEL.CONTACT_INSERT_ERROR + errorMessage); 
                        
                        } else {
                            
                            // link new contact record to the newly inserted Account record
                            contacts[contactIndex.get(index)].AccountId = newAccounts[index].Id;
                        
                        }
                    }
                }
            }
        }
    
    /**
    * removes Accounts of type Individual that have been left over from Individual Contact record deletions
    */
        public class cleanUpOrphanAccounts implements Triggers.Handler {
            public void run(){
                
                Set<Id> oldAccountIds = new Set<Id>();
                for(Contact contact : (List<Contact>)Trigger.old){
                
                    if(contact.AccountId != null) oldAccountIds.add(contact.AccountId);
                
                }
                
                if(!oldAccountIds.isEmpty()){
                    
                    // cull targets to only those accounts that are Individuals
                    
                    List<Account> accountsToDelete = [select id 
                                                      from Account
                                                      where RecordTypeId = :CommonServices.RecordTypeId('Account',AccountServices.ACCOUNT_INDIVIDUAL_TYPE)
                                                      and Id in:oldAccountIds ];
                    
                    // delete allowing for partial failure and reporting if problem
                    system.debug('** acts to delete'+accountsToDelete);
                    Database.DeleteResult[] deleteResults = Database.delete(accountsToDelete, false);
                    String errorMessage = '';
                    for (integer index = 0 ; index < deleteResults.size() ; index++) {
                        
                        if(TestHelper.throwError('accountDelete') || !deleteResults[index].isSuccess() ){
                            
                            errorMessage = errorMessage + 'Record Id unable to be deleted:' + accountsToDelete[index].Id + ' ';
                            
                            for(Database.Error err : deleteResults[index].getErrors()) errorMessage += err.getMessage();
                        } 
                            
                    }   
                    
                    // log error if any occured for post process cleanup by admin
                    
                    if(errorMessage != '') ExLog.add('ContactTrigger.onDelete',
                                                      'Account',
                                                      'ContactServices.cleanUpOrphanAccounts',
                                                      errorMessage);
                }
                
            }
        }


	
	
	
	/**
	* utility to confirm if field has changed
	* @param fieldname the API name of the field to look at
	* @param newObj the new version of the sObject to be considered
	* @param oldObj the previous or older version of the sObject to be considered
	* @return boolean confirming if change has been observed or not
	*/
		private static Boolean fieldHasChanged(String fieldName, SObject newObj, SObject oldObj){
            try{
            	return (newObj.get(fieldName) != oldObj.get(fieldName)) ? true : false;
            } catch (exception e){
                return false; // if passed a null array 
            }
		}	
	
	
    
}