/**
 * Wrapper class used by mt_mainControllerCC
 * @author Sayantan Dutta (PWC) 
 * @see mt_mainControllerCC.cls
*/
public with sharing class TaskDetail {
    public ID contactID{get;set;}
    public ID taskID{get;set;}
    public ID roundID{get;set;}
    public string roundNumber{get;set;}
    public integer num{get;set;}
    public string firstname{get;set;}
    public string lastname{get;set;}
    public string Course{get;set;}
    public string Faculty{get;set;}
    public string Campus{get;set;}
    public string CallAttempt{get;set;}
    public string status{get;set;}
    public string studentID{get;set;}
    public string cohortID{get;set;}
    public string cohortName{get;set;}
    public string monashEmail{get;set;}
    public string personalEmail{get;set;}
    public string suburb{get;set;}
    public string postcode{get;set;}
    public string phone1{get;set;}
    public string phone2{get;set;}
    public string phone3{get;set;}
    public boolean isFirstInFamily{get;set;} 
    public boolean isInternational{get;set;}
    public string callBackDateTime{get;set;}
    public string textBackgroundColour {get;set;}
    public string datetimeColour {get;set;}
    public string alternateDateTime {get;set;} // more user friendly way to read callback date/time
    public task taskRecord {get;set;}
    public TaskDetail(){}
}