<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>ENQ_INT_Copy_Course_Fac_to_Man_Fac</fullName>
        <description>copy course managing faculty onto enquiry interest record</description>
        <field>Managing_Faculty__c</field>
        <formula>TEXT( Course__r.Managing_Faculty__c )</formula>
        <name>ENQ INT: Copy Course Fac to Man Fac</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ENQ_INT_Copy_Fac_PL_to_Managing_Fac</fullName>
        <description>copy Faculty of Interest picklist value to Managing Faculty field</description>
        <field>Managing_Faculty__c</field>
        <formula>TEXT( Faculty_PickList__c )</formula>
        <name>ENQ INT:Copy Fac PL to Managing Fac</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>ENQ INT%3A Copy Faculty PL to Man Fac</fullName>
        <actions>
            <name>ENQ_INT_Copy_Fac_PL_to_Managing_Fac</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>if Faculty of Interest selected and course lookup empty, then copy it to the Managing Faculty field on Enq Interest.</description>
        <formula>AND( ISBLANK( Course__c), NOT(ISBLANK( TEXT(Faculty_PickList__c) )) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ENQ INT%3A Populate Managing Faculty</fullName>
        <actions>
            <name>ENQ_INT_Copy_Course_Fac_to_Man_Fac</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>if course lookup populated, then copy the managing faculty value on course record to the managing faculty field on Enquiry Interest</description>
        <formula>NOT(ISBLANK(Course__c ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
