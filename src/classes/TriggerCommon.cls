/**
 * A class of trigger specific utilities to support a consistent approach across the org
 * these provide for user specific trigger muting, or thread specific trigger muting
 * examples:
 * <p>
 * TriggerCommon.disableTrigger('Contact') will indicate to framework to disable contact related triggers.
 * TriggerCommon.enableTrigger('Contact') will indicate to framework to enable contact related triggers.
 * <p>
 * if within Trigger 'contactTrigger' TriggerCommon.doNotRunTrigger('Contact') is called, it
 * will return false if either a) TriggerCommon.disableTrigger('Contact') has been called,
 * or the context user has had a custom setting created that disables 'contactTrigger' for that user specifically.
 *
 * 
*/

public class TriggerCommon {
	
	// public method to enable a trigger, if was previously disabled

	public static void enableTrigger(string obj){
		triggersToDisable.remove(obj.tolowercase());
	}

	// public method to disable a trigger for this execution thread

	public static void disableTrigger(string obj){
		triggersToDisable.add(obj.tolowercase());
	}

	// public method to advise if a trigger has been disabled via either direct method or user specific custom setting

	public static boolean doNotRunTrigger(string obj){
		return (triggersToDisable.contains(obj.tolowercase()) || userSpecificTriggersToDisable.contains(obj.tolowercase())) ? true : false;
	}
	
	
	
	// map of forced trigger disablements

	private static set<string> triggersToDisable {
		get{
			if(triggersToDisable == null){
				triggersToDisable = new set<string>();
			}
			return triggersToDisable;
		}
		private set;
	}

	// user specific trigger mutes

	private static set<string> userSpecificTriggersToDisable  {
		get{
			
			userSpecificTriggersToDisable = new set<string>();
				try {
					// retrieve from custom settings, so no DML required as is in application cache 
					for(string triggerName : TriggerMuteRequest__c.getInstance(UserInfo.getUserName()).TriggersList__c.split(',')){
						userSpecificTriggersToDisable.add(triggerName.tolowercase());
					}
				} catch (exception e){
					// field doesnt exist, or is null, or format wrong so assume no triggers to disable
				}
			
			return userSpecificTriggersToDisable;
		}
		private set;
	}
	
	
	
}