trigger EmailMessageTrigger on EmailMessage (after insert) {

    if (TriggerCommon.doNotRunTrigger('EmailMessage')) { return; }
    
    new Triggers()
    .bind(Triggers.Evnt.afterInsert, new EmailMessageServices.mapEmailToAddressToCases())
    .bind(Triggers.Evnt.afterInsert, new EmailMessageServices.flagInboundEmailResponse())
    .execute();
}