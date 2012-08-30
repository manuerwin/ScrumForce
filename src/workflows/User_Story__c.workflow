<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Set_User_Story_Rank_to_1_000_000</fullName>
        <description>Set User Story Rank to 1,000,000</description>
        <field>Rank__c</field>
        <formula>1000000</formula>
        <name>Set User Story Rank to 1,000,000</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Set Cancelled Story Rank to 1000000</fullName>
        <actions>
            <name>Set_User_Story_Rank_to_1_000_000</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>User_Story__c.Status__c</field>
            <operation>equals</operation>
            <value>Cancelled</value>
        </criteriaItems>
        <description>When User Story Status is Cancelled set the Rank to 1,000,000</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
