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
}