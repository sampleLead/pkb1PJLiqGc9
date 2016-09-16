<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>TASK_Copy_Location_to_Activity</fullName>
        <description>copies location data to activity</description>
        <field>Location__c</field>
        <formula>IF(
AND(
TEXT($User.Location__c ) != &quot;Not Set&quot;,
TEXT($User.Location__c ) != &quot;&quot;),
TEXT($User.Location__c ),
&quot;&quot;
)</formula>
        <name>TASK: Copy Location to Activity</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>TASK_Copy_Queue_data_to_Activity</fullName>
        <description>copies queue data from user to activity</description>
        <field>Queue__c</field>
        <formula>IF(
AND(
TEXT($User.Queue__c ) != &quot;Not Set&quot;,
TEXT($User.Queue__c ) != &quot;&quot;),
TEXT($User.Queue__c ),
&quot;&quot;
)</formula>
        <name>TASK: Copy Queue data to Activity</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Task_Completed_Date_Time</fullName>
        <description>Stamps the date and time when the task is completed</description>
        <field>Completed_Date_Time__c</field>
        <formula>now()</formula>
        <name>Task - Completed Date/Time</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>TASK%3A Copy My Information to Activities</fullName>
        <actions>
            <name>TASK_Copy_Location_to_Activity</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>TASK_Copy_Queue_data_to_Activity</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>User.UserRoleId</field>
            <operation>contains</operation>
            <value>Monash Connect</value>
        </criteriaItems>
        <description>Copy user info to activities at creation</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Task - Completed Date%2FTime</fullName>
        <actions>
            <name>Task_Completed_Date_Time</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Task.Status</field>
            <operation>equals</operation>
            <value>Completed</value>
        </criteriaItems>
        <description>Creates a time stamp on the task record when the status is changed to Completed</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
