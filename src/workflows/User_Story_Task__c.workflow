<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Set_Remaining_Hours_to_zero</fullName>
        <description>Set the Remaining Hours to zero</description>
        <field>Remaining_Hours__c</field>
        <formula>0</formula>
        <name>Set Remaining Hours to zero</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Set Remaining Hours to zero on Done</fullName>
        <actions>
            <name>Set_Remaining_Hours_to_zero</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>User_Story_Task__c.Status__c</field>
            <operation>equals</operation>
            <value>Done</value>
        </criteriaItems>
        <criteriaItems>
            <field>User_Story_Task__c.Remaining_Hours__c</field>
            <operation>notEqual</operation>
            <value>0</value>
        </criteriaItems>
        <description>When the Status becomes &apos;Done&apos; set the Remaining Hours to zero</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
