@isTest
private class SprintBurndownNightlyRollup_Test {
	static testMethod void closedVsInProgressNotStarteduserStorys_Test() {
		// userStorys with Closed status should be ignored in calculations however
		// Not Started and In Progress should be processed.
		Sprint__c sprint01 = new Sprint__c (Name = 'closedVsInProgressNotStarteduserStorys_Test',
								Status__c = 'In Progress',
								Start_Date__c = System.today().addDays(-2),
								End_Date__c = System.today().addDays(+2));
		insert sprint01;

		List<User_Story__c> listUserStories = new List<User_Story__c>();
		// Add 50 each of Not Started, In Progress and Closed
		for (Integer intCounter = 0; intCounter < 50; intCounter++) {
			User_Story__c userStory = new User_Story__c(Name = 'closedVsInProgressNotStarteduserStorys_Test-InProgress-' + intCounter,
							Sprint__c = sprint01.Id,
							Status__c = 'In Progress',
							Story_Points__c = 2);
			listUserStories.add(userStory);
		}
		for (Integer intCounter = 0; intCounter < 50; intCounter++) {
			User_Story__c userStory = new User_Story__c(Name = 'closedVsInProgressNotStarteduserStorys_Test-Not Started-' + intCounter,
							Sprint__c = sprint01.Id,
							Status__c = 'Not Started',
							Story_Points__c = 2);
			listUserStories.add(userStory);
		}
		for (Integer intCounter = 0; intCounter < 50; intCounter++) {
			User_Story__c userStory = new User_Story__c(Name = 'closedVsInProgressNotStarteduserStorys_Test-Closed-' + intCounter,
							Sprint__c = sprint01.Id,
							Status__c = 'Closed',
							Story_Points__c = 2);
			listUserStories.add(userStory);
		}
		insert listUserStories;

		Test.startTest();
			SprintBurndownNightlyRollup sch = new SprintBurndownNightlyRollup();
			sch.strQuery =	'SELECT Id, Sprint__c, Story_Points__c, ' +
                            	'(SELECT Id, User_Story__c, Remaining_Hours__c FROM User_Story__c.User_Story_Tasks__r ' +
	                        	'WHERE Status__c IN (\'Not Started\', \'In Progress\')) ' +
                        	'FROM User_Story__c ' +
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
	static testMethod void notStartedInProgressVsCloseduserStoryTasks_Test() {
		// userStory Tasks with Closed status should be ignored in calculations however
		// Not Started and In Progress userStory Tasks should be processed.
		Sprint__c sprint01 = new Sprint__c (Name = 'notStartedInProgressVsCloseduserStoryTasks',
								Status__c = 'In Progress',
								Start_Date__c = System.today().addDays(-2),
								End_Date__c = System.today().addDays(+2));
		insert sprint01;

		// Add 10 each of Not Started, In Progress userStory records
		List<User_Story__c> listUserStories = new List<User_Story__c>();
		for (Integer intCounter = 0; intCounter < 20; intCounter++) {
			User_Story__c userStory = new User_Story__c(Name = 'notStartedInProgressVsCloseduserStoryTasks-' + intCounter,
							Sprint__c = sprint01.Id,
							Story_Points__c = 2);
			if (System.Math.mod(intCounter, 2) == 0) {
				userStory.Status__c = 'Not Started';
			} else if (System.Math.mod(intCounter, 2) == 1) {
				userStory.Status__c = 'In Progress';
			}
				
			listUserStories.add(userStory);
		}
		insert listUserStories;

		// Add 10 Closed userStory records
		List<User_Story__c> listUserStoriesClosed = new List<User_Story__c>();
		for (Integer intCounter = 0; intCounter < 10; intCounter++) {
			User_Story__c userStory = new User_Story__c(Name = 'notStartedInProgressVsCloseduserStoryTasks-Closed-' + intCounter,
							Sprint__c = sprint01.Id,
							Status__c = 'Closed',
							Story_Points__c = 2);
			listUserStoriesClosed.add(userStory);
		}
		insert listUserStoriesClosed;

		List<User_Story_Task__c> listuserStoryTasks = new List<User_Story_Task__c>();
		// Add 4 'active' userStory Tasks and 2 'inactive' userStoryTasks to the 'active' userStorys - only 4 should be counted
		for (Integer intCounter = 0; intCounter < 6; intCounter++) {
			User_Story_Task__c userStoryTask = new User_Story_Task__c(Name = 'notStartedInProgressVsCloseduserStoryTasks-activeuserStory-' + intCounter,
								User_Story__c = listUserStories[intCounter].Id, Estimated_Hours__c = 2, Remaining_Hours__c = 2);
			if (System.Math.mod(intCounter, 3) == 0) {
				userStoryTask.Status__c = 'Not Started';
			} else if (System.Math.mod(intCounter, 3) == 1) {
				userStoryTask.Status__c = 'In Progress';
			} else if (System.Math.mod(intCounter, 3) == 2) {
				userStoryTask.Status__c = 'Closed';
			}
			listuserStoryTasks.add(userStoryTask);
		}
		// Add 4 'active' userStory Tasks and 2 'inactive' userStoryTasks to the 'inactive' userStorys - all should be ignored
		for (Integer intCounter = 0; intCounter < 6; intCounter++) {
			User_Story_Task__c userStoryTask = new User_Story_Task__c(Name = 'notStartedInProgressVsCloseduserStoryTasks-closeduserStory-' + intCounter,
							User_Story__c = listUserStoriesClosed[intCounter].Id, Estimated_Hours__c = 2, Remaining_Hours__c = 2);
			if (System.Math.mod(intCounter, 3) == 0) {
				userStoryTask.Status__c = 'Not Started';
			} else if (System.Math.mod(intCounter, 3) == 1) {
				userStoryTask.Status__c = 'In Progress';
			} else if (System.Math.mod(intCounter, 3) == 2) {
				userStoryTask.Status__c = 'Closed';
			}
			listuserStoryTasks.add(userStoryTask);
		}
		System.debug(listuserStoryTasks);
		insert listuserStoryTasks;

		Test.startTest();
			SprintBurndownNightlyRollup sch = new SprintBurndownNightlyRollup();
			sch.strQuery =	'SELECT Id, Sprint__c, Story_Points__c, ' +
                            	'(SELECT Id, User_Story__c, Remaining_Hours__c FROM User_Story__c.User_Story_Tasks__r ' +
	                        	'WHERE Status__c IN (\'Not Started\', \'In Progress\')) ' +
                        	'FROM User_Story__c ' +
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

		// Add 10 each of Not Started, In Progress and Closed User Story records
		List<User_Story__c> listUserStories = new List<User_Story__c>();
		for (Integer intCounter = 0; intCounter < 30; intCounter++) {
			User_Story__c userStory = new User_Story__c(Name = 'multipleSprintBurndowns_Test-' + intCounter,
							Story_Points__c = 2);
			if (System.Math.mod(intCounter, 2) == 0) {
				userStory.Sprint__c = listSprints[intCounter].Id;
			} else if (System.Math.mod(intCounter, 3) == 1) {
				userStory.Sprint__c = listSprints[intCounter].Id;
			} else if (System.Math.mod(intCounter, 3) == 2) {
				userStory.Sprint__c = listSprints[intCounter].Id;
			}
				
			if (System.Math.mod(intCounter, 3) == 0) {
				userStory.Status__c = 'Not Started';
			} else if (System.Math.mod(intCounter, 3) == 1) {
				userStory.Status__c = 'In Progress';
			} else if (System.Math.mod(intCounter, 3) == 2) {
				userStory.Status__c = 'Closed';
			}
				
			listUserStories.add(userStory);
		}
		insert listUserStories;

		List<User_Story_Task__c> listuserStoryTasks = new List<User_Story_Task__c>();
		for (Integer intCounter = 0; intCounter < 6; intCounter++) {
			User_Story_Task__c userStoryTask = new User_Story_Task__c(Name = 'multipleSprintBurndowns_Test-activeuserStory-' + intCounter,
								User_Story__c = listUserStories[intCounter].Id, Estimated_Hours__c = 2, Remaining_Hours__c = 2);
			if (System.Math.mod(intCounter, 3) == 0) {
				userStoryTask.Status__c = 'Not Started';
			} else if (System.Math.mod(intCounter, 3) == 1) {
				userStoryTask.Status__c = 'In Progress';
			} else if (System.Math.mod(intCounter, 3) == 2) {
				userStoryTask.Status__c = 'Closed';
			}
			listuserStoryTasks.add(userStoryTask);
		}

		Test.startTest();
			SprintBurndownNightlyRollup sch = new SprintBurndownNightlyRollup();
			sch.strQuery =	'SELECT Id, Sprint__c, Story_Points__c, ' +
                            	'(SELECT Id, User_Story__c, Remaining_Hours__c FROM User_Story__c.User_Story_Tasks__r ' +
	                        	'WHERE Status__c IN (\'Not Started\', \'In Progress\')) ' +
                        	'FROM User_Story__c ' +
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