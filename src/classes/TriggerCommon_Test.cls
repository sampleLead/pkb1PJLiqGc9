/**
 * This class contains unit tests for validating the behavior of TriggerCommon class methods
 * these methods are part of the Trigger management framework implemented throughout UniCRM
 * 
 */
@isTest
private class TriggerCommon_Test {

    static testMethod void testTriggerDisableAndEnable() {
        
        // validate the behaviour of adding and removing an sobject type to trigger management methods
        
        Test.startTest();
        
	        TriggerCommon.disableTrigger('testObject');
	        System.assertEquals(true, 
	        					TriggerCommon.doNotRunTrigger('testObject'),
	        					'trigger should have been disabled');
	        
	        TriggerCommon.enableTrigger('testObject');
	        System.assertEquals(false, 
	        					TriggerCommon.doNotRunTrigger('testObject'),
	        					'trigger should have been enabled');
	        
        Test.stopTest();
     }
     
     static testMethod void testUserSpecificTriggerDisable(){
     	
     	// test the user specific mute logic
     	// based on a custom setting, trigger utility logic should return true to run for one user, but not another.
     	
        List<User> users = TestHelper.createTestUsers('Standard User',2);
        
        TestHelper.createTriggerMutingCustomSetting(users[0].username, 'testObject,testObject2');
        
        Test.startTest();
        
	        System.runAs(users[0]){
	        	System.assertEquals(true, 
		        					TriggerCommon.doNotRunTrigger('testObject'),
		        					'trigger should have been disabled for user 0');
	        }
	        
	        System.runAs(users[1]){
	        	System.assertEquals(false, 
		        					TriggerCommon.doNotRunTrigger('testObject'),
		        					'trigger should have been enabled for user 1');
	        }
	 	
	 	Test.stopTest();
     }
}