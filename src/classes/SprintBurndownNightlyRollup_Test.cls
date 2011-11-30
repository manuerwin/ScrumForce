@isTest
private class SprintBurndownNightlyRollup_Test {
	static testMethod void closedVsInProgressNotStartedWorks_Test() {
		// Works with Closed status should be ignored in calculations however
		// Not Started and In Progress should be processed.
		Sprint__c sprint01 = new Sprint__c (Name = 'closedVsInProgressNotStartedWorks_Test',
								Status__c = 'In Progress',
								Start_Date__c = System.today().addDays(-2),
								End_Date__c = System.today().addDays(+2));
		insert sprint01;

		List<Work__c> listWorks = new List<Work__c>();
		// Add 50 each of Not Started, In Progress and Closed
		for (Integer intCounter = 0; intCounter < 50; intCounter++) {
			Work__c work = new Work__c(Name = 'closedVsInProgressNotStartedWorks_Test-InProgress-' + intCounter,
							Sprint__c = sprint01.Id,
							Status__c = 'In Progress',
							Story_Points__c = 2);
			listWorks.add(work);
		}
		for (Integer intCounter = 0; intCounter < 50; intCounter++) {
			Work__c work = new Work__c(Name = 'closedVsInProgressNotStartedWorks_Test-Not Started-' + intCounter,
							Sprint__c = sprint01.Id,
							Status__c = 'Not Started',
							Story_Points__c = 2);
			listWorks.add(work);
		}
		for (Integer intCounter = 0; intCounter < 50; intCounter++) {
			Work__c work = new Work__c(Name = 'closedVsInProgressNotStartedWorks_Test-Closed-' + intCounter,
							Sprint__c = sprint01.Id,
							Status__c = 'Closed',
							Story_Points__c = 2);
			listWorks.add(work);
		}
		insert listWorks;

		Test.startTest();
			SprintBurndownNightlyRollup sch = new SprintBurndownNightlyRollup();
			sch.strQuery =	'SELECT Id, Sprint__c, Story_Points__c, ' +
                            	'(SELECT Id, Work__c, Remaining_Hours__c FROM Work__c.Work_Tasks__r ' +
	                        	'WHERE Status__c IN (\'Not Started\', \'In Progress\')) ' +
                        	'FROM Work__c ' +
                        	'WHERE Status__c IN (\'Not Started\', \'In Progress\') ' +
                        	'AND Sprint__r.Status__c = \'In Progress\' ' +
                        	'AND Sprint__c = \'' + sprint01.Id + '\'';
			Database.executeBatch(sch);
		Test.stopTest();

		List<Sprint_Burndown__c> listSprintBurns =	[SELECT Id, Sprint__c, Total_Points_Remaining__c
													FROM Sprint_Burndown__c
													WHERE Sprint__c = :sprint01.Id];
		System.debug(listSprintBurns);
		System.assert(listSprintBurns.size() == 1, 'There should be only one Sprint Burndown');
		Sprint_Burndown__c theSprintBurndown = listSprintBurns[0];
		System.assert(theSprintBurndown.Total_Points_Remaining__c == 200, 'There should be 200 points');
	}
	static testMethod void notStartedInProgressVsClosedWorkTasks_Test() {
		// Work Tasks with Closed status should be ignored in calculations however
		// Not Started and In Progress Work Tasks should be processed.
		Sprint__c sprint01 = new Sprint__c (Name = 'notStartedInProgressVsClosedWorkTasks',
								Status__c = 'In Progress',
								Start_Date__c = System.today().addDays(-2),
								End_Date__c = System.today().addDays(+2));
		insert sprint01;

		// Add 10 each of Not Started, In Progress Work records
		List<Work__c> listWorks = new List<Work__c>();
		for (Integer intCounter = 0; intCounter < 20; intCounter++) {
			Work__c work = new Work__c(Name = 'notStartedInProgressVsClosedWorkTasks-' + intCounter,
							Sprint__c = sprint01.Id,
							Story_Points__c = 2);
			if (System.Math.mod(intCounter, 2) == 0) {
				work.Status__c = 'Not Started';
			} else if (System.Math.mod(intCounter, 2) == 1) {
				work.Status__c = 'In Progress';
			}
				
			listWorks.add(work);
		}
		insert listWorks;

		// Add 10 Closed Work records
		List<Work__c> listWorksClosed = new List<Work__c>();
		for (Integer intCounter = 0; intCounter < 10; intCounter++) {
			Work__c work = new Work__c(Name = 'notStartedInProgressVsClosedWorkTasks-Closed-' + intCounter,
							Sprint__c = sprint01.Id,
							Status__c = 'Closed',
							Story_Points__c = 2);
			listWorksClosed.add(work);
		}
		insert listWorksClosed;

		List<Work_Task__c> listWorkTasks = new List<Work_Task__c>();
		// Add 4 'active' Work Tasks and 2 'inactive' WorkTasks to the 'active' Works - only 4 should be counted
		for (Integer intCounter = 0; intCounter < 6; intCounter++) {
			Work_Task__c workTask = new Work_Task__c(Name = 'notStartedInProgressVsClosedWorkTasks-activeWork-' + intCounter,
								Work__c = listWorks[intCounter].Id, Estimated_Hours__c = 2, Remaining_Hours__c = 2);
			if (System.Math.mod(intCounter, 3) == 0) {
				workTask.Status__c = 'Not Started';
			} else if (System.Math.mod(intCounter, 3) == 1) {
				workTask.Status__c = 'In Progress';
			} else if (System.Math.mod(intCounter, 3) == 2) {
				workTask.Status__c = 'Closed';
			}
			listWorkTasks.add(workTask);
		}
		// Add 4 'active' Work Tasks and 2 'inactive' WorkTasks to the 'inactive' Works - all should be ignored
		for (Integer intCounter = 0; intCounter < 6; intCounter++) {
			Work_Task__c workTask = new Work_Task__c(Name = 'notStartedInProgressVsClosedWorkTasks-closedWork-' + intCounter,
							Work__c = listWorksClosed[intCounter].Id, Estimated_Hours__c = 2, Remaining_Hours__c = 2);
			if (System.Math.mod(intCounter, 3) == 0) {
				workTask.Status__c = 'Not Started';
			} else if (System.Math.mod(intCounter, 3) == 1) {
				workTask.Status__c = 'In Progress';
			} else if (System.Math.mod(intCounter, 3) == 2) {
				workTask.Status__c = 'Closed';
			}
			listWorkTasks.add(workTask);
		}
		System.debug(listWorkTasks);
		insert listWorkTasks;

		Test.startTest();
			SprintBurndownNightlyRollup sch = new SprintBurndownNightlyRollup();
			sch.strQuery =	'SELECT Id, Sprint__c, Story_Points__c, ' +
                            	'(SELECT Id, Work__c, Remaining_Hours__c FROM Work__c.Work_Tasks__r ' +
	                        	'WHERE Status__c IN (\'Not Started\', \'In Progress\')) ' +
                        	'FROM Work__c ' +
                        	'WHERE Status__c IN (\'Not Started\', \'In Progress\') ' +
                        	'AND Sprint__r.Status__c = \'In Progress\' ' +
                        	'AND Sprint__c = \'' + sprint01.Id + '\'';
			Database.executeBatch(sch);
		Test.stopTest();

		List<Sprint_Burndown__c> listSprintBurns =	[SELECT Id, Sprint__c,
													Total_Points_Remaining__c, Total_Hours_Remaining__c
													FROM Sprint_Burndown__c
													WHERE Sprint__c = :sprint01.Id];
		System.debug(listSprintBurns);
		System.assert(listSprintBurns.size() == 1, 'There should be only one Sprint Burndown');
		Sprint_Burndown__c theSprintBurndown = listSprintBurns[0];
		System.assert(theSprintBurndown.Total_Hours_Remaining__c == 8, 'There should be 8 hours remaining');
	}
	static testMethod void multipleSprintBurndowns_Test() {
		// Not Started and Closed should be ignored
		List<Sprint__c> listSprints = new List<Sprint__c>();
		for (Integer intCounter = 0; intCounter < 30; intCounter++) {
			Sprint__c sprint = new Sprint__c (Name = 'multipleSprintBurndowns_Test-' + intCounter,
								Start_Date__c = System.today().addDays(-2),
								End_Date__c = System.today().addDays(+2));
				if (System.Math.mod(intCounter, 3) == 0) {
					sprint.Status__c = 'Not Started';
				} else if (System.Math.mod(intCounter, 3) == 1) {
					sprint.Status__c = 'In Progress';
				} else if (System.Math.mod(intCounter, 3) == 2) {
					sprint.Status__c = 'Closed';
				}
			listSprints.add(sprint);
		}
		insert listSprints;

		// Add 10 each of Not Started, In Progress and Closed Work records
		List<Work__c> listWorks = new List<Work__c>();
		for (Integer intCounter = 0; intCounter < 30; intCounter++) {
			Work__c work = new Work__c(Name = 'multipleSprintBurndowns_Test-' + intCounter,
							Story_Points__c = 2);
			if (System.Math.mod(intCounter, 2) == 0) {
				work.Sprint__c = listSprints[intCounter].Id;
			} else if (System.Math.mod(intCounter, 3) == 1) {
				work.Sprint__c = listSprints[intCounter].Id;
			} else if (System.Math.mod(intCounter, 3) == 2) {
				work.Sprint__c = listSprints[intCounter].Id;
			}
				
			if (System.Math.mod(intCounter, 3) == 0) {
				work.Status__c = 'Not Started';
			} else if (System.Math.mod(intCounter, 3) == 1) {
				work.Status__c = 'In Progress';
			} else if (System.Math.mod(intCounter, 3) == 2) {
				work.Status__c = 'Closed';
			}
				
			listWorks.add(work);
		}
		insert listWorks;

		List<Work_Task__c> listWorkTasks = new List<Work_Task__c>();
		for (Integer intCounter = 0; intCounter < 6; intCounter++) {
			Work_Task__c workTask = new Work_Task__c(Name = 'multipleSprintBurndowns_Test-activeWork-' + intCounter,
								Work__c = listWorks[intCounter].Id, Estimated_Hours__c = 2, Remaining_Hours__c = 2);
			if (System.Math.mod(intCounter, 3) == 0) {
				workTask.Status__c = 'Not Started';
			} else if (System.Math.mod(intCounter, 3) == 1) {
				workTask.Status__c = 'In Progress';
			} else if (System.Math.mod(intCounter, 3) == 2) {
				workTask.Status__c = 'Closed';
			}
			listWorkTasks.add(workTask);
		}

		Test.startTest();
			SprintBurndownNightlyRollup sch = new SprintBurndownNightlyRollup();
			sch.strQuery =	'SELECT Id, Sprint__c, Story_Points__c, ' +
                            	'(SELECT Id, Work__c, Remaining_Hours__c FROM Work__c.Work_Tasks__r ' +
	                        	'WHERE Status__c IN (\'Not Started\', \'In Progress\')) ' +
                        	'FROM Work__c ' +
                        	'WHERE Status__c IN (\'Not Started\', \'In Progress\') ' +
                        	'AND Sprint__r.Status__c = \'In Progress\' ' +
                        	'AND Sprint__r.Name LIKE \'multipleSprintBurndowns_Test%\'';
			Database.executeBatch(sch);
		Test.stopTest();

		List<Sprint_Burndown__c> listSprintBurns =	[SELECT Id, Sprint__c,
													Total_Points_Remaining__c, Total_Hours_Remaining__c
													FROM Sprint_Burndown__c
													WHERE Sprint__r.Name LIKE 'multipleSprintBurndowns_Test%'];
		System.debug(listSprintBurns);
		System.assert(listSprintBurns.size() == 10, 'There should be ten Sprint Burndowns');
	}
}