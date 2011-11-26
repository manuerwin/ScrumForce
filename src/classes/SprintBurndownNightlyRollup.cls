global class SprintBurndownNightlyRollup implements Database.Batchable<sObject>, Database.Stateful {
	//////////////////////////////////////
	// Created: 25-Nov-2011 By: Manu Erwin
	// Purpose: Rollup all active Work (Points) and Work Tasks (Hours) to their parent Sprints.
	//////////////////////////////////////

	// Map of Sprint Ids to Sprint Burndown records that will populated during the process
	global Map<Id, Sprint_Burndown__c> mapSprintIdToSprintBurndown;

	// Constructor
	global SprintBurndownNightlyRollup () {
		mapSprintIdToSprintBurndown = new Map<Id, Sprint_Burndown__c>();
	}

	global Database.QueryLocator start(Database.BatchableContext BC) {
		// Find all Work (and 'active' child Work Tasks) where the 'parent' Sprint is active
		//		(assume status either formula based on end date OR updated by time based WF)
		//		AND Work.Status = planned or active

		String strQuery = 	'SELECT Id, Sprint__c, Story_Points__c, ' +
								'(SELECT Id, Work__c, Remaining_Hours__c FROM Work__c.Work_Tasks__r) ' +
							'FROM Work__c ' +
							'WHERE Status__c IN (\'Not Started\', \'In Progress\')' +
							'AND Sprint__r.Status__c = \'In Progress\'';

		return Database.getQueryLocator(strQuery);
	}

	global void execute(Database.BatchableContext BC, List<Work__c> listWorks) {
		Set<Id> setSprintIds = new Set<Id>();
		
		// Loop through Work records
		for (Work__c workRecord : listWorks) {
			// populate set with SprintIds
			setSprintIds.add(workRecord.Sprint__c);
		}

		// Loop through Work records
		for (Work__c work : listWorks) {
			Sprint_Burndown__c sprintBurndown;
			// obtain SprintBurndown from map (using Work.SprintId) or
			// create if first time (default rollup fields to zero and date to today)
			if (mapSprintIdToSprintBurndown.containsKey(work.Sprint__c)) {
				sprintBurndown = mapSprintIdToSprintBurndown.get(work.Sprint__c);
			} else {
				sprintBurndown = new Sprint_Burndown__c(Sprint__c = work.Sprint__c, Date__c = System.today(),
								Total_Points_Remaining__c = 0, Total_Hours_Remaining__c =0 );
			}

			// add Work Story Points to SprintBurndown
			sprintBurndown.Total_Points_Remaining__c += work.Story_Points__c;

			// Loop child Work Tasks
			for (Work_Task__c workTask : work.Work_Tasks__r) {
				// add Hours Remaining to SprintBurndown
				sprintBurndown.Total_Hours_Remaining__c += workTask.Remaining_Hours__c;
			}

			// put SprintBurndown (back) into Map
			mapSprintIdToSprintBurndown.put(work.Sprint__c, sprintBurndown);
		}
	}

	global void finish(Database.BatchableContext BC) {
		// insert list of SprintBurndown records that have been populated during the batch process
		System.debug(mapSprintIdToSprintBurndown.values());
		insert mapSprintIdToSprintBurndown.values();
	}
}