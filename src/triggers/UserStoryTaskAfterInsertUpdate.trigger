trigger UserStoryTaskAfterInsertUpdate on User_Story_Task__c (after insert, after update) {
System.debug(LoggingLevel.DEBUG, '## >>> UserStoryTaskAfterInsertUpdate <<< run by ' + UserInfo.getName());
System.debug(LoggingLevel.DEBUG, '##:Trigger.size:' + Trigger.size);
System.debug(LoggingLevel.DEBUG, '##:getDMLRows: ' + Limits.getDMLRows());
System.debug(LoggingLevel.DEBUG, '##:getScriptStatements: ' + Limits.getScriptStatements());

	// Created: 27-Jan-2012 By: Manu Erwin
	// Purpose:	Set parent User Story status to 'In Progress' when any child User Story Task status
	//			is or becomes 'In Progress'.
	//			This trigger deals with both before insert AND before update so is split across the two contexts below.

	Set<Id> setParentUSIds = new Set<Id>();

	for (User_Story_Task__c ust : trigger.new) {
	    if (trigger.isInsert) {
		    System.debug(LoggingLevel.DEBUG, '##### START: UPDATE PARENT USER STORY STATUS - INSERT :START #####');
	
			if (ust.Status__c == 'In Progress') {
				System.debug(System.LoggingLevel.DEBUG, 'Status is In Progress');
				setParentUSIds.add(ust.User_Story__c);
			}
		    System.debug(LoggingLevel.DEBUG, '##### END: UPDATE PARENT USER STORY STATUS - INSERT :END #####');
	    }
	    
	    if (trigger.isUpdate) {
		    System.debug(LoggingLevel.DEBUG, '##### START: UPDATE PARENT USER STORY STATUS - UPDATE :START #####');
			if ((trigger.oldMap.get(ust.Id).Status__c != ust.Status__c) && ust.Status__c == 'In Progress') {
				System.debug(System.LoggingLevel.DEBUG, 'Status has changed');
				setParentUSIds.add(ust.User_Story__c);
			}
		    System.debug(LoggingLevel.DEBUG, '##### END: UPDATE PARENT USER STORY STATUS - UPDATE :END #####');
	    }
	}

    System.debug(LoggingLevel.DEBUG, '##### START: UPDATE PARENT USER STORY STATUS - PROCESSING :START #####');
	List<User_Story__c> listUserStories = new List<User_Story__c>();
	for (User_Story__c userStory : [SELECT Id, Status__c FROM User_Story__c WHERE Id IN :setParentUSIds]) {
		userStory.Status__c = 'In Progress';
		listUserStories.add(userStory);
	}
	update listUserStories;
    System.debug(LoggingLevel.DEBUG, '##### END: UPDATE PARENT USER STORY STATUS - PROCESSING :END #####');
}