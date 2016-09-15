/**
 * Services class specific to Campaign sObject
 *
 * @author Carl Vescovi, PwC
 */
 
public class CampaignServices {

	
	/**
	 * prevents deletion of campaigns that have been specifically opted in 'not for deletion' via admin only field.
	 * in particular, this will prevent deletion of MonTrack campaign, which must not be deleted in production
	 */
	 
		public class preventCampaignDeletion implements Triggers.Handler {
			
			public void run(){
                for(Campaign c : (List<Campaign>)Trigger.old){
            		if(c.Prevent_Deletion__c) c.addError('This record is not permitted to be deleted. Contact System Administrator for assistance.');        
                }
			}
		}
    
}