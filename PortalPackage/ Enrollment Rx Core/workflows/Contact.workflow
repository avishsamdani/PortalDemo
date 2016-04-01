<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>SetEOCheckFlag</fullName>
        <field>Has_EO_Check__c</field>
        <literalValue>1</literalValue>
        <name>Set EO Check Flag</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Set EO Check Flag</fullName>
        <actions>
            <name>SetEOCheckFlag</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Contact.Has_EO_Check__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Forces new records to be updated</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
