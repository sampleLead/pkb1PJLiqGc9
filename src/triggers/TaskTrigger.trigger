trigger TaskTrigger on Task (after insert, before insert, before update) {

    if (TriggerCommon.doNotRunTrigger('Task')) { return; }
    
    new Triggers()
    .bind(Triggers.Evnt.beforeInsert, new TaskServices.considerWrapUpTasks())
    .bind(Triggers.Evnt.afterInsert, new CaseServices.clearLastEmailReceived())
    .bind(Triggers.Evnt.beforeInsert, new TaskServices.considerTaskFieldMappings())
    .bind(Triggers.Evnt.beforeUpdate, new TaskServices.considerTaskFieldMappings())
    .execute(); 
}