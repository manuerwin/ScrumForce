global class SprintBurndownNightlyRollup implements Database.Batchable<sObject>, Database.Stateful {
	/*
		PURPOSE:
		- Rollup all 'Not Started' and 'In Progress' User Story (Points) and User Story Tasks (Hours)
		to a 'Sprint Burndown' record attached to the top level Sprint.
		- Ignore 'Done' User Story and User Story Task records in these Sprint Burndown records
		however do create a 'zero' Sprint Burndown record in the scenario where ALL User Stories are Done
		(by definition means all User Story Tasks are Done).

		- Can be run multiple times in the same day because only creates records once.
		- Allows for the query string to be set for testing.
		
		HISTORY:
		25-Nov-2011 Manu Erwin		Created
		26-Feb-2012 Manu Erwin		Fix: #41 - If ALL User Stories (and child Tasks) are DONE still create a zero Sprint Burndown
		24-May-2012 Manu Erwin		FIX: Merging test methods into main class
	*/

    // Map of Sprint Ids to Sprint Burndown records that will populated during the process
    global Map<Id, Sprint_Burndown__c> mapSprintIdToSprintBurndown;
    public String strQuery;

    // Constructor
    global SprintBurndownNightlyRollup () {
        System.debug(System.LoggingLevel.DEBUG, '##DEBUG: Constructor');
        mapSprintIdToSprintBurndown = new Map<Id, Sprint_Burndown__c>();
        if (strQuery == null){
	        System.debug(System.LoggingLevel.DEBUG, '##DEBUG: Using the default query for Production execution');
        	strQuery =	'SELECT Id, Sprint__c, Story_Points__c, Status__c, ' +
                            '(SELECT Id, User_Story__c, Remaining_Hours__c, Status__c FROM User_Story__c.User_Story_Tasks__r ' +
	                        'WHERE Status__c IN (\'Not Started\', \'In Progress\', \'Verify\')) ' +
                        'FROM User_Story__c ' +
                        'WHERE Sprint__r.Status__c = \'In Progress\'';
        } else {
	        System.debug(System.LoggingLevel.DEBUG, '##DEBUG: strQuery has been set - i.e., for testing');
        }
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        // Find all User Stories (and 'active' child User Story Tasks) where the 'parent' Sprint is active
        //      (assume status either formula based on end date OR updated by time based WF)
        System.debug(System.LoggingLevel.DEBUG, '##DEBUG: Start with strQuery: ' + strQuery);
        return Database.getQueryLocator(strQuery);
    }

    global void execute(Database.BatchableContext BC, List<User_Story__c> listUserStories) {
    	System.debug(System.LoggingLevel.DEBUG, '##DEBUG: execute');
        // loop through User Story records
        if (!listUserStories.isEmpty() ) {
            System.debug(System.LoggingLevel.DEBUG, '##DEBUG: number of User Story records to process:' + listUserStories.size());
	        for (User_Story__c userStory : listUserStories) {
	            System.debug(System.LoggingLevel.DEBUG, '##DEBUG: userStory:' + userStory);
	            Sprint_Burndown__c sprintBurndown;
	            // obtain SprintBurndown from map (using UserStory.SprintId) or
	            // create if first time (default rollup fields to zero and date to today)
	            if (mapSprintIdToSprintBurndown.containsKey(userStory.Sprint__c)) {
	                sprintBurndown = mapSprintIdToSprintBurndown.get(userStory.Sprint__c);
	                System.debug(System.LoggingLevel.DEBUG, '##DEBUG: sprintBurndown obtained from map: ' + sprintBurndown);
	            } else {
	                System.debug(System.LoggingLevel.DEBUG, '##DEBUG: Create new sprintBurndown');
	                // Note: Setting the Unique field so can upsert existing records
	                sprintBurndown = new Sprint_Burndown__c(Sprint__c = userStory.Sprint__c, Date__c = System.today(),
	                                Total_Points_Remaining__c = 0, Total_Hours_Remaining__c = 0,
	                                Unique_Sprint_Burndown__c = userStory.Sprint__c + '-' + String.valueOf(System.today()));
	            }

				if (userStory.Status__c == 'Not Started' || userStory.Status__c == 'In Progress') {
	                System.debug(System.LoggingLevel.DEBUG, '##DEBUG: User Story Status = Not Started/In Progress - add points: ' + userStory);
		            if (userStory.Story_Points__c != null) {
			            // add User Story Story Points to SprintBurndown
			            sprintBurndown.Total_Points_Remaining__c += userStory.Story_Points__c;
		            }
		
		            // loop child userStory Tasks
		            for (User_Story_Task__c userStoryTask : userStory.User_Story_Tasks__r) {
		                System.debug(System.LoggingLevel.DEBUG, '##DEBUG: User Story Task - add hours: ' + userStoryTask);
			            if (userStoryTask.Remaining_Hours__c != null) {
			                // add Hours Remaining to SprintBurndown
			                sprintBurndown.Total_Hours_Remaining__c += userStoryTask.Remaining_Hours__c;
			            }
		            }
				} else {
	                System.debug(System.LoggingLevel.DEBUG, '##DEBUG: User Story Status = Cancelled/Done - no calculations');
				}
	
	            // put SprintBurndown (back) into Map
	            System.debug(System.LoggingLevel.DEBUG, '##DEBUG: sprintBurndown before put into map: ' + sprintBurndown);
	            mapSprintIdToSprintBurndown.put(userStory.Sprint__c, sprintBurndown);
	        }
        } else {
	        System.debug(System.LoggingLevel.DEBUG, '##DEBUG: zero records to process:' + listUserStories.size());
        }
    }

    global void finish(Database.BatchableContext BC) {
	    System.debug(System.LoggingLevel.DEBUG, '##DEBUG: finish');
        if (!mapSprintIdToSprintBurndown.values().isEmpty()) {
            // attempt to upsert list of SprintBurndown records that have been populated during the batch process
            System.debug(System.LoggingLevel.INFO, '##DEBUG: about to upsert Sprint Burndowns: ' + mapSprintIdToSprintBurndown.values());
            // Upserting so that only one record per sprint is created per day 
            upsert mapSprintIdToSprintBurndown.values() Unique_Sprint_Burndown__c;
        } else {
            System.debug(System.LoggingLevel.INFO, '##DEBUG: no records to upsert');
        }
    }

	/* TEST METHODS */
	@isTest static void DoneVsInProgressNotStarteduserStorys_Test() {
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
                            	'(SELECT Id, User_Story__c, Remaining_Hours__c, Status__c FROM User_Story__c.User_Story_Tasks__r ' +
	                        	'WHERE Status__c IN (\'Not Started\', \'In Progress\', \'Verify\')) ' +
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
	@isTest static void notStartedInProgressVsDoneUserStoryTasks_Test() {
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
                            	'(SELECT Id, User_Story__c, Remaining_Hours__c, Status__c FROM User_Story__c.User_Story_Tasks__r ' +
	                        	'WHERE Status__c IN (\'Not Started\', \'In Progress\', \'Verify\')) ' +
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
	@isTest static void createZeroSprintBurndown_Test() {
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
                            	'(SELECT Id, User_Story__c, Remaining_Hours__c, Status__c FROM User_Story__c.User_Story_Tasks__r ' +
	                        	'WHERE Status__c IN (\'Not Started\', \'In Progress\', \'Verify\')) ' +
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
	@isTest static void doNotCreateBurndownsForDoneSprints_Test() {
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
                            	'(SELECT Id, User_Story__c, Remaining_Hours__c, Status__c FROM User_Story__c.User_Story_Tasks__r ' +
	                        	'WHERE Status__c IN (\'Not Started\', \'In Progress\', \'Verify\')) ' +
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
	@isTest static void doNotCreateZeroSprintBurndown_Test() {
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
                            	'(SELECT Id, User_Story__c, Remaining_Hours__c, Status__c FROM User_Story__c.User_Story_Tasks__r ' +
	                        	'WHERE Status__c IN (\'Not Started\', \'In Progress\', \'Verify\')) ' +
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
	@isTest static void multipleSprintBurndowns_Test() {
		List<Sprint__c> listSprints = new List<Sprint__c>();
		// Distractors
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
		// Actual Sprint records
		for (Integer intCounter = 0; intCounter < 4; intCounter++) {
			Sprint__c sprint = new Sprint__c (Name = 'multipleSprintBurndowns_Test-' + intCounter,
								Status__c = 'In Progress',
								Start_Date__c = System.today().addDays(-2),
								End_Date__c = System.today().addDays(+2));
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
					userStory.Status__c = 'Done';
				} else if (intMod4 == 3) {
					userStory.Status__c = 'Cancelled';
				}
				listUserStories.add(userStory);
			}
		}
		insert listUserStories;

		List<User_Story_Task__c> listUserStoryTasks = new List<User_Story_Task__c>();
		for (User_Story__c userStory : listUserStories) {
			if (userStory.Status__c == 'Not Started' || userStory.Status__c == 'In Progress') {
				System.debug('##DEBUG: userStory.Status Not Started/In Progress - create USTs: ' + userStory);
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
						userStoryTask.Status__c = 'Verify';
						userStoryTask.Remaining_Hours__c = 2;
					} else if (intMod4 == 3) {
						userStoryTask.Status__c = 'Done';
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
                            	'(SELECT Id, User_Story__c, Remaining_Hours__c, Status__c FROM User_Story__c.User_Story_Tasks__r ' +
	                        	'WHERE Status__c IN (\'Not Started\', \'In Progress\', \'Verify\')) ' +
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
			System.assert(sprintBurn.Total_Points_Remaining__c == 4, 'There should be 4 points remaining: ' + sprintBurn);
			System.assert(sprintBurn.Total_Hours_Remaining__c == 12, 'There should be 12 hours remaining: ' + sprintBurn);
		}
	}
}