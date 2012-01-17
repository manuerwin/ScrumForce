trigger UserStoryAfterUpdate on User_Story__c (after update) {
System.debug(LoggingLevel.DEBUG, '## >>> UserStoryAfterUpdate <<< run by ' + UserInfo.getName());
System.debug(LoggingLevel.DEBUG, '##:Trigger.size:' + Trigger.size);
System.debug(LoggingLevel.DEBUG, '##:getDMLRows: ' + Limits.getDMLRows());
System.debug(LoggingLevel.DEBUG, '##:getScriptStatements: ' + Limits.getScriptStatements());

    System.debug(LoggingLevel.DEBUG, '##### START: User Story Task to Sprint on User Story Update :START #####');
	// Created: 18-Jan-2012 By: Manu Erwin
	// Purpose: When a User Story's Sprint is populated, associate all child User Story Tasks to the new
	//			grandparent Sprint record.
	//			When a User Story's Sprint becomes blank, remove all child User Story Tasks from the previous
	//			grandparent Sprint record.
    System.debug(LoggingLevel.DEBUG, '#####   END: User Story Task to Sprint on User Story Update :END #####');
}