/**
 * This class contains unit tests for validating the behavior of the MonTrack custom controller
 * these methods are part of the testing framework implemented throughout UniCRM
 * 
 */
@isTest
private class mt_mainControllerCC_Test {
    static testMethod void testmt_mainControllerCC() {
        
        //create user
        
        User u= TestHelper.ssaUser();
        
        //create account
        
        List<Account>acct= TestHelper.createStudent(10);
        insert acct;
        
        List<Contact> conList= TestHelper.createStudentContacts(10, acct);
        
        insert conList;
        
        Set<ID>accountID = new Set<ID>();
        
        for(Account a:acct){
            accountID.add(a.ID);
        }
        
        //create Campaign
        
        List<Campaign> camp=  TestHelper.createCampaign(1);
        insert camp;
        
        //create Cohort
        
        List<Cohort__c> cohort = TestHelper.createCohort(2);
        insert cohort;
        
        set<ID> contactID= new Set<ID> ();
        for(Contact con : conList){
            contactID.add(con.Id);
        }
        list<CampaignMember> cm= TestHelper.createCampaignMember(u.Id, cohort[0].id, camp[0].Id,contactID );
        insert cm;
        
        list<CampaignMember> tmpCM= new List<CampaignMember>();
        tmpCM=[SELECT ID,contactID,cohort__c,CampaignID FROM CampaignMember WHERE Cohort__c=:cohort[0].ID AND CampaignID=:camp[0].Id ];
        
        list<Round__c> rList= TestHelper.createRounds(tmpCM[0].Cohort__c, tmpCM[0].CampaignId, 4); 
        insert rList;
        
        
        Set<ID>roundID= new Set<ID>();
        for(Round__c r:rList){
            roundID.add(r.Id);
        }
            
        Test.startTest();
            System.runAs(u){
                // confirming can add tasks
                list<Task> taskList = new list<Task>();
                boolean callbackAdded = false;
                for(ID conID:contactID){
                Task newtask= new Task( whatId= rlist[3].id,
                                     whoId=conID,
                                     Subject='MonTRACK Call');
                                     if(!callbackAdded){
                                        newTask.Status = 'Call Back Requested by Student/Other';
                                        newTask.Call_Back_Date_Time__c = datetime.now().addHours(1);
                                        callbackAdded = true;
                                     }
                    taskList.add(newtask);
                }
                insert taskList;
                List<Task> task=[Select Id, WhatID FROM Task where WhatID =:rlist[3].id];
                
                
         
                 PageReference ref = Page.mt_main;
                 Test.setCurrentPage(ref);
                 mt_mainControllerCC montrack = new mt_mainControllerCC();                 
                 List<selectOption> cOptions = montrack.cohortOptions;
                 montrack.cohort = cohort[0].id;
                 List<selectOption> rOptions = montrack.roundOptions;
                 montrack.round = rList[3].id;
                 List<selectOption> uOptions = montrack.ssaUserOptions;                 
                 montrack.ssaUser = u.id;
                 montrack.retrieveCalls();
                 List<selectOption> fOptions = montrack.filterOptions;
                 montrack.listFilter= 'Not Started';                 
                 montrack.retrieveCalls();
                 montrack.listFilter= 'Incomplete';
                 montrack.retrieveCalls();
                 montrack.listFilter= 'Completed';
                 montrack.retrieveCalls();
                 montrack.listFilter= 'All';
                 montrack.retrieveCalls();
                 
                 string msg = montrack.nextCallbackMessage;                 
                 system.assertEquals(10,montrack.taskDetailList.size());
                 
                 id tskId = montrack.taskDetailList[0].taskId;
                 id conId = montrack.taskDetailList[0].contactId;
                 
                 apexpages.currentpage().getparameters().put('tId',tskId);
                 apexpages.currentpage().getparameters().put('cId',conId);
                 montrack.taskClicked();
                 
                 
                 
                 montrack.saveCall(); //Error                   
                 montrack.currenttask.status = 'Call Back Requested by Student/Other';
                 montrack.saveCall(); //Error
                 montrack.currenttask.status = 'No Answer';
                 montrack.currentContact.MonTrack_Opt_Out__c = true;
                 montrack.saveCall(); //Error
                 
                 montrack.currenttask.status = 'No Answer'; //I
                 montrack.currentTask.Call_Back_Date_Time__c= System.Now(); 
                 montrack.currentContact.MonTrack_Opt_Out__c = true;
                 montrack.currentContact.MonTrack_Opt_Out_Reason__c='Reason';
                 montrack.saveCall();
                 
                 
                                 
                 apexpages.currentpage().getparameters().put('tId',tskId);
                 apexpages.currentpage().getparameters().put('cId',conId);
                 montrack.taskClicked();
                 
                 //montrack.testRoundTasks = montrack.otherRounds; 
                 //montrack.testTaskHistory = montrack.taskHistories;
                 
                 montrack.currenttask.status = 'No Answer'; //II
                 montrack.currentTask.Call_Back_Date_Time__c= System.Now(); 
                 montrack.currentContact.MonTrack_Opt_Out__c = true;
                 montrack.currentContact.MonTrack_Opt_Out_Reason__c='Reason';               
                 montrack.saveCall();
                 
                 montrack.deleteTask();    //undo
                 
                 montrack.currenttask.status = 'No Answer'; //II
                 montrack.currentTask.Call_Back_Date_Time__c= System.Now(); 
                 montrack.currentContact.MonTrack_Opt_Out__c = true;
                 montrack.currentContact.MonTrack_Opt_Out_Reason__c='Reason';               
                 montrack.saveCall();
                 
                 montrack.currenttask.status = 'Completed';                
                 montrack.saveCall(); //Error-Complete your call                 
                 
                                                                
                 //Topic
                 montrack.saveTopicRecord();    //Exception //Both are mandatory                 
                 montrack.topic.type__c = 'Montrack';
                 montrack.saveTopicRecord();    //Exception
                 montrack.topic.description__c = 'Academic - Exam timetable'; 
                 montrack.saveTopicRecord();
                 
                 Id topicId=montrack.topic.id;
                 apexpages.currentPage().getParameters().put('tId',topicId);
                 montrack.deleteTopicRecord();
                 
                 //Referral
                 montrack.saveReferralRecord(); //Exception
                 montrack.referral.referral__c = 'Childcare';
                 montrack.saveReferralRecord();
                 
                 
                 Id referralId=montrack.referral.id;
                 apexpages.currentPage().getParameters().put('rId',referralId);
                 montrack.deleteReferralRecord();
                 
                 montrack.currentTask.Reaction_to_Call__c = '';
                 montrack.currentTask.Duration_mins__c = '';
                 montrack.saveCall(); //Error
                 
                 montrack.currentTask.Reaction_to_Call__c = 'Well Received';
                 montrack.currentTask.Duration_mins__c = '5';
                 montrack.saveCall(); //Save
                 
                 
                 
                 
                 
                 //Topic Insert after Complete
                 montrack.topic.description__c = 'Academic - Exam timetable'; 
                 montrack.topic.type__c = 'Montrack';
                 montrack.saveTopicRecord();    //Error
                 //Referral after complete
                 montrack.referral.referral__c = 'Childcare';
                 montrack.saveReferralRecord();
                 
                 apexpages.currentpage().getparameters().put('tId',tskId);
                 apexpages.currentpage().getparameters().put('cId',conId);
                 montrack.taskClicked();
                 montrack.saveCall(); //Error //Completed Call
                 
                 montrack.deleteId=montrack.currentTask.id;
                 montrack.deleteTask();    //undo  //Exception
                 
                 
                 
                // montrack.clearContextStudent(); // cover off, and going to reset in next step
                 
                 apexpages.currentPage().getParameters().put('rId',referralId);
                 montrack.deleteReferralRecord();
                 
                 
                 
                 
                 montrack.resetChildObjects();
                 montrack.revertToListView();
                 montrack.dummyAction();
                 
                             
            }
        Test.stopTest();        
    }           
    static testMethod void throughToCompleteScenario() {
        //create user
        User u= TestHelper.ssaUser();
        //create account
        List<Account>acct= TestHelper.createStudent(10);
        insert acct;
        List<Contact> conList= TestHelper.createStudentContacts(10, acct);
        insert conList;
        Set<ID>accountID = new Set<ID>();
        for(Account a:acct){
            accountID.add(a.ID);
        }
        //create Campaign
        List<Campaign> camp=  TestHelper.createCampaign(1);
        insert camp;
        //create Cohort
        List<Cohort__c> cohort = TestHelper.createCohort(2);
        insert cohort;
        set<ID> contactID= new Set<ID> ();
        for(Contact con : conList){
            contactID.add(con.Id);
        }
        list<CampaignMember> cm= TestHelper.createCampaignMember(u.Id, cohort[0].id, camp[0].Id,contactID );
        insert cm;
        
        list<CampaignMember> tmpCM= new List<CampaignMember>();
        tmpCM=[SELECT ID,contactID,cohort__c,CampaignID FROM CampaignMember WHERE Cohort__c=:cohort[0].ID AND CampaignID=:camp[0].Id ];
        
        list<Round__c> rList= TestHelper.createRounds(tmpCM[0].Cohort__c, tmpCM[0].CampaignId, 4); 
        insert rList;
        
        
        Set<ID>roundID= new Set<ID>();
        for(Round__c r:rList){
            roundID.add(r.Id);
        }
            
        Test.startTest();
            System.runAs(u){
                
                // confirming can add tasks
                list<Task> taskList = new list<Task>();
                boolean callbackAdded = false;
                for(ID conID:contactID){
                Task newtask= new Task( whatId= rlist[3].id,
                                     whoId=conID,
                                     Subject='MonTRACK Call');
                                     if(!callbackAdded){
                                        newTask.Status = 'Call Back Requested by Student/Other';
                                        newTask.Call_Back_Date_Time__c = datetime.now().addHours(1);
                                        callbackAdded = true;
                                     }
                    taskList.add(newtask);
                }
                insert taskList;
                List<Task> task=[Select Id, WhatID FROM Task where WhatID =:rlist[3].id];
                
                
         
                 PageReference ref = Page.mt_main;
                 Test.setCurrentPage(ref);
                 mt_mainControllerCC montrack = new mt_mainControllerCC();
                 
                 List<selectOption> cOptions = montrack.cohortOptions;
                 montrack.cohort = cohort[0].id;
                 List<selectOption> rOptions = montrack.roundOptions;
                 montrack.round = rList[3].id;
                 List<selectOption> uOptions = montrack.ssaUserOptions;
                 montrack.ssaUser = u.id;
                 montrack.retrieveCalls();
                 
                 string msg = montrack.nextCallbackMessage;
                 
                 system.assertEquals(10,montrack.taskDetailList.size());    // expect one task for each of the 10 students enrolled to montrack
                 // we have list, so simulate selection from list 
                 id tskId = montrack.taskDetailList[0].taskId;
                 id conId = montrack.taskDetailList[0].contactId;
                 
                 apexpages.currentpage().getparameters().put('tId',tskId);
                 apexpages.currentpage().getparameters().put('cId',conId);
                 montrack.taskClicked();
                 
                 taskDetail td = montrack.tdetail; // simulate getter by VF page
                 montrack.testRoundTasks = montrack.otherRounds; // simulate get by VF page 
                 montrack.testTaskHistory = montrack.taskHistories; // simulate get by VF page
                 
                 // confirm input fields 
                 system.assertEquals('Not Started',montrack.currenttask.status);
                 
                 // test the save call validation
                 montrack.resetChildObjects(); // simulate onchange action and then save
                 montrack.currenttask.status = 'Not Started';
                 //montrack.currentTask.Call_Back_Date_Time__c= System.Now();                
                 montrack.saveCall();
                 system.assertEquals('msg2',montrack.errorMsg); // should have prevented save
                 
                 boolean b=montrack.renderTaskTable;               
                 mt_mainControllerCC.roundTask rt=new mt_mainControllerCC.roundTask();
                 rt.cohort=null;
                 rt.round=null;
                 rt.task=null;
                 rt.SSAName=null;
                 rt.createdDate=null;
                 montrack.editOnlyMode=true;
                 
                 montrack.resetChildObjects(); // simulate onchange action and then save
                 montrack.currenttask.status = 'Call Back Requested by Student/Other';
                 //montrack.currentTask.Call_Back_Date_Time__c= System.Now();                
                 montrack.saveCall();
                 system.assertEquals('msg3',montrack.errorMsg); // should have prevented save
                 montrack.currenttask.status = 'No Answer';
                 montrack.resetChildObjects(); // simulate onchange action and then save
                 montrack.currenttask.status = 'No Answer';
                 montrack.currentContact.MonTrack_Opt_Out__c = true;
                 //montrack.currentTask.Call_Back_Date_Time__c= System.Now();                
                 montrack.saveCall();
                 system.assertEquals('msg4',montrack.errorMsg); // should have prevented save
                 
                 montrack.resetChildObjects(); // simulate onchange action and then save
                 montrack.currenttask.status = 'No Answer';
                 montrack.currentContact.MonTrack_Opt_Out__c = true;
                 montrack.currentContact.MonTrack_Opt_Out_Reason__c='Reason'; 
                 montrack.saveCall();
                 
                 // is first call, so save with a not completed result
                 montrack.resetChildObjects(); // simulate onchange action and then save
                 montrack.currenttask.status = 'No Answer';
                 montrack.saveCall();
                 
                 // pull up same again - confirm is now onto second call attempt
                 apexpages.currentpage().getparameters().put('tId',tskId);
                 apexpages.currentpage().getparameters().put('cId',conId);
                 montrack.taskClicked();
                 
                 // register second call attempt without topic and referral
                 montrack.resetChildObjects(); // simulate onchange action and then save
                 montrack.currenttask.status = 'Completed';
                 montrack.currentTask.Reaction_to_Call__c = 'Well Received';
                 montrack.currentTask.Duration_mins__c = '5';
                 montrack.currentTask.Call_Back_Date_Time__c= System.Now();                
                 montrack.saveCall();
                 system.assertEquals('msg0',montrack.errorMsg);  // expect call not to have been saved
                 
                 
                               
                 id tmpId = montrack.currentTask.id; // store this for delete action later in test method
                 
                 // now add a topic and referral, then try to save as completed again
                 
                 montrack.topic.type__c = 'Montrack';
                 montrack.topic.description__c = 'Academic - Exam timetable';
                 montrack.saveTopicRecord();
                 system.assertEquals(1,[ select count() from topic__c where round__c =:montrack.round and student__c =:montrack.contactId]); // confirm insert success
                 
                 montrack.referral.referral__c = 'Childcare';
                 montrack.saveReferralRecord();
                 system.assertEquals(1,[select count() from referrals__c where round__c =:montrack.round and student__c =:montrack.contactId]); // confirm insert success
                 
                 montrack.saveCall(); // expect a successful save this time
                 montrack.clearContextStudent(); // cover off, and going to reset in next step
                 
                 // having saved successfully, now try to save over the top of the completed task
                 apexpages.currentpage().getparameters().put('tId',tskId);
                 apexpages.currentpage().getparameters().put('cId',conId);
                 montrack.taskClicked();                 
                 montrack.saveCall();
                 system.assertEquals('msg1',montrack.errorMsg);
                 
                 montrack.onChangeRefreshList(); // just to run the logic
                 
                 // test delete option
                 
                 montrack.deleteId = tmpId;
                 montrack.deleteTask(); // attempt to delete task added 
                 
                                 
                 // now change cohort and round vals to cover the reset functions
                 montrack.resetRoundAndUser(); // this called on cohort picklist change
                 montrack.cohort = cohort[0].id;
                 montrack.resetUser();
           }           
       Test.stopTest();
    }
    
        static testMethod void throughToNoResultScenario() {
        //create user
        User u= TestHelper.ssaUser();
        //create account
        List<Account> acct= TestHelper.createStudent(10);
        insert acct;
        system.debug('######acct'+acct);
        List<Contact> conList= TestHelper.createStudentContacts(10, acct);
        insert conList;
        Set<ID>accountID = new Set<ID>();
        for(Account a:acct){
            accountID.add(a.ID);
        }
        system.debug('######conList'+conList);
        //create Campaign
        List<Campaign> camp=  TestHelper.createCampaign(1);
        insert camp;
        system.debug('######'+camp);
        //create Cohort
        List<Cohort__c> cohort = TestHelper.createCohort(2);
        insert cohort;
        system.debug('######'+cohort);
        set<ID> contactID= new Set<ID> ();
        for(Contact con:conList){
            contactID.add(con.Id);
        }
        system.debug('######contactID'+contactID);
        list<CampaignMember> cm= TestHelper.createCampaignMember(u.Id, cohort[0].id, camp[0].Id,contactID );
        insert cm;
        system.debug('######'+cm);
        list<CampaignMember> tmpCM= new List<CampaignMember>();
        tmpCM=[SELECT ID,contactID,cohort__c,CampaignID FROM CampaignMember WHERE Cohort__c=:cohort[0].ID AND CampaignID=:camp[0].Id ];
        system.debug('######'+tmpCM);
        list<Round__c> rList= TestHelper.createRounds(tmpCM[0].Cohort__c, tmpCM[0].CampaignId, 4); 
        insert rList;
        
        
        Set<ID>roundID= new Set<ID>();
        for(Round__c r:rList){
            roundID.add(r.Id);
        }
            
        Test.startTest();
            System.runAs(u){
                
                // confirming can add tasks
                list<Task> taskList = new list<Task>();
                for(ID conID:contactID){
                Task newtask= new Task( whatId= rlist[3].id,
                                     whoId=conID,
                                     Subject='MonTRACK Call');
                    taskList.add(newtask);
                }
                insert taskList;
                List<Task> task=[Select Id, WhatID FROM Task where WhatID =:rlist[3].id];
                
                
         
                 PageReference ref = Page.mt_main;
                 Test.setCurrentPage(ref);
                 mt_mainControllerCC montrack = new mt_mainControllerCC();
                 
                 List<selectOption> cOptions = montrack.cohortOptions;
                 montrack.cohort = cohort[0].id;
                 List<selectOption> rOptions = montrack.roundOptions;
                 montrack.round = rList[3].id;
                 List<selectOption> uOptions = montrack.ssaUserOptions;
                 montrack.ssaUser = u.id;
                 montrack.retrieveCalls();
                 system.assertEquals(10,montrack.taskDetailList.size());    // expect one task for each of the 10 students enrolled to montrack
                 // we have list, so simulate selection from list 
                 id tskId = montrack.taskDetailList[0].taskId;
                 id conId = montrack.taskDetailList[0].contactId;
                 
                 apexpages.currentpage().getparameters().put('tId',tskId);
                 apexpages.currentpage().getparameters().put('cId',conId);
                 montrack.taskClicked();
                 
                 // confirm input fields 
                 system.assertEquals('Not Started',montrack.currenttask.status);
                 
                 // is first call, so save with a not completed result
                 montrack.resetChildObjects(); // simulate onchange action and then save
                 montrack.currenttask.status = 'No Answer';
                 montrack.saveCall();
                 
                 // pull up same again - confirm is now onto second result
                 apexpages.currentpage().getparameters().put('tId',tskId);
                 apexpages.currentpage().getparameters().put('cId',conId);
                 montrack.taskClicked();
                 system.assertEquals('First Attempt',montrack.roundTask.Call_Attempt__c);
                 
                 // register second call attempt and add a topic and referral whilst doing so
                 montrack.resetChildObjects(); // simulate onchange action and then save
                 montrack.currenttask.status = 'No Answer';
                 
                 montrack.topic.type__c = 'Montrack';
                 montrack.topic.description__c = 'Academic - Exam timetable';
                 montrack.saveTopicRecord();
                 system.assertEquals(1,[ select count() from topic__c where round__c =:montrack.round and student__c =:montrack.contactId]); // confirm insert success
                 
                 montrack.referral.referral__c = 'Childcare';
                 montrack.saveReferralRecord();
                 system.assertEquals(1,[select count() from referrals__c where round__c =:montrack.round and student__c =:montrack.contactId]); // confirm insert success
                 
                 
                 // now also confirm delete function for newly inserted topic
                 apexpages.currentPage().getParameters().put('tId',montrack.topic.id);
                 montrack.deleteTopicRecord();
                 system.assertEquals(0,[select count() from topic__c where student__c =:montrack.ssaUser and round__c =:montrack.round]);
                 
                 // and confirm referral can be deleted
                 apexpages.currentPage().getParameters().put('rId',montrack.referral.id);
                 montrack.deleteReferralRecord();
                 system.assertEquals(0,[select count() from referrals__c where student__c =:montrack.ssaUser and round__c =:montrack.round]);
                 
                 
                 montrack.saveCall();
                 
                 // pull up same again - confirm is onto third call attempt
                 apexpages.currentpage().getparameters().put('tId',tskId);
                 apexpages.currentpage().getparameters().put('cId',conId);
                 montrack.taskClicked();
                 system.assertEquals('Second Attempt',montrack.roundTask.Call_Attempt__c);
                 
                 // register third attempt
                 montrack.resetChildObjects(); // simulate onchange action and then save
                 montrack.currenttask.status = 'No Answer';
                 montrack.saveCall();
                 
                 // pull up same and confirm can no longer log calls
                 apexpages.currentpage().getparameters().put('tId',tskId);
                 apexpages.currentpage().getparameters().put('cId',conId);
                 montrack.taskClicked();
                 system.assertEquals('Third Attempt',montrack.roundTask.Call_Attempt__c);
                 system.assertEquals('Third Attempt made. No more call attempts possible.',montrack.callAttemptNote);
                 
                 // register third attempt
                 montrack.resetChildObjects(); // simulate onchange action and then save
                 montrack.currenttask.status = 'No Answer';
                 montrack.saveCall();
                 
                 // pull up same and confirm can no longer log calls
                 apexpages.currentpage().getparameters().put('tId',tskId);
                 apexpages.currentpage().getparameters().put('cId',conId);
                 montrack.taskClicked();
                 
                 
           }           
       Test.stopTest();
    }
        
         
}