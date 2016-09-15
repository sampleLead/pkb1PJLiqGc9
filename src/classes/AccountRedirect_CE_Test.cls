/**
 * Test coverage written for the AccountRedirect Controller Extension
 * 
 * @param   NIL	collection of static methods
 * @return  NIL
 * @see		AccountRedirect_CE
 */
@isTest
private class AccountRedirect_CE_Test {

    static testMethod void testRedirectOfAccountTypes() {
        
        List<contact> contacts  = TestHelper.createOrphanContactRecords(1);
        
        insert contacts;
        
        // test with Organisation
        
        Account organisation = new Account(name = 'test organisation',
        								   RecordTypeId = CommonServices.recordTypeId('Account',AccountServices.ACCOUNT_ORGANISATION_TYPE));
        
        insert organisation;
        
        ApexPages.StandardController stdAccount = new ApexPages.StandardController(organisation);
        
        AccountRedirect_CE con = new AccountRedirect_CE(stdAccount);
        PageReference result = con.IndividualRedirect();
        
        system.assert(result.getUrl().startsWith('/001')); // expect will direct to org record
        
        // now test with Individual
        
        Id accountId = [select id,accountId from contact where id =:contacts[0].id limit 1].accountId ; // the id resulting from Individual creation
        					
        stdAccount = new ApexPages.StandardController([select id from Account where id =:accountId limit 1]);
        
        con = new AccountRedirect_CE(stdAccount);
        
        result = con.IndividualRedirect();
        
        system.assert(result.getUrl().startsWith('/003')); // expect will direct to contact record
        
        
        system.debug(result);
        
    }
}