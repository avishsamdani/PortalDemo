<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>UpdateAccountOwner</fullName>
        <field>OwnerId</field>
        <lookupValue>portaldev-jzhuang@enrollmentrx.com</lookupValue>
        <lookupValueType>User</lookupValueType>
        <name>Update Account Owner</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Assign Appropriate Account Owner</fullName>
        <actions>
            <name>UpdateAccountOwner</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>User.UserRoleId</field>
            <operation>equals</operation>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
