trigger EnquiryInterestTrigger on Enquiry_Interest__c (before insert, before delete) {
 
 if (TriggerCommon.doNotRunTrigger('Enquiry_Interest__c')) { return; }
    
    new Triggers()
    .bind(Triggers.Evnt.beforeInsert, new EnquiryInterestServices.linkInterestsToPerson())
    .bind(Triggers.Evnt.beforeDelete, new EnquiryInterestServices.preventDeletionOnClosedCases())    
    .execute();
    
}