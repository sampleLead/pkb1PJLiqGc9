@isTest
private class CampaignServicesTest {

    static testMethod void testDeletePrevention(){
        list<campaign> campaigns = TestHelper.createCampaign(10);
        for(campaign c : campaigns) c.Prevent_Deletion__c = true;
        insert campaigns;
        
        try{
            delete campaigns;
        } catch (exception e){}
        
        system.assertEquals(campaigns.size(),
                            [select count() from campaign],
                            'campaigns should not have been deleted');
        
       
        for(campaign c : campaigns) c.Prevent_Deletion__c = false;
        update campaigns;
        
        delete campaigns;
        system.assertEquals(0,
                            [select count() from campaign],
                            'campaigns should have been deleted');
    }
}