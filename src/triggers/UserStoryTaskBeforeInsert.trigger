trigger UserStoryTaskBeforeInsert on User_Story_Task__c (before insert) {
System.debug(LoggingLevel.DEBUG, '## >>> User_Story_Task__c Before Insert <<< run by ' + UserInfo.getName());
System.debug(LoggingLevel.DEBUG, '##:Trigger.size:' + Trigger.size);
System.debug(LoggingLevel.DEBUG, '##:getDMLRows: ' + Limits.getDMLRows());
System.debug(LoggingLevel.DEBUG, '##:getScriptStatements: ' + Limits.getScriptStatements());

    System.debug(LoggingLevel.DEBUG, '##### START: ASSOCIATE User Story Task TO GRANDPARENT SPRINT :START #####');
	// Created: 14-Dec-2011 By: Manu Erwin
	// Purpose: When a User Story Task is created, associate the Sprint lookup field to the grandparent Sprint record.

	Set<Id> setUserStoryIds = new Set<Id>();
	Map<Id, Id> mapUserStoryIdToSprintId = new Map<Id, Id>();
	
	for (User_Story_Task__c UserStoryTask : trigger.new) {
		setUserStoryIds.add(UserStoryTask.User_Story__c);
	}

	for (User_Story__c UserStory : [SELECT Id, Sprint__c FROM User_Story__c WHERE Id IN :setUserStoryIds]) {
		System.debug(LoggingLevel.DEBUG, '## The UserStory: ' + UserStory);
		mapUserStoryIdToSprintId.put(UserStory.Id, UserStory.Sprint__c);
	}

	System.debug(LoggingLevel.DEBUG, '## mapUserStoryIdToSprintId: ' + mapUserStoryIdToSprintId);

	for (User_Story_Task__c oneUserStoryTask : trigger.new) {
		if (mapUserStoryIdToSprintId.get(oneUserStoryTask.User_Story__c) != null) {
			System.debug(LoggingLevel.DEBUG, '## The UserStory has a parent Sprint so associate it');
			oneUserStoryTask.Sprint__c = mapUserStoryIdToSprintId.get(oneUserStoryTask.User_Story__c);
		} else {
			System.debug(LoggingLevel.DEBUG, '## The UserStory does not have a parent Sprint so do NOT associate it');
		}
	}
}