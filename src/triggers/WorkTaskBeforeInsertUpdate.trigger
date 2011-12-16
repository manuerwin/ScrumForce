trigger WorkTaskBeforeInsertUpdate on Work_Task__c (before insert, before update) {
System.debug(LoggingLevel.DEBUG, '## >>> Work_Task__c Before Insert and Before Update <<< run by ' + UserInfo.getName());
System.debug(LoggingLevel.DEBUG, '##:Trigger.size:' + Trigger.size);
System.debug(LoggingLevel.DEBUG, '##:getDMLRows: ' + Limits.getDMLRows());
System.debug(LoggingLevel.DEBUG, '##:getScriptStatements: ' + Limits.getScriptStatements());

	if (Trigger.isBefore && Trigger.isInsert) {
	    System.debug(LoggingLevel.DEBUG, '##### START: ASSOCIATE WORK TASK TO GRANDPARENT SPRINT :START #####');
	    // Created: 14-Dec-2011 By: Manu Erwin
	    // Purpose: When a Work Task is created, associate the Sprint lookup field to the grandparent Sprint record.

		Set<Id> setWorkIds = new Set<Id>();
		Map<Id, Id> mapWorkIdToSprintId = new Map<Id, Id>();
		
		for (Work_Task__c workTask : trigger.new) {
			setWorkIds.add(workTask.Work__c);
		}

		for (Work__c work : [SELECT Id, Sprint__c FROM Work__c WHERE Id IN :setWorkIds]) {
		    System.debug(LoggingLevel.DEBUG, '## The Work: ' + work);
			mapWorkIdToSprintId.put(work.Id, work.Sprint__c);
		}

	    System.debug(LoggingLevel.DEBUG, '## mapWorkIdToSprintId: ' + mapWorkIdToSprintId);

		for (Work_Task__c oneWorkTask : trigger.new) {
			if (mapWorkIdToSprintId.get(oneWorkTask.Work__c) != null) {
			    System.debug(LoggingLevel.DEBUG, '## The Work has a parent Sprint so associate it');
				oneWorkTask.Sprint__c = mapWorkIdToSprintId.get(oneWorkTask.Work__c);
			} else {
			    System.debug(LoggingLevel.DEBUG, '## The Work does not have a parent Sprint so do NOT associate it');
			}
		}
	}
}