trigger RoundTrigger on Round__c (after insert) {
    
    if (TriggerCommon.doNotRunTrigger('Round__c')) { return; }
    
    new Triggers()
    .bind(Triggers.Evnt.afterinsert, new RoundServices.createMontrackTasks())
    .execute();
    
}