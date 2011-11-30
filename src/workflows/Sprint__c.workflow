<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Set_Sprint_Status_To_Closed</fullName>
        <description>Set the Sprint Status to &apos;Closed&apos;</description>
        <field>Status__c</field>
        <literalValue>Closed</literalValue>
        <name>Set Sprint Status To Closed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Sprint_Status_To_In_Progress</fullName>
        <description>Set the Sprint Status to &apos;In Progress&apos;</description>
        <field>Status__c</field>
        <literalValue>In Progress</literalValue>
        <name>Set Sprint Status To In Progress</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Auto Activate Sprints At Start Date</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Sprint__c.Status__c</field>
            <operation>equals</operation>
            <value>Not Started</value>
        </criteriaItems>
        <description>When the Sprint Start Date occurs the Sprint Status should be changed to &apos;In Progress&apos;</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Auto Close Sprint At End Date</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Sprint__c.Status__c</field>
            <operation>equals</operation>
            <value>In Progress</value>
        </criteriaItems>
        <description>A Sprint should be &apos;Closed&apos; when the End Date is reached</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
