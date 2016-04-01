<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>UpdateApplicationsCompleted</fullName>
        <field>Applications_Complete__c</field>
        <formula>IF( Updated__c = &quot;Application Complete&quot;, 1, 0)</formula>
        <name>Update Applications Completed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateContactsCompleted</fullName>
        <field>Contacts_Completed__c</field>
        <formula>IF(  Updated__c  = &quot;Contact Complete&quot;, 1, 0)</formula>
        <name>Update Contacts Completed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateEnrollmentsAccepted</fullName>
        <field>Enrollments__c</field>
        <formula>IF( Updated__c = &quot;Enrollment Accepted&quot;, 1, 0)</formula>
        <name>Update Enrollments Accepted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateInterviewsCompleted</fullName>
        <field>Interviews_Completed__c</field>
        <formula>IF( Updated__c = &quot;Interview Complete&quot;, 1, 0)</formula>
        <name>Update Interviews Completed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateInterviewsScheduled</fullName>
        <field>Interviews_Scheduled__c</field>
        <formula>IF( Updated__c = &quot;Interview Scheduled&quot;, 1, 0)</formula>
        <name>Update Interviews Scheduled</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateStarts</fullName>
        <field>Starts__c</field>
        <formula>IF( Updated__c = &quot;Active Student&quot;, 1, 0)</formula>
        <name>Update Starts</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Status Tracking Update Rule</fullName>
        <actions>
            <name>UpdateApplicationsCompleted</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>UpdateContactsCompleted</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>UpdateEnrollmentsAccepted</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>UpdateInterviewsCompleted</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>UpdateInterviewsScheduled</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>UpdateStarts</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Status_Tracking__c.Updated__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Referencing the Update field on the Status Tracking object, analyze the value and populate the appropriate metric field.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
