<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Set_Unique_Sprint_Burndown</fullName>
        <description>Set the field &apos;Unique Sprint Burndown&apos; to a concatenation of Sprint Id + current date converting the 15 character id to the 18 characters.</description>
        <field>Unique_Sprint_Burndown__c</field>
        <formula>Sprint__c&amp; 
CASE( 
IF(CONTAINS(&quot;ABCDEFGHIJKLMNOPQRSTUVWXYZ&quot;,RIGHT(LEFT(Sprint__c,1),1)),1,0)+ 
IF(CONTAINS(&quot;ABCDEFGHIJKLMNOPQRSTUVWXYZ&quot;,RIGHT(LEFT(Sprint__c,2),1)),2,0)+ 
IF(CONTAINS(&quot;ABCDEFGHIJKLMNOPQRSTUVWXYZ&quot;,RIGHT(LEFT(Sprint__c,3),1)),4,0)+ 
IF(CONTAINS(&quot;ABCDEFGHIJKLMNOPQRSTUVWXYZ&quot;,RIGHT(LEFT(Sprint__c,4),1)),8,0)+ 
IF(CONTAINS(&quot;ABCDEFGHIJKLMNOPQRSTUVWXYZ&quot;,RIGHT(LEFT(Sprint__c,5),1)),16,0), 
0,&quot;A&quot;,1,&quot;B&quot;,2,&quot;C&quot;,3,&quot;D&quot;,4,&quot;E&quot;,5,&quot;F&quot;,6,&quot;G&quot;,7,&quot;H&quot;,8,&quot;I&quot;, 
9,&quot;J&quot;,10,&quot;K&quot;,11,&quot;L&quot;,12,&quot;M&quot;,13,&quot;N&quot;,14,&quot;O&quot;,15,&quot;P&quot;,16,&quot;Q&quot;,17,&quot;R&quot;, 
18,&quot;S&quot;,19,&quot;T&quot;,20,&quot;U&quot;,21,&quot;V&quot;,22,&quot;W&quot;,23,&quot;X&quot;,24,&quot;Y&quot;,25,&quot;Z&quot;,26,&quot;0&quot;, 
27,&quot;1&quot;,28,&quot;2&quot;,29,&quot;3&quot;,30,&quot;4&quot;,31,&quot;5&quot;,&quot;0&quot;)&amp; 

CASE( 
IF(CONTAINS(&quot;ABCDEFGHIJKLMNOPQRSTUVWXYZ&quot;,RIGHT(LEFT(Sprint__c,6),1)),1,0)+ 
IF(CONTAINS(&quot;ABCDEFGHIJKLMNOPQRSTUVWXYZ&quot;,RIGHT(LEFT(Sprint__c,7),1)),2,0)+ 
IF(CONTAINS(&quot;ABCDEFGHIJKLMNOPQRSTUVWXYZ&quot;,RIGHT(LEFT(Sprint__c,8),1)),4,0)+ 
IF(CONTAINS(&quot;ABCDEFGHIJKLMNOPQRSTUVWXYZ&quot;,RIGHT(LEFT(Sprint__c,9),1)),8,0)+ 
IF(CONTAINS(&quot;ABCDEFGHIJKLMNOPQRSTUVWXYZ&quot;,RIGHT(LEFT(Sprint__c,10),1)),16,0), 
0,&quot;A&quot;,1,&quot;B&quot;,2,&quot;C&quot;,3,&quot;D&quot;,4,&quot;E&quot;,5,&quot;F&quot;,6,&quot;G&quot;,7,&quot;H&quot;,8,&quot;I&quot;, 
9,&quot;J&quot;,10,&quot;K&quot;,11,&quot;L&quot;,12,&quot;M&quot;,13,&quot;N&quot;,14,&quot;O&quot;,15,&quot;P&quot;,16,&quot;Q&quot;,17,&quot;R&quot;, 
18,&quot;S&quot;,19,&quot;T&quot;,20,&quot;U&quot;,21,&quot;V&quot;,22,&quot;W&quot;,23,&quot;X&quot;,24,&quot;Y&quot;,25,&quot;Z&quot;,26,&quot;0&quot;, 
27,&quot;1&quot;,28,&quot;2&quot;,29,&quot;3&quot;,30,&quot;4&quot;,31,&quot;5&quot;,&quot;0&quot;)&amp; 

CASE( 
IF(CONTAINS(&quot;ABCDEFGHIJKLMNOPQRSTUVWXYZ&quot;,RIGHT(LEFT(Sprint__c,11),1)),1,0)+ 
IF(CONTAINS(&quot;ABCDEFGHIJKLMNOPQRSTUVWXYZ&quot;,RIGHT(LEFT(Sprint__c,12),1)),2,0)+ 
IF(CONTAINS(&quot;ABCDEFGHIJKLMNOPQRSTUVWXYZ&quot;,RIGHT(LEFT(Sprint__c,13),1)),4,0)+ 
IF(CONTAINS(&quot;ABCDEFGHIJKLMNOPQRSTUVWXYZ&quot;,RIGHT(LEFT(Sprint__c,14),1)),8,0)+ 
IF(CONTAINS(&quot;ABCDEFGHIJKLMNOPQRSTUVWXYZ&quot;,RIGHT(LEFT(Sprint__c,15),1)),16,0), 
0,&quot;A&quot;,1,&quot;B&quot;,2,&quot;C&quot;,3,&quot;D&quot;,4,&quot;E&quot;,5,&quot;F&quot;,6,&quot;G&quot;,7,&quot;H&quot;,8,&quot;I&quot;, 
9,&quot;J&quot;,10,&quot;K&quot;,11,&quot;L&quot;,12,&quot;M&quot;,13,&quot;N&quot;,14,&quot;O&quot;,15,&quot;P&quot;,16,&quot;Q&quot;,17,&quot;R&quot;, 
18,&quot;S&quot;,19,&quot;T&quot;,20,&quot;U&quot;,21,&quot;V&quot;,22,&quot;W&quot;,23,&quot;X&quot;,24,&quot;Y&quot;,25,&quot;Z&quot;,26,&quot;0&quot;, 
27,&quot;1&quot;,28,&quot;2&quot;,29,&quot;3&quot;,30,&quot;4&quot;,31,&quot;5&quot;,&quot;0&quot;)

&amp; &apos;-&apos; &amp; TEXT( Date__c )</formula>
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
