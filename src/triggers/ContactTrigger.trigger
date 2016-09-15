trigger ContactTrigger on Contact (before insert, before update, after delete, after update) {
    
    if (TriggerCommon.doNotRunTrigger('Contact')) { return; }
    
    new Triggers()
        .bind(Triggers.Evnt.beforeInsert, new ContactServices.populateNullPersonIdField())
        .bind(Triggers.Evnt.beforeInsert, new ContactServices.enableCopyCaseInfoToContact())
        .bind(Triggers.Evnt.beforeInsert, new ContactServices.addContactAccounts())
        .bind(Triggers.Evnt.afterDelete, new ContactServices.cleanUpOrphanAccounts())
        .bind(Triggers.Evnt.beforeUpdate, new ContactServices.maintainEmailAddressHistory())
        .bind(Triggers.Evnt.beforeInsert, new ContactServices.maintainEmailAddressHistory())
        .bind(Triggers.Evnt.beforeInsert, new ContactServices.copyMultiselectToTextField())
        .bind(Triggers.Evnt.beforeUpdate, new ContactServices.copyMultiselectToTextField())
        .bind(Triggers.Evnt.afterUpdate, new ContactServices.maintainAccountName())
    .execute();
}