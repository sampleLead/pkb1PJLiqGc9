/**
 * test coverage for the CommonServices class
 */ 
@isTest
private class CommonServices_Test {

    static  testMethod void checkMethods(){
        
        string typ = [select id,name from RecordType where SobjectType = 'Contact' limit 1].Name;
        
        
        system.assertNotEquals(null,
                            CommonServices.recordTypeId('Contact',typ),
                            'should not have returned null');
        
        system.assertEquals(null,
                            CommonServices.recordTypeId('Contact','nonexistantType'),
                            'should have returned null');
        
        system.assertEquals(null,
                            CommonServices.orgWideAddressId('nonExistantOrgWideEmail'),
                            'should have returned null');
        system.assertNotEquals(null,
                            CommonServices.orgWideAddressId(CommonServices.ORGWIDE_ADDRESS_MONASH),
                            'should not have returned null');
        
    
    	boolean retrieveSandbox = CommonServices.isSandbox;
    }
    
    
}