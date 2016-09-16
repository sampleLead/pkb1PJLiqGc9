<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Contact_Email_Opt_out_to_true</fullName>
        <description>set Contact Email Opt out to true</description>
        <field>HasOptedOutOfEmail</field>
        <literalValue>1</literalValue>
        <name>Contact: Email Opt out to true</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Contact_is_corporate_to_false</fullName>
        <field>Is_Corporate_Contact_Result__c</field>
        <literalValue>0</literalValue>
        <name>Contact.is corporate to false</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Contact_set_is_corporate_checkbox_to_tr</fullName>
        <field>Is_Corporate_Contact_Result__c</field>
        <literalValue>1</literalValue>
        <name>Contact. set is corporate checkbox to tr</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Contact_RT_to_Non_Student</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Non_Student</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Contact.RT to Non-Student</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Contact_RT_to_Student</fullName>
        <description>Set Contact RT to Student</description>
        <field>RecordTypeId</field>
        <lookupValue>Student</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Contact.RT to Student</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Marketing_Comms_Status_field_to_Opt</fullName>
        <field>Marketing_Communications_Status__c</field>
        <literalValue>Opted out</literalValue>
        <name>Set Marketing Comms field to Opt out</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>append_test_to_email_field</fullName>
        <field>Email</field>
        <formula>IF(LEFT( Email ,5) = &quot;test.&quot;,Email, &quot;test.&quot;&amp;Email)</formula>
        <name>append .test to email field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Assign Non-Student Layout</fullName>
        <actions>
            <name>Set_Contact_RT_to_Non_Student</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>if has no student Id, then use non-student layout.</description>
        <formula>NOT( AND( LEN( Person_ID_unique__c ) &lt; 9, LEN( Person_ID_unique__c ) &gt; 1 ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Assign Student Layout</fullName>
        <actions>
            <name>Set_Contact_RT_to_Student</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>has a student Id, so use student layout.</description>
        <formula>AND( LEN( Person_ID_unique__c ) &lt; 9, LEN( Person_ID_unique__c ) &gt; 1 )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>If Deceased opt contact out of marketing</fullName>
        <actions>
            <name>Contact_Email_Opt_out_to_true</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Contact.Deceased__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>If Deceased set to true, ensure marketing is opted out</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Mirror False Is Corporate Contact field</fullName>
        <actions>
            <name>Contact_is_corporate_to_false</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Contact.Is_Corporate_Contact__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>copy formula field to checkbox field, so is accessible to criteria based sharing rule</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Mirror True Is Corporate Contact field</fullName>
        <actions>
            <name>Contact_set_is_corporate_checkbox_to_tr</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Contact.Is_Corporate_Contact__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>copy formula field to checkbox field, so is accessible to criteria based sharing rule</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Monitor for Marketing Status to Opt out</fullName>
        <actions>
            <name>Set_Marketing_Comms_Status_field_to_Opt</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND (2 or 3 or 4 or 5)</booleanFilter>
        <criteriaItems>
            <field>Contact.Marketing_Communications_Status__c</field>
            <operation>equals</operation>
            <value>Opted in</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.DoNotCall</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Do_Not_Mail__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.HasOptedOutOfEmail</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Deceased__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>if any standard opt outs are set, then roll the marketing status field to Opt out</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
