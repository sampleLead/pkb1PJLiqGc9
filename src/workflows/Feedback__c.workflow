<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>notify_admin_of_feedback</fullName>
        <description>notify admin of feedback</description>
        <protected>false</protected>
        <recipients>
            <recipient>carl.vescovi@monash.edu</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Feedback_templates/FEEDBACK_Notification_email</template>
    </alerts>
    <alerts>
        <fullName>send_confirmation_to_creator_of_feedback</fullName>
        <description>send confirmation to creator of feedback</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Feedback_templates/FEEDBACK_Notification_email</template>
    </alerts>
    <alerts>
        <fullName>send_feedback_update</fullName>
        <description>send feedback update</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Feedback_templates/FEEDBACK_closed_feedback_record</template>
    </alerts>
    <rules>
        <fullName>FEEDBACK%3A Notification email</fullName>
        <actions>
            <name>notify_admin_of_feedback</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Feedback__c.Test_Ref__c</field>
            <operation>notEqual</operation>
            <value>xxxx</value>
        </criteriaItems>
        <description>send notification of feedback</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>FEEDBACK%3A confirmation email</fullName>
        <actions>
            <name>send_confirmation_to_creator_of_feedback</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Feedback__c.Name</field>
            <operation>notEqual</operation>
            <value>xxxx</value>
        </criteriaItems>
        <description>confirm details sent to sf as feedback</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>FEEDBACK%3A notify if change to status</fullName>
        <actions>
            <name>send_feedback_update</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Feedback__c.Status__c</field>
            <operation>notEqual</operation>
            <value>New</value>
        </criteriaItems>
        <description>send update to owner of feedback record</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
