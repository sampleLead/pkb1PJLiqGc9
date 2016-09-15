/**
* 27.1.15 CV (PWC) 
* Rewrite of the logic originally prepared by Cloudsherpas for Montrack custom UI.
* Rewrite required to remove the use of heavy javascript front end, hardcoded element refs and remoting method to perform DML
* Bulk of logic carried over from original where possible. Very little time to redo from scratch so some 'interesting' code remains for now.
* Added ExLog inserts in the try catches, which were also added around DML statements.
* Montrack uses a 'Call Only Attempt' field on Task to differentiate between a 'master' task record on which the current round progress is noted,
 and 'subordinate' tasks that result from call activity that was not successful i.e. no answer or voicemail reached.
* When a call is made, a 'subordinate' task is added to document the attempt.  Success or failure is tracked on the master task record.
* <p>
* 30.11.2015 Sayantan Dutta(PwC)
* Rewrite of the logic to align with the data model of UniCRM 2.0
* References of Person Accounts removed
* Exception logs and other custom objects remain the same
* No change in logic added  in MonTRACK
* <p>
* 28.04.16 CV(PwC)
* update to logic to allow three call attempts. Was set to two only.
*/
public with sharing class mt_mainControllerCC {

    public id MONTRACK_RECORDTYPE {
        get{ return CommonServices.recordTypeId('Task','MonTrack'); }
    } 
    
    static final String COMPLETED = TaskServices.COMPLETED;
    static final String NOT_STARTED = TaskServices.NOT_STARTED;
    static final String NOT_APPLICABLE = TaskServices.NOT_APPLICABLE;
    
    public boolean renderTaskTable {
        get{
            if(taskDetailList == null) { return false; } 
            else {
                return (taskDetailList.size() == 0) ? false : true;
            }
        }
    }
    public list<taskDetail> taskDetailList {get;set;}
    public string listFilter {get;set;} // used to store the task list filtering used i.e. all records, or only incomplete etc.
    list<task> tList {get;set;}
    public boolean showUserDetailsSelect {get;set;}
    public boolean showCallSelect {get;set;}
    public boolean sortOrder {get;set;} // toggle for use in table column sorting logic
    public string colFilter {get;set;} // tracks filter type to apply to task list
    public id taskId {get;set;} // task that user selects from table in UI
    private boolean runInitialSort {get;set;} 
    public id contactId {get;set;} // id of the student that is linked to the task that is in focus
    public Task currentTask {get;set;} // context task ie the attempt that SSA is making now
    public Task roundTask {get;set;} // the task that reflects how many attempts made during the round
    public string errorMsg {get;set;} // used during testing
    public string cohort {get;set;}
    public string round {get;set;}
    public string ssaUser {get;set;}
    public boolean disableRoundSelect {get;set;}
    public Contact currentContact {get;set;}
    public String callAttemptNote {get;set;} // for use in UI
    public Referrals__c referral {get;set;}
    public Topic__c topic {get;set;}
    public boolean showListViewMessage {get;set;}
    public boolean viewList {get;set;} // to toggle view
    public string loadedTaskStatus {get;set;} // used at validation prior to task save
    public list<roundTask> testRoundTasks {get;set;} // used by test method
    public list<taskHistory> testTaskHistory {get;set;} // used by test method
    public boolean editOnlyMode {get;set;} // if true, then we dont insert a new task at saveCall method as editing existing task only
    public boolean allowToUpdate {get;set;} // used in UI to control button visibility
    public boolean saveCallClicked {get;set;} // used to control which message panels are rendered
    public boolean lastChanceUndo {get;set;} // used to provide a user single chance to undo an accidental call complete
    public id deleteId {get;set;} // used when new tasks inserted and an undo option needs to be provided
    public boolean forceListView {get{if(forceListView == null) forceListView = false; return forceListView;} set;} // used to force change to list view filter.
    public string colClicked {get;set;} // flag used to help with sorting 
    
    private Set<id> roundIds; // used to verify user input prior to dynamic soql
    private Set<id> ssaUserIds; // used to verify user input prior to dynamic soql
    
    // feedback current next callback that is in detailList
    
    public string nextCallbackMessage {
        get{
            string msg = null;
            if(taskDetailList == null) taskDetailList = new list<taskDetail>();
            if(taskDetailList.isEmpty()){
                // do nothing and return an empty string
            } else {
                // cycle through and look for next callback due today
                datetime nextCallback = null;
                taskDetail nextTd = null;
                for(taskDetail td : taskDetailList){
                    if(td.taskRecord.Call_Back_Date_Time__c != null){
                        if(((nextCallback == null) || (td.taskRecord.Call_Back_Date_Time__c < nextCallback)) && td.taskRecord.Call_Back_Date_Time__c.date() == date.today()){
                            if(td.taskRecord.Call_Back_Date_Time__c > datetime.now()) {
                                nextCallback = td.taskRecord.Call_Back_Date_Time__c;
                                nextTd = td;
                            }
                        }
                    }
                }
                // if we have an actual callback today then convert to a string message to display
                if(nextCallback != null) {
                    string mins = (nextCallback.minute() < 10) ? '0'+string.valueOf(nextCallback.minute()) : String.valueOf(nextCallback.minute());
                    msg = 'Next future callback for today is scheduled for '+nextCallback.hour()+':'+mins + ' to '+nextTd.firstname+' '+nextTd.lastname;
                }
            }
            return msg;
        }
        
    }
    
    // carried over from original build
    public class roundTask{
        public String cohort{get;set;}
        public Round__c round{get;set;}
        public Task task{get;set;}
        public String SSAName{get;set;}
        public String createdDate{get;set;}
        public roundTask(){
        }
    }
    public class TaskHistory{
        public Task ta{get;set;}
        public String myCreaDate{get;set;}
        public String myCallBackDate{get;set;}
        public String friendlyCreatedDate {get;set;}
        public Integer daysAgo {get;set;} 
    }
    
    // if call status changed by user, then reset the topic and referral objects
    public pageReference resetChildObjects(){
        //referral = new Referrals__c();
        //topic = new Topic__c();
        return null;
    }
    
    public pageReference saveCall(){
        saveCallClicked = true;
        errorMsg = ''; // referenced in test method
        // perform validation prior to completing save
        if(roundTask.status != COMPLETED && currentTask.status == COMPLETED ){
            integer referralCount = relatedReferrals.size();
            integer topicCount = relatedTopic.size();
            referralCount += (referral.Referral__c == NOT_APPLICABLE) ? 1 : 0;
            topicCount += (topic.type__c == NOT_APPLICABLE) ? 1:0;
            if(!(referralCount > 0 && topicCount > 0)){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Complete your call after topic and referral selections have been filled in.'));
                errorMsg = 'msg0'; // referenced in test method
                return null;
            }
        }
        
        
        // validate prior to attempting save
        if(currentTask.status == COMPLETED && !(currentTask.Reaction_to_Call__c > '' && currentTask.Duration_mins__c > '')){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please enter a value for both the Reaction to Call and the Duration (mins) fields before saving.'));
            errorMsg = 'msg0'; // referenced in test method
            return null;
        }
        
        if(roundTask.Status== COMPLETED){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Cannot save over the top of a completed call.'));
            errorMsg = 'msg1'; // referenced in test method
            return null;
        }
        
        if(currentTask.Status== NOT_STARTED){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select a valid Call Outcome for this Call.'));
            errorMsg = 'msg2'; // referenced in test method
            return null;
        }
        
        if(currentTask.Status == 'Call Back Requested by Student/Other' && (currentTask.Call_Back_Date_Time__c < datetime.now() || currentTask.Call_Back_Date_Time__c == null)){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please enter a callback date.'));
            errorMsg = 'msg3'; // referenced in test method
            return null;
        }
        system.debug('cc='+currentContact);
        if( currentContact.MonTrack_Opt_Out__c && (currentContact.MonTrack_Opt_Out_Reason__c == '' || currentContact.MonTrack_Opt_Out_Reason__c == null)){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You must provide a reason if the Student is opting out of the program.'));
            errorMsg = 'msg4'; // referenced in test method
            return null;
        }
                
                
                
        String nextCallAttempt=''; 
                
                
        if (roundTask.Call_Attempt__c == null || roundTask.Call_Attempt__c == '' || roundTask.Call_Attempt__c == 'New') { nextCallAttempt='First Attempt'; } else
        if (roundTask.Call_Attempt__c == TaskServices.FIRST_ATTEMPT) { nextCallAttempt = TaskServices.SECOND_ATTEMPT; } else
        if (roundTask.Call_Attempt__c == TaskServices.SECOND_ATTEMPT) { nextCallAttempt = TaskServices.THIRD_ATTEMPT; } else                   
        if (roundTask.Call_Attempt__c == TaskServices.THIRD_ATTEMPT) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No further call attempts can be made.'));
            return null;
        }   
                   
                    
                // Update the existing Task and add followup task if havent completed call round for this student
        //if(currentTask.Status != COMPLETED) {
        // need to update the round task to reflect this attempt, and add a 'call attempt only' task to log the attempt
        roundTask.Status = currentTask.status;
        roundTask.Call_Attempt__c = nextCallAttempt;
        roundTask.activityDate = System.today();
        boolean taskInsertOk = false;
            
        // log this current call attempt
        currentTask.Subject= TaskServices.MONTRACK_CALL_SUBJECT;
        currentTask.WhatId=round;
        currentTask.WhoId=contactId;
        currentTask.OwnerId= UserInfo.getUserId();
        currentTask.Call_Attempt__c= roundTask.Call_Attempt__c;
        currentTask.Call_Attempt_Only__c=true;
        currentTask.RecordTypeId = MONTRACK_RECORDTYPE;
            
        try{
            insert currentTask; 
            taskInsertOk = true;
            // added 13-2-15 CV - need to push callback date (if provided) to the taskDetailList, so that view can be refreshed with call data in it.
            if(currentTask.Call_Back_Date_Time__c != null){
                roundtask.Call_Back_Date_Time__c = currentTask.Call_Back_Date_Time__c;
                // need to store this on the current taskDetailList prior to it being rerendered, so appears in the list view at left of UI
                for(taskDetail td : taskDetailList){
                    if(td.taskId == taskId){
                    
                        // found the context record, so update the callback datetime info
                        roundtask.Call_Back_Date_Time__c = currentTask.Call_Back_Date_Time__c;
                        
                    }
                }
            }
            
        } catch (exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error during call save. Try again.'+ex.getMessage()));
            errorMsg = 'msg6';
            return null; // abort save process
        } 
        // now update the roundtask only because the currentTask record was saved ok.   
        if(taskInsertOk){
            try{
                TaskServices.updateTaskRecords(new List<Task>{ roundTask });
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Call saved.'));
                deleteId = currentTask.id; // used by undo option
                // final step is if was a callback then setup list to look at other callbacks
                
                // push opt out reasons to contact record if required
                if(currentContact.MonTrack_Opt_Out__c){
                    try{
                        ContactServices.updateMontrackFields(currentContact);
                    } catch (exception ex){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error during student info update. Try again.'));
                        errorMsg = 'msg7';
                        return null;
                    }
                }
                referral = new Referrals__c();
                topic = new Topic__c(); 
                loadTaskDetailList(); // rebuild list view to reflect 
                setRecordValues(); // this updates vars to reflect current call status
                lastChanceUndo = true; // allow user to undo if required
                 
                return null;
            } catch (exception ex){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error during call update. Try again.'));
                errorMsg = 'msg5';
                ExLog.add('Class','mt_mainControllerCC','saveCall',ex);
                return null;    
            }
        }
             
              
        
        return null;    
    }
    
    
    /** Method called when deleting a Task from the 
    * Call Attempt History section of the page
    * 11-April-2014 Nick Forsyth 
    * 29-1-15 CV - removed this option from the UI, as concerned it doesnt work properly
    * 29-1-15 CV - reworked 
    */
    public pageReference deleteTask(){
        
        try{
            task tDelete = new task(id = deleteId);
            TaskServices.deleteTaskRecords( new List<Task>{ tDelete});
            
        } catch (exception ex){
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error occured during delete.'+ex.getMessage()));
            ExLog.add('Class','mt_mainControllerCC','deleteTask (at delete tDelete)',ex);
            return null;
            
        }
        
        // success, so now sort out the 'not call only' task attempt status to align to the now most recent history
        if(!TaskHistories.isEmpty()){
            
            Task mostRecentCall = taskHistories[0].ta;
            roundTask.Call_Attempt__c = mostRecentCall.Call_Attempt__c;
            roundTask.Status = mostRecentCall.Status;
        
            
        } else {
        
            // no history left, so set to initial values
            roundTask.Call_Attempt__c = '';
            roundTask.Status = NOT_STARTED;
        }
        
        try{
            
            TaskServices.updateTaskRecords(new List<Task>{roundTask});
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Deleted.'));
            setRecordValues(); // refresh now that things have changed
            deleteId = null; //used it up
            
        } catch (exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error occured during delete.'+ex.getMessage()));
            ExLog.add('Class','mt_mainControllerCC','deleteTask (at update roundTask)',ex);
        }
        
        return null; 
    }
    
    
    
    public PageReference setRecordValues() {
        
        if(taskID!=null){
            
            roundTask=[SELECT Call_Attempt__c,Status, Reaction_to_Call__c,
                                WhatID,WhoID,Duration_mins__c, Call_Attempt_Only__c, 
                                Description,ActivityDate,ID,Subject,OwnerID,Call_Back_Date_Time__c
                                FROM Task WHERE ID=:taskID];
            
            currentTask = new Task(Status = NOT_STARTED, recordTypeId = MONTRACK_RECORDTYPE);
             
            // also need to set the instructions to user about which call attempt they're up to
            
            allowToUpdate = true; // default. Only allowed three attempts
            
            if(roundTask.Call_Attempt__c == '' || roundTask.Call_Attempt__c == null) { callAttemptNote = 'New'; } else
            if(roundTask.Call_Attempt__c == 'Third Attempt') { callAttemptNote = 'Third Attempt made. No more call attempts possible.'; allowToUpdate = false; } else
            if(roundTask.Call_Attempt__c == 'First Attempt'){ callAttemptNote = 'Second Attempt'; } else
            if(roundTask.Call_Attempt__c == 'Second Attempt'){ callAttemptNote = 'Third Attempt'; } 
            if(roundTask.Status == COMPLETED) { callAttemptNote = COMPLETED; allowToUpdate = false; }
                               
            currentContact=[SELECT Id, MonTrack_Opt_Out__c, MonTrack_Opt_Out_Reason__c FROM Contact WHERE id = : contactID];  
                
            
            
        
            
        } 
        
        return null;
    }
    
    public list<TaskHistory> taskHistories{
        get{
            taskHistories=new list<TaskHistory>();
            if(round != '' && contactId != null){                
                for(Task t:[SELECT ID, Call_Attempt__c,Status, Reaction_to_Call__c,
                                    Duration_mins__c, Call_Attempt_Only__c, OwnerId,
                                    Description,CreatedDate,LastModifiedDate,Call_Back_Date_Time__c
                                    FROM Task WHERE 
                                    WhatId=:round
                                    AND WhoId=:ContactID
                                    AND Call_Attempt_Only__c = true 
                                    order by Call_Attempt__c desc ]){
                    if (t.Call_Attempt_Only__c){
                        TaskHistory th= new TaskHistory();
                        th.ta=t;
                        th.myCreaDate=getTimeZoneTime(t.CreatedDate); 
                        th.friendlyCreatedDate = t.CreatedDate.format('EEE, d MMM yy HH:mm'); 
                        th.daysAgo = date.newInstance(t.CreatedDate.year(),t.CreatedDate.month(),t.CreatedDate.day()).daysBetween(System.today());         
                        if (t.Call_Back_Date_Time__c != null) {
                            th.myCallBackDate=getTimeZoneTime(t.Call_Back_Date_Time__c);
                        }   
                        taskHistories.add(th);
                    } else {
                        if(t.Status==COMPLETED){
                            TaskHistory th= new TaskHistory();
                            th.ta=t;
                            th.myCreaDate=getTimeZoneTime(t.LastModifiedDate);  
                            if (t.Call_Back_Date_Time__c != null) {
                                th.myCallBackDate=getTimeZoneTime(t.Call_Back_Date_Time__c);
                            }                           
                            taskHistories.add(th);
                        
                        }
                        
                    }
                }
            }
            return taskHistories;
        }
    
        set;
    }
    
    public list<Referrals__c> relatedReferrals{
        get{
            relatedReferrals= new List<Referrals__c>();
            if(contactId != null) {
                relatedReferrals=[SELECT Round__r.Round_Number__c, Round__r.Cohort__r.name, Referral__c, SSA_Identified__r.Name 
                            FROM Referrals__c WHERE Student__c =: contactID ORDER BY LastModifiedDate DESC];   
            }
            return relatedReferrals;
        }
        set;
    } 
    
    /** return all related topics for current round and student */
    
    public list<Topic__c> relatedTopic{
        get{
            relatedTopic= new List<Topic__c>();
            if(round != '' && contactId != null){
                relatedTopic=[SELECT Round__r.Round_Number__c,Type__c, Description__c, SSA_Identified__r.Name 
                            FROM Topic__c WHERE Round__c =: round AND Student__c =: contactID];   
            }
            return relatedTopic;
        
        }
        set;
    }
    
    /** page action to delete a referral record from the call */
    
    public pageReference deleteReferralRecord(){
        id refId = apexpages.currentPage().getParameters().get('rId');
        if(refId != null){
            Referrals__c ref = new Referrals__c(id = refId);
            try{
                delete ref;
            } catch (exception ex){
                ExLog.add('Class','mt_mainControllerCC','deleteReferralRecord',ex);
                ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Error occured:'+ex.getMessage());
                ApexPages.addMessage(errMsg);
            }
        }
        return null;
    }
    
    /** page action to save a referral record for current student */
    
    public pageReference saveReferralRecord(){
        if(referral.Referral__c == null){
            referral.Referral__c.addError('This is a required field when adding a referral.');
            return null;
         }
        
        if(taskID != null){ 
            Task tmpTask=[SELECT Status FROM Task WHERE Call_Attempt_Only__c=false AND ID=:taskID];
            if(tmpTask!=null&& tmpTask.Status!=COMPLETED){
                if(referral.Referral__c!=null){
                    Referrals__c ref= new Referrals__c();
                    ref.Round__c = round;
                    ref.Student__c = contactID;
                    ref.Referral__c = referral.Referral__c;
                    ref.SSA_Identified__c = UserInfo.getUserId();
                    try{
                        insert ref;
                    } catch (exception ex){
                        ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Error during save attempt. Try again.');
                        ApexPages.addMessage(errMsg);
                        ExLog.add('Class','mt_mainControllerCC','saveReferralRecord',ex);
                        return null;
                    }
                    if(!Test.isRunningTest()) referral = new Referrals__c(); 
                    
                }else{
                    ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.montrack_ref_err1);
                    ApexPages.addMessage(errMsg);
                }           
            }else{
                ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'You cannot add a Referral after a call has been completed.');
                ApexPages.addMessage(errMsg);
            }        
        }
        saveCallClicked = false;
        return null;
    }
    
    /** page action to delete a topic */
    
    public pageReference deleteTopicRecord(){
        id topicId = apexpages.currentPage().getParameters().get('tId');
        if(topicId != null){
            Topic__c top = new Topic__c(id = topicId);
            try{
                delete top;
            } catch (exception ex){
                ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Error occured:'+ex.getMessage());
                ApexPages.addMessage(errMsg);
                ExLog.add('Class','mt_mainControllerCC','deleteTopicRecord',ex);
            }
        }
        return null;
    }
    
    /** page action to save a topic */
    
    public pageReference saveTopicRecord(){
         if(topic.Type__c == null){
            topic.Type__c.addError('This is a required field when adding a topic.');
            return null;
         }
        if(topic.Type__c != 'Not Applicable' && (topic.Description__c == null || topic.Description__c == '')){
            topic.Description__c.addError('This is a required field for this topic type.');
            return null;
        }
         
         if(taskId !=null){  
            Task tmpTask=[SELECT Status FROM Task WHERE Call_Attempt_Only__c=false AND ID=:taskID limit 1];
            if(tmpTask!=null&& tmpTask.Status!=COMPLETED){
                Round__c r=[SELECT Round_Number__c FROM Round__c WHERE ID=:round];
                if(topic.Type__c!=null && topic.Description__c!=null){
                
                        Topic__c tp= new Topic__c();
                        tp.Round__c=round;
                        tp.Student__c=contactID;
                        tp.Type__c=topic.Type__c;
                        tp.Description__c=topic.Description__c;
                        tp.SSA_Identified__c=UserInfo.getUserId();
                        try{
                            insert tp;
                        } catch (exception ex){
                            ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Error during save attempt. Try again.');
                            ApexPages.addMessage(errMsg);
                            ExLog.add('Class','mt_mainControllerCC','savetopicRecord',ex);
                            return null;
                        }
                        topic= new Topic__c();
                    
                    
                }else{
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please select both a Type and Description.');
                    ApexPages.addMessage(myMsg);
                }           
            }else{
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'You cannot add a Topic after a call has been completed.');
                    ApexPages.addMessage(myMsg);
            }
         }
         saveCallClicked = false;
        return null;
    }
    
    /** retrieves a list of montrack activities for current contact for other rounds 
     * @return list of custom wrapper records of type roundTask
     */ 
    public list<roundTask> otherRounds{
        get{
            otherRounds = new list<roundTask>();
            map<id,Round__c> mpRound= new map<id,Round__c>();
            map<id,User> mpUser= new map<id,User>();
            Set<ID> cID = new Set<ID>();
            
            for(Round__c r:[SELECT ID,  Round_Number__c ,Cohort__c
                            FROM Round__c limit 200]){ 
                cID.add(r.Cohort__c);               
            }
            
            for(Round__c r1: [SELECT ID,  Round_Number__c ,Cohort__c, Cohort__r.name
                              FROM Round__c
                              WHERE Cohort__c IN:cID]){
                              
                 mpRound.put(r1.ID,r1); 
            }
            
            for(User u:[SELECT ID, Name FROM User WHERE  SSA__c=TRUE])
                mpUser.put(u.ID,u);

            Id montrackRecordTypeId = CommonServices.recordTypeId('Task','MonTrack');
            system.assertNotEquals(null,montrackRecordTypeId);
                           
            for(Task taks:[SELECT Call_Attempt__c,Status, whoId,Reaction_to_Call__c,
                                Duration_mins__c, Call_Attempt_Only__c, OwnerID, LastModifiedById,
                                Description,ActivityDate,ID,Subject,WhatId,CreatedDate
                                FROM Task
                                WHERE whoId=:contactID
                                AND Status!=:NOT_STARTED
                                AND whatID!=:round
                                AND RecordTypeId = :montrackRecordTypeId order by CreatedDate DESC ]){
                                	
                        roundTask rt= new roundTask();
                        rt.round=mpRound.get(taks.WhatID);
                        rt.cohort = rt.round.Cohort__r.name;
                        
                        rt.task=taks;
                        if(taks.Status==COMPLETED)
                            rt.createdDate=getTimeZoneTime(taks.ActivityDate);
                        else
                            rt.createdDate=getTimeZoneTime(taks.CreatedDate);
                        rt.SSAName=(mpUser.containsKey(taks.LastModifiedById)) ? mpUser.get(taks.LastModifiedById).Name : 'Non SSA User';
                        otherRounds.add(rt);    
                }
        
            return otherRounds;
        }
    
        set;
    }
    
    public pageReference revertToListView(){
        viewList = true;
        return null;
    }
    
    public pageReference dummyAction(){
        return null;
    }
    
    /** retrieves some context attributes from UI */
    
    public pageReference taskClicked(){
        System.debug('Inside taskClicked');
        //viewList = false; // will render person details instead
        deleteId = null; // user loses the right to undo a save if they click away from call screen
        taskId = apexpages.currentpage().getParameters().get('tId');
        contactId = apexPages.currentPage().getParameters().get('cId');
        System.debug('tId :'+taskId);
        System.debug('cId :'+contactId);
        setRecordValues();
        return null;
    }
    
    /**  retrieves the details of a student when task is clicked in taskList */
    
    public TaskDetail tdetail{
        get{
            tdetail= new TaskDetail();
            if(taskId != null && round != '' && contactId != null){
                Round__c roundObj= new Round__c();
                roundObj= [SELECT cohort__c, cohort__r.name, round_number__c FROM Round__c Where ID=:round ];
                if(roundObj!=null)
                    tdetail.cohortID=roundObj.cohort__c;
                    tdetail.cohortName=roundObj.cohort__r.name;
                    tdetail.roundNumber=roundObj.round_number__c;
                    string course='';
                Contact cnct= new Contact();
                cnct= [SELECT Person_ID__c, FirstName, LastName,First_in_Family__c,International_Student__c, Course_Code__c,Course_Name__c,
                                        Faculty__c,Campus__c, Email,MailingCity, MailingPostalCode,
                                        Phone, HomePhone,MobilePhone
                                        FROM Contact 
                                        WHERE id = : contactId];
                if(cnct!=null){
                    tdetail.studentID=cnct.Person_ID__c;
                    tdetail.firstname=cnct.FirstName;
                    tdetail.lastname=cnct.LastName;
                    course='';
                    if(cnct.Course_Code__c!=null && cnct.Course_Code__c!='')
                        course='['+cnct.Course_Code__c+'] ';
                    if(cnct.Course_Name__c!=null && cnct.Course_Name__c!='')
                        course+=cnct.Course_Name__c;
                    tdetail.course=course;
                    tdetail.faculty=cnct.Faculty__c;
                    tdetail.Campus=cnct.Campus__c;
                    tdetail.monashEmail='';
                    tdetail.personalEmail=cnct.Email;
                    tdetail.suburb=cnct.Mailingcity;
                    tdetail.postcode=cnct.MailingPostalCode;
                    tdetail.phone1=cnct.Phone;
                    tdetail.phone2=cnct.HomePhone;
                    tdetail.phone3=cnct.MobilePhone;
                    tdetail.isFirstInFamily=cnct.First_in_Family__c;
                    tdetail.isInternational=cnct.International_Student__c;
                } 
            }
            return tdetail;
        }
            
        set;
    }
    
    /** re-sorts current list depending on column clicked */
    
    public pageReference sortTable(){
        String colFilterTmp = apexPages.currentPage().getParameters().get('colFilter'); // latest sort request
        if(colFilterTmp == colFilter && colFilterTmp > '' && colClicked == 'true') { sortOrder = !sortOrder; } //else { sortOrder = true; } // same column as current so just change sort order
        if(colFilterTmp > '') colFilter = colFilterTmp;
        
        
        
        // what if is initial sort ?
        if(runInitialSort){
            runInitialSort = false;
            colFilter = 'lastName';
            sortOrder = true;
        }
        
        

        // pull list into map and generate list for sorting
        Map<id,taskDetail> taskMap = new Map<id,taskDetail>();
        List<string> sortingList = new List<string>();
        for(taskDetail td : taskDetailList) {
            taskMap.put(td.taskid,td);
            // create a list of keys to sort
            td.callBackDateTime = (td.callBackDateTime < '') ? '' : td.callBackDateTime;
            if(colFilter == 'firstName') sortingList.add(td.firstname + '_' + td.taskid);
            if(colFilter == 'lastName') sortingList.add(td.lastname + '_' + td.taskid);
            if(colFilter == 'course') sortingList.add(td.course + '_' + td.taskid);
            if(colFilter == 'faculty') sortingList.add(td.faculty + '_' + td.taskid);
            if(colFilter == 'campus') sortingList.add(td.campus + '_' + td.taskid);
            if(colFilter == 'callAttempt') sortingList.add(td.CallAttempt + '_' + td.taskid);
            if(colFilter == 'callBackDateTime') sortingList.add(td.callBackDateTime + '_' + td.taskid);
            if(colFilter == 'status') sortingList.add(td.status + '_' + td.taskid);
        }
        // sort the list of strings
        sortingList.sort();
        List<string> finalSortedList = new List<string>();
        if(sortOrder){
            finalSortedList.addAll(sortingList); // ascending order
        } else {
            for(integer i= sortingList.size() ; i > 0; i--) finalSortedList.add(sortingList[i-1]); // descending order
        }
        sortingList.clear();
        // rebuild list for presentation using new keys to describe order
        taskDetailList.clear();
        for(string key : finalSortedList){
            string recordId = key.right(18); // only need the id of the record now we have completed sorting
            taskDetailList.add(taskMap.get(recordId));
        }
        colClicked = '';
        return null;
    }
    
    /** builds a list of filtering options to present to user using the task list
     * @return list of select options - one per filter option
     */
    public list<selectOption> filterOptions {
        get{
            list<selectOption> options = new list<selectOption>();
            List<string> optionList = new List<string>{'All',NOT_STARTED,'Incomplete',COMPLETED,'Call Back Requested by Student/Other','Invalid Phone Numbers'};
            for(string opt : optionList){
                options.add(new selectOption(opt,opt));
            }
            return options;
        }
    }
    
    /** page action to allow UI to hook into a task list refresh action */
    
    public pageReference onChangeRefreshList(){
        loadtaskDetailList();
        return null;
    }
    
    /** internal method to dynamically retrieve a list of relevant tasks, 
	 * sort them based on sort criteria selected, and then add to a task map 
	*/
    
    private void loadtaskDetailList(){
        if(taskDetailList == null) { 
            taskDetailList = new List<taskDetail>(); // handle instantiation
        }
        taskDetailList = new List<taskDetail>(); // reset 
        map<ID, Task> taskMap = new map<ID, Task>();
        map<ID , Contact> contactMap = new map<ID , Contact>();
        Set<ID> whoSet= new Set<ID>();
        // the following task retrieval is dynamic because user is selecting specific task types from a picklist in UI
        // added check to ensure no injection risk - must be one of the provided options, as stored in private sets internal to controller
        // 
        id rnd = (roundIds.contains(round)) ? round : null; // default and to prevent SOQL injection
        id ssaUsr = (ssaUserIds.contains(ssaUser)) ? ssaUser : null; // default and to prevent SOQL injection
        
        // only perform the soql if have valid rnd and ssauser inputs, otherwise return empty list
        if(rnd != null && ssaUsr != null){
            string query = 'Select Id, WhatId, OwnerId, WhoId, Subject, Status,Call_Attempt__c,Call_Back_Date_Time__c FROM Task WHERE WhatId = \''+ rnd +'\' AND OwnerId =\''+ ssaUsr +'\' AND Call_Attempt_Only__c=False ';
            string filter = (listFilter > '') ? String.escapeSingleQuotes(listFilter) : ''; // prevent SOQL injection
            if(filter != 'All'){
                // need to append the additional filter criteria
                if(filter == NOT_STARTED) { query += ' AND status =\'Not Started\''; } 
                else if(filter == 'Incomplete') { query += ' AND status !=\'Invalid Phone Numbers\' AND status!=\'Completed\' AND status!=\'Call Back Requested by Student/Other\' AND status!=\'Not Started\'';}
                else if(filter == 'Invalid Phone Numbers' || filter == COMPLETED || filter == 'Call Back Requested by Student/Other') { query += 'AND status=\''+filter+'\''; }
                
            }
            for(Task t: Database.query(query)){
                    whoSet.add(t.Whoid);
                    taskMap.put(t.Id, t);
            }
            for(Contact c:[SELECT ID, FirstName, 
                              LastName, 
                              Course_Code__c, 
                              Course_Name__c, 
                              Faculty__c, 
                              Campus__c,
                              MonTrack_Opt_Out__c
                        FROM Contact 
                        WHERE ID IN: whoSet]){
                contactMap.put(c.Id,c);
            }
        
            if(!taskMap.isEmpty()){
                String course='';
                Integer ctr = 0;
                for(Id taskId:taskMap.keySet()){
                    Task task=taskMap.get(taskID);
                    Contact con= contactMap.get(task.whoId);
                    TaskDetail td= new TaskDetail();
                    td.taskRecord = task;
                    td.contactID=con.Id;
                    td.roundID=task.WhatId;
                    td.taskID=task.Id;
                    td.num=ctr;
                    td.firstname=con.FirstName;
                    td.lastname=con.LastName;
                    course = '';
                    if(con.Course_Code__c!=null && con.Course_Code__c!='') course ='['+con.Course_Code__c+'] ';
                    if( con.Course_Name__c!=null && con.Course_Name__c!='') course += con.Course_Name__c;
                    td.Course=course;
                    td.Faculty=con.Faculty__c;
                    td.Campus=con.Campus__c;
                    td.CallAttempt=task.Call_Attempt__c;
                    td.status=task.Status;
                    if(task.Call_Back_Date_Time__c != null) 
                    {
                        td.callBackDateTime=getTimeZoneTime(task.Call_Back_Date_Time__c);
                    } 
                    // 30-1-15 CV : add colour code to use in UI
                    td.textBackgroundColour = ''; // default
                    td.datetimeColour = ''; // default
                    td.alternateDateTime = '';
                    string cellColour = '';
                    if(task.status == COMPLETED) { cellColour = 'LightGreen'; } else
                    if(task.status != 'Invalid Phone Numbers' && task.status != 'Call Back Requested by Student/Other' && task.status !=NOT_STARTED) { cellColour='yellow'; } else
                    if(task.status == 'Invalid Phone Numbers') { cellColour = '#FF8080'; } else 
                    if(task.status == 'Call Back Requested by Student/Other') { 
                        cellColour = 'LightBlue'; 
                        
                        if(task.Call_Back_Date_Time__c != null){
                            if(task.Call_Back_Date_Time__c < datetime.now()) td.datetimeColour = 'color:red;';
                            if(task.Call_Back_Date_Time__c.date() == date.today() && task.Call_Back_Date_Time__c.time() > datetime.now().time()) td.datetimeColour = 'color:green;';
                            string dy = '';
                            integer diff = date.today().daysBetween(task.Call_Back_Date_Time__c.date());
                            if(diff == 0) { dy = 'today '; } else
                            if(diff == -1) { dy = 'yesterday '; } else
                            if(diff == 1) { dy = 'tomorrow '; } else
                            if(diff < -1) { dy = String.valueOf(math.abs(diff))+' days ago '; } else
                            { dy = String.valueOf(math.abs(diff))+' days from now '; }
                            dy += ' at ';
                            dy += String.valueOf(task.Call_Back_Date_Time__c.hour()) + ':';
                            if(task.Call_Back_Date_Time__c.minute() < 10) dy += '0';
                            dy += task.Call_Back_Date_Time__c.minute();
                            td.alternateDateTime = dy;
                        }
                    } 
                    if(cellColour != '') td.textBackgroundColour = 'background-color:'+cellColour+';';
                    
                    
                    
                    
                    taskDetailList.add(td);
                    ctr ++;
                }
                
                
                //if(runInitialSort || colClicked == 'true') 
                sortTable(); // if setup then auto sort the table to defaults, otherwise let user run the sorting.
            } else {
                
            }
        }    
        
    }
    
    /** formatting utility to convert a datetime into a string */
    
    public String getTimeZoneTime(DateTime cDate){
        return (cDate != null) ? CDate.format('yyyy-MM-dd HH:mm:ss') : '';
        
    
    }
    
    /** page action called by JS, to initiate retrieval and sorting of task records */
    
    public PageReference retrieveCalls() {
        runInitialSort = true; // to automate initial sorting of list
        loadtaskDetailList(); // refresh the task list for user to select from
        return null;
    }


    /** resets round and context user related variables */
    
    public pageReference resetRoundAndUser(){
        round = '';
        ssaUser = '';
        taskid = null;
        contactId = null;
        if(taskDetailList != null) taskDetailList.clear();
        currentTask = new Task();
        loadedTaskStatus = '';
        return null;
    }
    
    /** reset variables related to 'context' user (SSA user selected) and clear task lists */
    public pageReference resetUser(){
        ssaUser = '';
        taskId = null;
        contactId = null;
        if(taskDetailList != null) taskDetailList.clear();
        currentTask = new Task();
        loadedTaskStatus = '';
        return null;    
    
    }
    
    /** reset variables related to context student */
    
    public pageReference clearContextStudent(){
        taskId = null;
        contactId = null;
        currentTask = new Task();
        return null;
    }
    
    /** builds a list of Cohorts to select from 
     * @return list of select option records - one per Cohort
     */
    public List<SelectOption> cohortOptions{
        get 
        {
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('', '-- Select --'));
            
            for (Cohort__c coh : [select id, name from Cohort__c order by name limit 100]) {
                options.add(new SelectOption(coh.id, coh.name));
            }
            return options;
        }
        set;
    }
    
    /** builds a list of Rounds to select from, based on Cohort selected
     * @return list of select option records - one per Round
     */
    
    public List<SelectOption> roundOptions {
        get
        {
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('', '-- Select --'));
            for (Round__c rnd : [select id, Round_Number__c from Round__c where Cohort__c = : cohort order by round_number__c]) {
                options.add(new SelectOption(rnd.id, rnd.Round_Number__c));
                roundIds.add(rnd.id);
            }
            disableRoundSelect = (cohort != '' && options.size() > 1) ? false : true;
            return options;
        }
        set;
    }

    /** builds a list of SSA Users to select from 
     * @return list of select option records - one per SSA user
     */
    public List<SelectOption> ssaUserOptions {
        get
        {
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('', '-- Select --'));
            for (User usr : [select id, name from User WHERE SSA__c = TRUE AND IsActive = TRUE order by name]) {
                options.add(new SelectOption(usr.id, usr.name));
                ssaUserIds.add(usr.id);
            }
            return options;
        }
        set;
    }



	/** instantiation method to init variables */
    
    public mt_mainControllerCC(){
        tList = new List<task>();
        showUserDetailsSelect = true;
        showCallSelect = false;
        cohort = '';
        round = '';
        disableRoundSelect = true;
        listFilter = 'All';
        sortOrder = false; // default sorting order
        colFilter = 'lastName'; // default sorting column
        currentTask = new Task();
        roundTask = new Task();
        currentContact = new Contact();
        callAttemptNote = '';
        referral = new Referrals__c();
        topic = new Topic__c();
        showListViewMessage = true;
        viewList = true;
        loadedTaskStatus = ''; 
        saveCallClicked = true;
        errorMsg = '';
        allowToUpdate = true;
        lastChanceUndo = false;
        deleteId = null;
        forceListView = false;
        colClicked = '';
        roundIds = new Set<id>();
        ssaUserIds = new Set<id>();
    }


}