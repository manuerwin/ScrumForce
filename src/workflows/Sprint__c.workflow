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
        <fullName>Close Sprint if End Date in past</fullName>
        <actions>
            <name>Set_Sprint_Status_To_Closed</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Sprint__c.End_Date__c</field>
            <operation>lessThan</operation>
            <value>TODAY</value>
        </criteriaItems>
        <description>If the End Date is moved into the past (e.g., admin cleanup) then set the Status to Closed</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Sprint Status Updates</fullName>
        <active>true</active>
        <booleanFilter>1 OR ( 2 AND 3 )</booleanFilter>
        <criteriaItems>
            <field>Sprint__c.Status__c</field>
            <operation>equals</operation>
            <value>Not Started</value>
        </criteriaItems>
        <criteriaItems>
            <field>Sprint__c.Start_Date__c</field>
            <operation>lessOrEqual</operation>
            <value>TODAY</value>
        </criteriaItems>
        <criteriaItems>
            <field>Sprint__c.End_Date__c</field>
            <operation>greaterOrEqual</operation>
            <value>TODAY</value>
        </criteriaItems>
        <description>Ensure the Sprint Status is updated</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Set_Sprint_Status_To_In_Progress</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Sprint__c.Start_Date__c</offsetFromField>
            <timeLength>-1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Set_Sprint_Status_To_Closed</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Sprint__c.End_Date__c</offsetFromField>
            <timeLength>23</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
</Workflow>
