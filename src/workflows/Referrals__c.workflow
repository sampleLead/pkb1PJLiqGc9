<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>mt_Send_email_because_Supervisor_alert_requested</fullName>
        <description>mt_Send email because Supervisor alert requested</description>
        <protected>false</protected>
        <recipients>
            <recipient>judith.little@monash.edu.v2</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>kellie.rayment@monash.edu.v2</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>MonTRACK_Templates/Referral_alert</template>
    </alerts>
    <rules>
        <fullName>mt_Send alert for Supervisor followup</fullName>
        <actions>
            <name>mt_Send_email_because_Supervisor_alert_requested</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Referrals__c.Referral__c</field>
            <operation>equals</operation>
            <value>Supervisor follow up required</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.ProfileId</field>
            <operation>notEqual</operation>
            <value>Data Loading</value>
        </criteriaItems>
        <description>If Referrals are added for ‘Supervisor followup’, this rule sends alert to Montrack admin for followup</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
