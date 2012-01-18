trigger UserStoryAfterUpdate on User_Story__c (after update) {
System.debug(LoggingLevel.DEBUG, '## >>> UserStoryAfterUpdate <<< run by ' + UserInfo.getName());
System.debug(LoggingLevel.DEBUG, '##:Trigger.size:' + Trigger.size);
System.debug(LoggingLevel.DEBUG, '##:getDMLRows: ' + Limits.getDMLRows());
System.debug(LoggingLevel.DEBUG, '##:getScriptStatements: ' + Limits.getScriptStatements());

    System.debug(LoggingLevel.DEBUG, '##### START: User Story Task to Sprint on User Story Update :START #####');
	// Created: 18-Jan-2012 By: Manu Erwin
	// Purpose: When a User Story's Sprint has changed (still has a value), associate all child User Story Tasks
	//			to the new Sprint record.
	//			When a User Story's Sprint becomes blank, remove all child User Story Tasks from the previous
	//			grandparent Sprint record.

	Set<Id> setSprintChangedUserStoryIds = new Set<Id>();
	Set<Id> setSprintBlankUserStoryIds = new Set<Id>();
	for (User_Story__c userStory : trigger.new) {
		if (userStory.Sprint__c != trigger.oldMap.get(userStory.Id).Sprint__c) {
			// Sprint has changed - now check for value or blank
			if (userStory.Sprint__c != null) {
				System.debug(LoggingLevel.DEBUG, '## Sprint has changed to a value - change children: ' + userStory.Id);
				setSprintChangedUserStoryIds.add(userStory.Id);
			} else {
				System.debug(LoggingLevel.DEBUG, '## Sprint has changed to null - remove children: ' + userStory.Id);
				setSprintBlankUserStoryIds.add(userStory.Id);
			}
		} else {
			System.debug(LoggingLevel.DEBUG, '## Sprint has not changed - ignore this: ' + userStory.Id);
		}
	}

	List<User_Story_Task__c> listUserStoryTasks = new List<User_Story_Task__c>();

	// Loop through all User Story Tasks where User Story Sprint has changed and set to the new Sprint
	for (User_Story_Task__c userStoryTask : [SELECT Id, User_Story__c, Sprint__c
											FROM User_Story_Task__c
											WHERE User_Story__c IN :setSprintChangedUserStoryIds]) {
		userStoryTask.Sprint__c = trigger.newMap.get(userStoryTask.User_Story__c).Sprint__c;
		listUserStoryTasks.add(userStoryTask);
	}

	// Loop through all User Story Tasks where User Story Sprint is now blank and set Sprint to null
	for (User_Story_Task__c userStoryTask : [SELECT Id, User_Story__c, Sprint__c
											FROM User_Story_Task__c
											WHERE User_Story__c IN :setSprintBlankUserStoryIds]) {
		userStoryTask.Sprint__c = null;
		listUserStoryTasks.add(userStoryTask);
	}
	update listUserStoryTasks;
	System.debug(LoggingLevel.DEBUG, '#####   END: User Story Task to Sprint on User Story Update :END #####');
}