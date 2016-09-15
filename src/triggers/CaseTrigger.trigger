trigger CaseTrigger on Case (before insert, before update, after insert, after update) {
    
    if (TriggerCommon.doNotRunTrigger('Case')) { return; }
    
    new Triggers()
    .bind(Triggers.Evnt.beforeInsert, new CaseServices.mapCourseCode())
    .bind(Triggers.Evnt.beforeInsert, new CaseServices.checkDefaultsSet())
    .bind(Triggers.Evnt.beforeInsert, new CaseServices.convertStringRecordTypeNameToAnId())
    .bind(Triggers.Evnt.beforeInsert, new CaseServices.setDefaultsOnNewCases())
    .bind(Triggers.Evnt.beforeInsert, new CaseServices.checkForAndLinkToContacts())
    .bind(Triggers.Evnt.beforeInsert, new CaseServices.maintainLastQueueOwner())
    
    .bind(Triggers.Evnt.afterInsert, new CaseServices.setupBusinessHours())
    .bind(Triggers.Evnt.afterInsert, new CaseServices.addCourseInterests())
    
    .bind(Triggers.Evnt.beforeUpdate, new CaseServices.performValidation())
    .bind(Triggers.Evnt.beforeUpdate, new CaseServices.checkDefaultsSet())
    .bind(Triggers.Evnt.beforeUpdate, new CaseServices.clearAccountFieldOnContactChange())
    .bind(Triggers.Evnt.beforeUpdate, new CaseServices.maintainLastQueueOwner())
    

    .bind(Triggers.Evnt.afterUpdate, new CaseServices.maintainBusinessHours())
    .bind(Triggers.Evnt.afterUpdate, new CaseServices.manageReopenedDateTime())
    .bind(Triggers.Evnt.afterUpdate, new CaseServices.copyCaseFieldsOverToLinkedContact())
        
    .execute(); 
}