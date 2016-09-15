trigger CampaignMemberTrigger on CampaignMember (after update, before update) {
 	
 	if (TriggerCommon.doNotRunTrigger('CampaignMember')) { return; }
    
    new Triggers()
    .bind(Triggers.Evnt.afterUpdate, new CampaignMemberServices.manageChangesOfCohort())
    .execute();   
}