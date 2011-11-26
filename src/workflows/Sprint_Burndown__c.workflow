<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Set_Unique_Sprint_Burndown</fullName>
        <description>Set the field &apos;Unique Sprint Burndown&apos; to a concatenation of Sprint Id + current date</description>
        <field>Unique_Sprint_Burndown__c</field>
        <formula>Sprint__c + &apos;-&apos; +  TEXT( Date__c )</formula>
        <name>Set Unique Sprint Burndown</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Set Sprint Burndown Unique</fullName>
        <actions>
            <name>Set_Unique_Sprint_Burndown</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Set the &apos;Sprint Burndown Unique&apos; field to a concatenation on the parent Sprint Id + current date</description>
        <formula>true</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
