<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Case_Auto_Response_Email</fullName>
        <description>Case - Auto Response Email</description>
        <protected>false</protected>
        <recipients>
            <field>SuppliedEmail</field>
            <type>email</type>
        </recipients>
        <senderAddress>future@monash.edu</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Auto_responses/Future_monash_auto_response</template>
    </alerts>
    <alerts>
        <fullName>Case_Email_New_Owner_Schools_Engagement</fullName>
        <description>Case - Email New Owner (Schools Engagement)</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Channel_Mgt_New_Enquiry_Notification</template>
    </alerts>
    <alerts>
        <fullName>Send_Deferral_Request_Notification_to_Faculty</fullName>
        <description>Send Deferral Request Notification to Faculty</description>
        <protected>false</protected>
        <recipients>
            <field>Faculty_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>mge-apply@monash.edu</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>MGE_Admissions/Deferral_Request</template>
    </alerts>
    <alerts>
        <fullName>send_autoresponse_to_a_web_enquiry</fullName>
        <description>send autoresponse to a web enquiry</description>
        <protected>false</protected>
        <recipients>
            <field>SuppliedEmail</field>
            <type>email</type>
        </recipients>
        <senderAddress>future@monash.edu</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Auto_responses/Branded_auto_response</template>
    </alerts>
    <fieldUpdates>
        <fullName>Case_Enquiry_Type_to_Current_Course</fullName>
        <description>set Enquiry Type to current course</description>
        <field>Enquiry_Type__c</field>
        <literalValue>Current Course</literalValue>
        <name>Case:Enquiry Type to Current Course</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Case_Enquiry_type_to_Future_Course</fullName>
        <description>set case enquiry type to Future Course</description>
        <field>Enquiry_Type__c</field>
        <literalValue>Future Course</literalValue>
        <name>Case:Enquiry Type to Future Course</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Change_to_MGE_Record_Type</fullName>
        <field>RecordTypeId</field>
        <lookupValue>MGE_Enquiry</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Change to MGE Record Type</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Change_to_Standard_Record_Type</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Monash_Connect_Enquiry</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Change to Standard Record Type</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Clear_Latest_Inbound_Email_Field</fullName>
        <field>Latest_Inbound_Email__c</field>
        <name>Clear Latest Inbound Email Field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Category_1_to_MGE_Admissions</fullName>
        <field>Category_Level_1__c</field>
        <literalValue>MGE Admissions</literalValue>
        <name>Set Category 1 to MGE Admissions</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Category_2_to_Deferral</fullName>
        <field>Category_Level_2__c</field>
        <literalValue>Deferral</literalValue>
        <name>Set Category 2 to Deferral</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Enquiry_Type_to_Future_Student</fullName>
        <field>Enquiry_Type__c</field>
        <literalValue>Future Course</literalValue>
        <name>Set Enquiry Type to Future Student</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Faculty_Email_Address</fullName>
        <field>Faculty_Email__c</field>
        <formula>Faculty_Email_Mapping__c</formula>
        <name>Set Faculty Email Address</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Priority_to_Medium</fullName>
        <field>Priority</field>
        <literalValue>Medium</literalValue>
        <name>Set Priority to Medium</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Record_Type_to_SR_Enquiry</fullName>
        <field>RecordTypeId</field>
        <lookupValue>SR_Enquiry</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Set Record Type to SR Enquiry</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Status_to_Awaiting_Customer_Feedback</fullName>
        <field>Status</field>
        <literalValue>Awaiting Customer Feedback</literalValue>
        <name>Set Status to Awaiting Customer Feedback</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Student_Type_to_International</fullName>
        <field>Student_Type__c</field>
        <literalValue>International</literalValue>
        <name>Set Student Type to International</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Subject_for_International_Find_Cours</fullName>
        <field>Subject</field>
        <formula>&quot;International enquiry for course &quot;  &amp;  Course_Title_f__c</formula>
        <name>Set Subject for International Find Cours</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Subject_to_Deferral_Request</fullName>
        <field>Subject</field>
        <formula>&quot;Deferral Request&quot;</formula>
        <name>Set Subject to Deferral Request</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>CASE%3A set type if origin is airport pickup</fullName>
        <actions>
            <name>Case_Enquiry_Type_to_Current_Course</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>Email - Airport Pickup</value>
        </criteriaItems>
        <description>If enquiries that come in from origin “Email – Airport Pickup”  have their “Enquiry Type” auto populated as “Current Course”</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>CASE%3A set type if origin is web enquiry</fullName>
        <actions>
            <name>Case_Enquiry_type_to_Future_Course</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>course enquiry webform</value>
        </criteriaItems>
        <description>Enquiries that come in from origin  “Course enquiry webform” will have their “Enquiry Type” auto populated as “Future Course”</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Case %28Schools Engagment%29 - Email New Owner</fullName>
        <actions>
            <name>Case_Email_New_Owner_Schools_Engagement</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Auto response rule for cases owned by Schools Engagement.</description>
        <formula>Owner:Queue.QueueName = &quot;Schools Engagement&quot;</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Case - Auto Response Email</fullName>
        <actions>
            <name>Case_Auto_Response_Email</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>Web,course enquiry webform,Email - System,Web - Research Future Students,Email - study,Web - Future Students International,Web - Find Course International,Web - Monash College</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Standard Enquiry</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.SuppliedEmail</field>
            <operation>notEqual</operation>
            <value>,future@monash.edu</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.ProfileId</field>
            <operation>notEqual</operation>
            <value>Data Loading</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Created - Email - sr-socialenquiry-l</fullName>
        <actions>
            <name>Set_Student_Type_to_International</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>Email - sr-socialenquiry-l</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Created - Email - study</fullName>
        <actions>
            <name>Set_Student_Type_to_International</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>Email - study</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Created - Web - Find Course International</fullName>
        <actions>
            <name>Case_Enquiry_type_to_Future_Course</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Student_Type_to_International</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Subject_for_International_Find_Cours</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>Web - Find Course International</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Created - Web - Future Students International</fullName>
        <actions>
            <name>Set_Enquiry_Type_to_Future_Student</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Student_Type_to_International</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>Web - Future Students International</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Created - Web - Monash College</fullName>
        <actions>
            <name>Set_Student_Type_to_International</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>Web - Monash College</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Created - Web - Research Current Students</fullName>
        <actions>
            <name>Case_Enquiry_Type_to_Current_Course</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Priority_to_Medium</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>Web - Research Current Students</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Created - Web - Research Deferral Request</fullName>
        <actions>
            <name>Set_Category_1_to_MGE_Admissions</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Category_2_to_Deferral</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Enquiry_Type_to_Future_Student</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Faculty_Email_Address</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Priority_to_Medium</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Status_to_Awaiting_Customer_Feedback</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Subject_to_Deferral_Request</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>Web - Research Deferral Request</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Send_Deferral_Request_Notification_to_Faculty</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.Created_Date__c</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Created - Web - Research Future Students</fullName>
        <actions>
            <name>Case_Enquiry_type_to_Future_Course</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Category_1_to_MGE_Admissions</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Priority_to_Medium</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>Web - Research Future Students</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Queue Changed to MC - Change Record Type</fullName>
        <actions>
            <name>Change_to_Standard_Record_Type</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>equals</operation>
            <value>Monash Connect Enquiries</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>Standard Enquiry</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Flag_Owner_is_Queue__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>When enquiry is changed to Monash Connect queue, the enquiry record type is changed to Standard Record Type</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Queue Changed to MGE - Change Record Type</fullName>
        <actions>
            <name>Change_to_MGE_Record_Type</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>startsWith</operation>
            <value>MGE</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Flag_Owner_is_Queue__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>MGE Enquiry</value>
        </criteriaItems>
        <description>When enquiry is changed to MGE queues, the enquiry record type is changed to MGE Record Type</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Queue Changed to SR - Change Record Type</fullName>
        <actions>
            <name>Set_Record_Type_to_SR_Enquiry</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>equals</operation>
            <value>Student Rec Enquiries</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Flag_Owner_is_Queue__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>SR Enquiry</value>
        </criteriaItems>
        <description>When enquiry is changed to SR queue, the enquiry record type is changed to SR Record Type</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Status Changed - Clear Latest Inbound Email Field</fullName>
        <actions>
            <name>Clear_Latest_Inbound_Email_Field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>When enquiry status is changed this workflow will clear the latest inbound email date field</description>
        <formula>ISCHANGED( Status )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>at wrap up%2C add a wrap up task</fullName>
        <actions>
            <name>Wrap_Up_Task</name>
            <type>Task</type>
        </actions>
        <active>true</active>
        <description>to enable consolidated reporting around activities, add a completed task to case when is &apos;wrapped up&apos;</description>
        <formula>AND( 
IsClosed , 
NOT( $User.Alias = &quot;dload&quot;) /* exclude data load user */
)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <tasks>
        <fullName>Wrap_Up_Task</fullName>
        <assignedToType>owner</assignedToType>
        <description>Enquiry wrapped up</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Completed</status>
        <subject>Wrap Up Task</subject>
    </tasks>
</Workflow>
