@isTest
private class SprintBurndownNightlyRollup_Test {

	static testMethod void DoneVsInProgressNotStarteduserStorys_Test() {
		// userStorys with Done status should be ignored in calculations however
		// Not Started and In Progress should be processed.
		Sprint__c sprint01 = new Sprint__c (Name = 'DoneVsInProgressNotStarteduserStorys_Test',
								Status__c = 'In Progress',
								Start_Date__c = System.today().addDays(-2),
								End_Date__c = System.today().addDays(+2));
		insert sprint01;

		List<User_Story__c> listUserStories = new List<User_Story__c>();
		// Add 50 each of Not Started, In Progress and Done
		for (Integer intCounter = 0; intCounter < 50; intCounter++) {
			User_Story__c userStory = new User_Story__c(Name = 'DoneVsInProgressNotStarteduserStorys_Test-InProgress-' + intCounter,
							Sprint__c = sprint01.Id,
							Status__c = 'In Progress',
							Story_Points__c = 2);
			listUserStories.add(userStory);
		}
		for (Integer intCounter = 0; intCounter < 50; intCounter++) {
			User_Story__c userStory = new User_Story__c(Name = 'DoneVsInProgressNotStarteduserStorys_Test-Not Started-' + intCounter,
							Sprint__c = sprint01.Id,
							Status__c = 'Not Started',
							Story_Points__c = 2);
			listUserStories.add(userStory);
		}
		for (Integer intCounter = 0; intCounter < 50; intCounter++) {
			User_Story__c userStory = new User_Story__c(Name = 'DoneVsInProgressNotStarteduserStorys_Test-Done-' + intCounter,
							Sprint__c = sprint01.Id,
							Status__c = 'Done',
							Story_Points__c = 2);
			listUserStories.add(userStory);
		}
		insert listUserStories;

		Test.startTest();
			SprintBurndownNightlyRollup sch = new SprintBurndownNightlyRollup();
			sch.strQuery =	'SELECT Id, Sprint__c, Story_Points__c, Status__c, ' +
                            	'(SELECT Id, User_Story__c, Remaining_Hours__c FROM User_Story__c.User_Story_Tasks__r ' +
	                        	'WHERE Status__c IN (\'Not Started\', \'In Progress\')) ' +
                        	'FROM User_Story__c ' +
                        	'WHERE Sprint__r.Status__c = \'In Progress\' ' +
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
	static testMethod void notStartedInProgressVsDoneUserStoryTasks_Test() {
		// userStory Tasks with Done status should be ignored in calculations however
		// Not Started and In Progress userStory Tasks should be processed.
		Sprint__c sprint01 = new Sprint__c (Name = 'notStartedInProgressVsDoneuserStoryTasks',
								Status__c = 'In Progress',
								Start_Date__c = System.today().addDays(-2),
								End_Date__c = System.today().addDays(+2));
		insert sprint01;

		// Add 10 each of Not Started, In Progress userStory records
		List<User_Story__c> listUserStories = new List<User_Story__c>();
		for (Integer intCounter = 0; intCounter < 20; intCounter++) {
			User_Story__c userStory = new User_Story__c(Name = 'notStartedInProgressVsDoneUserStoryTasks-' + intCounter,
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

		// Add 10 'active' userStory Tasks and 10 'inactive' userStoryTasks to the 'active' userStorys - only 10 should be counted
		List<User_Story_Task__c> listUserStoryTasks = new List<User_Story_Task__c>();
		for (Integer intCounter = 0; intCounter < 20; intCounter++) {
			User_Story_Task__c userStoryTask = new User_Story_Task__c(Name = 'notStartedInProgressVsDoneUserStoryTasks-activeuserStory-' + intCounter,
								User_Story__c = listUserStories[intCounter].Id, Estimated_Hours__c = 2);
			Integer intMod4 = System.Math.mod(intCounter, 4);
			if (intMod4 == 0) {
				userStoryTask.Status__c = 'Not Started';
				userStoryTask.Remaining_Hours__c = 2;
			} else if (intMod4 == 1) {
				userStoryTask.Status__c = 'In Progress';
				userStoryTask.Remaining_Hours__c = 2;
			} else if (intMod4 == 2) {
				userStoryTask.Status__c = 'Done';
				userStoryTask.Remaining_Hours__c = 0;
			} else if (intMod4 == 3) {
				userStoryTask.Status__c = 'Cancelled';
				userStoryTask.Remaining_Hours__c = 0;
			}
			listUserStoryTasks.add(userStoryTask);
		}
		insert listUserStoryTasks;

		// Add 20 Done userStory records
		// ASSUMPTION: No User Story Tasks can be added to 'Done' User Stories
		List<User_Story__c> listUserStoriesDone = new List<User_Story__c>();
		for (Integer intCounter = 0; intCounter < 20; intCounter++) {
			User_Story__c userStory = new User_Story__c(Name = 'notStartedInProgressVsDoneUserStoryTasks-Done-' + intCounter,
							Sprint__c = sprint01.Id,
							Status__c = 'Done',
							Story_Points__c = 2);
			listUserStoriesDone.add(userStory);
		}
		insert listUserStoriesDone;

		Test.startTest();
			SprintBurndownNightlyRollup sch = new SprintBurndownNightlyRollup();
			sch.strQuery =	'SELECT Id, Sprint__c, Story_Points__c, Status__c, ' +
                            	'(SELECT Id, User_Story__c, Remaining_Hours__c FROM User_Story__c.User_Story_Tasks__r ' +
	                        	'WHERE Status__c IN (\'Not Started\', \'In Progress\')) ' +
                        	'FROM User_Story__c ' +
                        	'WHERE Sprint__r.Status__c = \'In Progress\' ' +
                        	'AND Sprint__c = \'' + sprint01.Id + '\'';
			Database.executeBatch(sch);
		Test.stopTest();

		List<Sprint_Burndown__c> listSprintBurns =	[SELECT Id, Sprint__c,
													Total_Points_Remaining__c, Total_Hours_Remaining__c
													FROM Sprint_Burndown__c
													WHERE Sprint__c = :sprint01.Id];
		System.assert(listSprintBurns.size() == 1, 'There should be only one Sprint Burndown: ' + listSprintBurns);
		Sprint_Burndown__c theSprintBurndown = listSprintBurns[0];
		System.assert(theSprintBurndown.Total_Hours_Remaining__c == 20, 'There should be 20 hours remaining: ' + theSprintBurndown);
		System.assert(theSprintBurndown.Total_Points_Remaining__c == 40, 'There should be 40 points remaining: ' + theSprintBurndown);
	}
	static testMethod void createZeroSprintBurndown_Test() {
		// When all Stories and Tasks are done, we still need to reflect that by creating a 'zero' Sprint Burndown
		Sprint__c sprint01 = new Sprint__c (Name = 'createZeroSprintBurndown_Test',
								Status__c = 'In Progress',
								Start_Date__c = System.today().addDays(-2),
								End_Date__c = System.today().addDays(+2));
		insert sprint01;

		// Add 200 'Done' User Stories - all should be ignored
		// ASSUMPTION: No User Story Tasks can be added to 'Done' User Stories
		List<User_Story__c> listUserStoriesDone = new List<User_Story__c>();
		for (Integer intCounter = 0; intCounter < 200; intCounter++) {
			User_Story__c userStory = new User_Story__c(Name = 'createZeroSprintBurndown_Test-' + intCounter,
							Sprint__c = sprint01.Id,
							Status__c = 'Done',
							Story_Points__c = 2);
			listUserStoriesDone.add(userStory);
		}
		insert listUserStoriesDone;

		Test.startTest();
			SprintBurndownNightlyRollup sch = new SprintBurndownNightlyRollup();
			sch.strQuery =	'SELECT Id, Sprint__c, Story_Points__c, Status__c, ' +
                            	'(SELECT Id, User_Story__c, Remaining_Hours__c FROM User_Story__c.User_Story_Tasks__r ' +
	                        	'WHERE Status__c IN (\'Not Started\', \'In Progress\')) ' +
                        	'FROM User_Story__c ' +
                        	'WHERE Sprint__r.Status__c = \'In Progress\' ' +
                        	'AND Sprint__c = \'' + sprint01.Id + '\'';
			Database.executeBatch(sch);
		Test.stopTest();

		List<Sprint_Burndown__c> listSprintBurns =	[SELECT Id, Sprint__c,
													Total_Points_Remaining__c, Total_Hours_Remaining__c
													FROM Sprint_Burndown__c
													WHERE Sprint__c = :sprint01.Id];
		System.debug('listSprintBurns: ' + listSprintBurns);
		System.assert(listSprintBurns.size() == 1, 'There should be a "zero" Sprint Burndown');
		Sprint_Burndown__c theSprintBurndown = listSprintBurns[0];
		System.debug('theSprintBurndown.Total_Hours_Remaining: ' + theSprintBurndown.Total_Hours_Remaining__c);
		System.assert(theSprintBurndown.Total_Hours_Remaining__c == 0, 'There should be 0 hours remaining');
		System.debug('theSprintBurndown.Total_Points_Points_Remaining: ' + theSprintBurndown.Total_Points_Remaining__c);
		System.assert(theSprintBurndown.Total_Points_Remaining__c == 0, 'There should be 0 points remaining');
	}
	static testMethod void doNotCreateBurndownsForDoneSprints_Test() {
		// Done Sprints should NOT have Sprint Burndown's created
		Sprint__c sprint01 = new Sprint__c (Name = 'doNotCreateBurndownsForDoneSprints_Test',
								Status__c = 'Done',
								Start_Date__c = System.today().addDays(-233),
								End_Date__c = System.today().addDays(-202));
		insert sprint01;

		// Add 200 'Done' User Stories - all should be ignored
		// ASSUMPTION: No User Story Tasks can be added to 'Done' User Stories
		List<User_Story__c> listUserStoriesDone = new List<User_Story__c>();
		for (Integer intCounter = 0; intCounter < 200; intCounter++) {
			User_Story__c userStory = new User_Story__c(Name = 'doNotCreateBurndownsForDoneSprints_Test-' + intCounter,
							Sprint__c = sprint01.Id,
							Status__c = 'Done',
							Story_Points__c = 2);
			listUserStoriesDone.add(userStory);
		}
		insert listUserStoriesDone;

		Test.startTest();
			SprintBurndownNightlyRollup sch = new SprintBurndownNightlyRollup();
			sch.strQuery =	'SELECT Id, Sprint__c, Story_Points__c, Status__c, ' +
                            	'(SELECT Id, User_Story__c, Remaining_Hours__c FROM User_Story__c.User_Story_Tasks__r ' +
	                        	'WHERE Status__c IN (\'Not Started\', \'In Progress\')) ' +
                        	'FROM User_Story__c ' +
                        	'WHERE Sprint__r.Status__c = \'In Progress\' ' +
                        	'AND Sprint__c = \'' + sprint01.Id + '\'';
			Database.executeBatch(sch);
		Test.stopTest();

		List<Sprint_Burndown__c> listSprintBurns =	[SELECT Id, Sprint__c,
													Total_Points_Remaining__c, Total_Hours_Remaining__c
													FROM Sprint_Burndown__c
													WHERE Sprint__c = :sprint01.Id];
		System.debug('listSprintBurns: ' + listSprintBurns);
		System.assert(listSprintBurns.size() == 0, 'There should be no Sprint Burndowns for this Done sprint');
	}
	static testMethod void doNotCreateZeroSprintBurndown_Test() {
		// If 'In Progress' User Stories exist, we should NOT create a zero Sprint Burndown, i.e., the Sprint Burndown should have point and hour values
		Sprint__c sprint01 = new Sprint__c (Name = 'doNotCreateZeroSprintBurndown_Test',
								Status__c = 'In Progress',
								Start_Date__c = System.today().addDays(-2),
								End_Date__c = System.today().addDays(+2));
		insert sprint01;

		List<User_Story__c> listUserStories = new List<User_Story__c>();
		for (Integer intCounter = 0; intCounter < 20; intCounter++) {
			User_Story__c userStory = new User_Story__c(Name = 'doNotCreateZeroSprintBurndown_Test-' + intCounter,
							Sprint__c = sprint01.Id,
							Status__c = 'In Progress',
							Story_Points__c = 2);
			listUserStories.add(userStory);
		}
		insert listUserStories;

		List<User_Story_Task__c> listUserStoryTasks = new List<User_Story_Task__c>();
		for (Integer intCounter = 0; intCounter < 20; intCounter++) {
			User_Story_Task__c userStoryTask = new User_Story_Task__c(Name = 'doNotCreateZeroSprintBurndown_Test-' + intCounter,
							User_Story__c = listUserStories[intCounter].Id, Estimated_Hours__c = 2, Remaining_Hours__c = 1, Status__c = 'In Progress');
			listUserStoryTasks.add(userStoryTask);
		}
		insert listUserStoryTasks;

		Test.startTest();
			SprintBurndownNightlyRollup sch = new SprintBurndownNightlyRollup();
			sch.strQuery =	'SELECT Id, Sprint__c, Story_Points__c, Status__c, ' +
                            	'(SELECT Id, User_Story__c, Remaining_Hours__c FROM User_Story__c.User_Story_Tasks__r ' +
	                        	'WHERE Status__c IN (\'Not Started\', \'In Progress\')) ' +
                        	'FROM User_Story__c ' +
                        	'WHERE Sprint__r.Status__c = \'In Progress\' ' +
                        	'AND Sprint__c = \'' + sprint01.Id + '\'';
			Database.executeBatch(sch);
		Test.stopTest();

		List<Sprint_Burndown__c> listSprintBurns =	[SELECT Id, Sprint__c,
													Total_Points_Remaining__c, Total_Hours_Remaining__c
													FROM Sprint_Burndown__c
													WHERE Sprint__c = :sprint01.Id];
		System.assert(listSprintBurns.size() == 1, 'There should be only one Sprint Burndown: ' + listSprintBurns);
		Sprint_Burndown__c theSprintBurndown = listSprintBurns[0];
		System.assert(theSprintBurndown.Total_Points_Remaining__c == 40, 'There should be 40 points remaining: ' + theSprintBurndown);
		System.assert(theSprintBurndown.Total_Hours_Remaining__c == 20, 'There should be 20 hours remaining: ' + theSprintBurndown);
	}
	static testMethod void multipleSprintBurndowns_Test() {
		List<Sprint__c> listSprints = new List<Sprint__c>();
		for (Integer intCounter = 0; intCounter < 4; intCounter++) {
			Sprint__c sprint = new Sprint__c (Name = 'multipleSprintBurndowns_Test-' + intCounter,
								Status__c = 'In Progress',
								Start_Date__c = System.today().addDays(-2),
								End_Date__c = System.today().addDays(+2));
			listSprints.add(sprint);
		}
		for (Integer intCounter = 0; intCounter < 4; intCounter++) {
			Sprint__c sprint = new Sprint__c (Name = 'multipleSprintBurndowns_Test-Future-' + intCounter,
								Status__c = 'Not Started',
								Start_Date__c = System.today().addDays(+2),
								End_Date__c = System.today().addDays(+25));
			listSprints.add(sprint);
		}
		for (Integer intCounter = 0; intCounter < 4; intCounter++) {
			Sprint__c sprint = new Sprint__c (Name = 'multipleSprintBurndowns_Test-Past-' + intCounter,
								Status__c = 'Done',
								Start_Date__c = System.today().addDays(-25),
								End_Date__c = System.today().addDays(-2));
			listSprints.add(sprint);
		}
		insert listSprints;

		List<User_Story__c> listUserStories = new List<User_Story__c>();
		for (Sprint__c sprint : listSprints) {
			for (Integer intCounter = 0; intCounter < 4; intCounter++) {
				User_Story__c userStory = new User_Story__c(Name = 'multipleSprintBurndowns_Test-' + sprint.Id + intCounter,
								Story_Points__c = 2, Sprint__c = sprint.Id);
	
				Integer intMod4 = System.Math.mod(intCounter, 4);
				if (intMod4 == 0) {
					userStory.Status__c = 'Not Started';
				} else if (intMod4 == 1) {
					userStory.Status__c = 'In Progress';
				} else if (intMod4 == 2) {
					userStory.Status__c = 'Verify';
				} else if (intMod4 == 3) {
					userStory.Status__c = 'Done';
				}
					
				listUserStories.add(userStory);
			}
		}
		insert listUserStories;

		List<User_Story_Task__c> listUserStoryTasks = new List<User_Story_Task__c>();
		for (User_Story__c userStory : listUserStories) {
			if (userStory.Status__c != 'Done') {
				System.debug('##DEBUG: userStory.Status not Done - create USTs: ' + userStory);
				for (Integer intCounter = 0; intCounter < 4; intCounter++) {
					User_Story_Task__c userStoryTask = new User_Story_Task__c(Name = 'multipleSprintBurndowns_Test-' + userStory.Id + intCounter,
										User_Story__c = userStory.Id, Estimated_Hours__c = 2);
					Integer intMod4 = System.Math.mod(intCounter, 4);
					if (intMod4 == 0) {
						userStoryTask.Status__c = 'Not Started';
						userStoryTask.Remaining_Hours__c = 2;
					} else if (intMod4 == 1) {
						userStoryTask.Status__c = 'In Progress';
						userStoryTask.Remaining_Hours__c = 2;
					} else if (intMod4 == 2) {
						userStoryTask.Status__c = 'Done';
						userStoryTask.Remaining_Hours__c = 0;
					} else if (intMod4 == 3) {
						userStoryTask.Status__c = 'Cancelled';
						userStoryTask.Remaining_Hours__c = 0;
					}
					System.debug('##DEBUG: userStoryTask: ' + userStoryTask);
					listUserStoryTasks.add(userStoryTask);
				}
			} else {
				System.debug('##DEBUG: userStory.Status is Done - no processing: ' + userStory);
			}
		}
		insert listUserStoryTasks;

		Test.startTest();
			SprintBurndownNightlyRollup sch = new SprintBurndownNightlyRollup();
			sch.strQuery =	'SELECT Id, Sprint__c, Story_Points__c, Status__c, ' +
                            	'(SELECT Id, User_Story__c, Remaining_Hours__c FROM User_Story__c.User_Story_Tasks__r ' +
	                        	'WHERE Status__c IN (\'Not Started\', \'In Progress\')) ' +
                        	'FROM User_Story__c ' +
                        	'WHERE Sprint__r.Status__c = \'In Progress\' ' +
                        	'AND Sprint__r.Name LIKE \'multipleSprintBurndowns_Test%\'';
			Database.executeBatch(sch);
		Test.stopTest();

		List<Sprint_Burndown__c> listSprintBurns =	[SELECT Id, Sprint__c,
													Total_Points_Remaining__c, Total_Hours_Remaining__c
													FROM Sprint_Burndown__c
													WHERE Sprint__r.Name LIKE 'multipleSprintBurndowns_Test%'];
		System.assert(listSprintBurns.size() == 4, 'There should be 4 Sprint Burndowns: ' + listSprintBurns);
		for (Sprint_Burndown__c sprintBurn : listSprintBurns) {
			System.assert(sprintBurn.Total_Points_Remaining__c == 6, 'There should be 6 points remaining: ' + sprintBurn);
			System.assert(sprintBurn.Total_Hours_Remaining__c == 12, 'There should be 12 hours remaining: ' + sprintBurn);
		}
	}
}