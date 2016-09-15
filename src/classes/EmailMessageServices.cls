/*
 * A services class specific to EmailMessage sObject
 * @author PwC
 * 
 */
public class EmailMessageServices {

    /**
    * purpose is to map the 'To' address on email message to the case that resulted from this email message, if required
    * this in turn allows case assignment rules engine to know which inbound email service the case originated from
    */ 
    public class mapEmailToAddressToCases implements Triggers.Handler {
        public void run(){
            
            Map<id,case> cases = new Map<id,case>(); // for bulk update later if required
            Set<id> caseIds = new Set<Id>();
            
            for(EmailMessage email : (List<EmailMessage>)Trigger.New){
                if(email.ToAddress != null && email.ParentId != null) caseIds.add(email.ParentId); // cull to only those we have info required
            }
            
            if(!caseIds.isEmpty()){
                // only want the cases that need the email field populated i.e. new 'email to salesforce' cases
                cases = new Map<id,Case>([select id, 
                                          Email_To__c,
                                          Latest_Inbound_Email__c
                                          from Case 
                                          where id in:caseIds 
                                          and (Email_To__c = null or Email_To__c = '')
                                          and (Origin = 'Email' or Origin like 'Email%')]); // cull to empty only
                if(!cases.isEmpty()){
                    
                    for(EmailMessage email : (List<EmailMessage>)Trigger.New){
                        if(email.ToAddress != null && email.ParentId != null && cases.containsKey(email.ParentId)) {
                         cases.put(email.ParentId, new Case(id = email.ParentId, Email_To__c = email.ToAddress)); // update email field 
                        }
                    }
                    try{
                        update cases.values(); // push new email values into affected cases
                    } catch (exception ex){
                        ExLog.write('EmailMessageServices','mapEmailToAddressToCases','updating case Email_To__c field',ex.getMessage());
                    }
                }
                
            }
        }
    }
    
    /** when inbound email received, flag the receipt on affected cases, so that customer service can see inbound activity */
    
    public class flagInboundEmailResponse implements Triggers.Handler {
        public void run(){
            
            Map<id,case> cases = new Map<id,case>(); // for bulk update later if required
            Set<id> caseIds = new Set<Id>();
            
            for(EmailMessage email : (List<EmailMessage>)Trigger.New){
                
                if( (email.Incoming==true || Test.isRunningTest()) && email.ParentId != null) caseIds.add(email.ParentId); // cull to only those we have info required
            }
            if(!caseIds.isEmpty()){
                // only want the cases that need the email field populated i.e. new 'email to salesforce' cases
                maintainCaseFields(caseIds);
                
            }
        }
    }
    
    /** updates cases that have an inbound email logged against them.
     * If is being reopened, then tries to reassign back to the most recent 'unassigned' queue that it belonged to.
     * @param caseIds the ids of the affected cases
     * @param emails the list of inbound email messages
     * @return void
     */
    public static void maintainCaseFields(Set<id> caseIds){
        Map<id,case> cases = new Map<id,Case>([select id, 
                                          Latest_Inbound_Email__c,
                                          Latest_Unassigned_Queue_OwnerId__c,
                                          Status,
                                          CreatedDate,
                                          Origin,
                                          (select id,MessageDate from emailMessages where Incoming = true order by MessageDate DESC limit 2),
                                          IsClosed
                                          from Case 
                                          where id in:caseIds 
                                          ]); 
        if(!cases.isEmpty()){
            for(case c : cases.values()){
                // need to consider Email - System value and Email - Airport Pickup value
                if(!(c.Origin != null && c.Origin.indexOf('Email - ') != -1  && c.emailMessages.size() == 1) && !c.emailMessages.isEmpty()){ // ignores the email2case channel initial email
                    system.debug('** met criteria so reopening');
                    datetime msgDate = (c.emailMessages[0].MessageDate != null) ? c.emailMessages[0].MessageDate : datetime.now();
                    case updatedCase = new Case(id = c.id, Latest_Inbound_Email__c = msgDate);
                    if (c.IsClosed) updatedCase.status = 'Open';
                    if (c.IsClosed && c.Latest_Unassigned_Queue_OwnerId__c > '') updatedCase.ownerId = c.Latest_Unassigned_Queue_OwnerId__c;
                    cases.put(c.id, updatedCase);  // update email field and status
                }
            }
            try{
                update cases.values(); // push new email values into affected cases
            } catch (exception ex){
                ExLog.write('EmailMessageServices','flagInboundEmailResponse','updating Latest_Inbound_Email field',ex.getMessage());
            }
        }
    }
    
    
}