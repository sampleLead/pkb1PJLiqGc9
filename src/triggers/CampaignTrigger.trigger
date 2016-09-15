trigger CampaignTrigger on Campaign (before delete) {
	
    if (TriggerCommon.doNotRunTrigger('Campaign')) { return; }
    
    new Triggers()
    .bind(Triggers.Evnt.beforeDelete, new CampaignServices.preventCampaignDeletion())
    .execute(); 
}