/**
 * Services class to provide User sObject centric logical support
 * 
 * @author Carl Vescovi, PwC
 * 
 */
public without Sharing class UserServices {

    public static final String CURRENT_STUDENT = 'Current Student';
    public static final String CURRENT_STUDENT_VALUE = 'Current Course';
    public static final String FUTURE_STUDENT = 'Future Student';
    public static final String FUTURE_STUDENT_VALUE = 'Future Course';
    public static final String FACE_TO_FACE = 'Face to Face & Online';
    public static final String FACE_TO_FACE_ORIGIN = 'Face to Face';
    public static final String PHONE = 'Phone & Online';
    public static final String PHONE_ORIGIN = 'Phone';
    public static final String MONASH_CONNECT_OFFICER_PERM_SET = 'Monash Connect - Officer';
    
    /**
    * my info reset at login, called from a login flow
    */ 
    @InvocableMethod
    public static void resetMyInformation() {
          
          User usr = new User(id = UserInfo.getUserId(),
                              Location__c = null,
                              Enquiry_Role__c = null,
                              My_Information_LastUpdate__c = null,
                              Queue__c = null);
          update usr;
    }
    
    
    /**
    * build a map of users that have Monash Connect permission set applied
    */ 
    public static Set<id> MonashConnectOfficerUsers {
        get{
            if(MonashConnectOfficerUsers == null){
                MonashConnectOfficerUsers = new Set<id>();
                for(PermissionSetAssignment perm : [select id,
                                                   			AssigneeId 
                                                   			from PermissionSetAssignment
                                                   			where PermissionSet.Label =:MONASH_CONNECT_OFFICER_PERM_SET])
                    MonashConnectOfficerUsers.add(perm.AssigneeId);
            }
            return MonashConnectOfficerUsers;
        }
        set;
    }
    
    /**
    * user details specific to console user settings
    */ 
    public static Map<Id,User> usersMap(Set<Id> userIds) {
        return new Map<Id,User>([select id,
                                 Enquiry_Role__c,
                                 Location__c,
                                 Profile.Name,
                                 My_Information_LastUpdate__c,
                                 Queue__c from User where id in:userIds]);
            
    }
    
    /** 
    * cached context user details
    */ 
    public static User contextUser {
        get{
            if(contextUser == null){
                contextUser = usersMap(new Set<Id> {UserInfo.getUserId()}).get(UserInfo.getUserId());
            }
            return contextUser;
        }
        private set;
    }
    
    /**
    * map of user and queue names to id
    * @return map of user or group id to name - so aggregates both into a single map
    */ 
    public static Map<id,string> userOrGroupName {
        get{
            if(userOrGroupName == null){
                userOrGroupName = new Map<id,string>();
                for(User u : [select id,firstname,lastname from User limit 1000]){
                    string fn = (u.firstname == null) ? '' : u.firstname;
                    userOrGroupName.put(u.id, fn+' '+u.lastname);
                }
                for(Group grp : [select id, name from Group where Type = 'Queue']){
                    userOrGroupName.put(grp.id, grp.name);
                }
            }
            return userOrGroupName;
        }
        set;
    }
    
    /** returns a map of role name by user id */
    public static Map<id,string> userRoleName {
        get{
            if(userRoleName == null){
                userRoleName = new Map<id,string>();
                for(list<user> uList : [select id, userrole.name from user where userrole.name != null limit 3000]){
                    for(user u : uList) userRoleName.put(u.id, u.userrole.name);
                }
            }
            return userRoleName;
        }
        set;
    }
    
    
    /**
     * update user records in the without sharing context
     * @param users list of user records to update
     */
    public static void updateUsers(list<user> users){
        update users;
    }
    
    
        
}