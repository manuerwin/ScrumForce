global class SprintBurndownNightlyRollup implements Database.Batchable<sObject>, Database.Stateful {
    //////////////////////////////////////
    // Created: 25-Nov-2011 By: Manu Erwin
    // Purpose: Rollup all 'Not Started' and 'In Progress' Work (Points) and Work Tasks (Hours) to their parent Sprints.
    //			Note: Ignore 'Closed' Work and Work Task records.
    //			Can be run multiple times in the same day because only creates records once.
    //			Allows for the query string to be set for testing.
    //////////////////////////////////////

    // Map of Sprint Ids to Sprint Burndown records that will populated during the process
    global Map<Id, Sprint_Burndown__c> mapSprintIdToSprintBurndown;
    public String strQuery;

    // Constructor
    global SprintBurndownNightlyRollup () {
        System.debug(System.LoggingLevel.DEBUG, '##DEBUG: Constructor');
        mapSprintIdToSprintBurndown = new Map<Id, Sprint_Burndown__c>();
        if (strQuery == null){
	        System.debug(System.LoggingLevel.DEBUG, '##DEBUG: Using the default query for Production execution');
        	strQuery =	'SELECT Id, Sprint__c, Story_Points__c, ' +
                            '(SELECT Id, Work__c, Remaining_Hours__c FROM Work__c.Work_Tasks__r ' +
	                        'WHERE Status__c IN (\'Not Started\', \'In Progress\')' +
                        'FROM Work__c ' +
                        'WHERE Status__c IN (\'Not Started\', \'In Progress\')' +
                        'AND Sprint__r.Status__c = \'In Progress\'';
        } else {
	        System.debug(System.LoggingLevel.DEBUG, '##DEBUG: strQuery has been set - i.e., for testing');
        }
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        // Find all Work (and 'active' child Work Tasks) where the 'parent' Sprint is active
        //      (assume status either formula based on end date OR updated by time based WF)
        //      AND Work.Status = planned or active
        System.debug(System.LoggingLevel.DEBUG, '##DEBUG: Start with strQuery: ' + strQuery);
        return Database.getQueryLocator(strQuery);
    }

    global void execute(Database.BatchableContext BC, List<Work__c> listWorks) {
    System.debug(System.LoggingLevel.DEBUG, '##DEBUG: execute');
        // loop through Work records
        for (Work__c work : listWorks) {
            Sprint_Burndown__c sprintBurndown;
            // obtain SprintBurndown from map (using Work.SprintId) or
            // create if first time (default rollup fields to zero and date to today)
            if (mapSprintIdToSprintBurndown.containsKey(work.Sprint__c)) {
                sprintBurndown = mapSprintIdToSprintBurndown.get(work.Sprint__c);
                System.debug(System.LoggingLevel.DEBUG, '##DEBUG: sprintBurndown obtained from map:' + sprintBurndown);
            } else {
                System.debug(System.LoggingLevel.DEBUG, '##DEBUG: Create new sprintBurndown');
                // Note: Setting the Unique field so can upsert existing records
                sprintBurndown = new Sprint_Burndown__c(Sprint__c = work.Sprint__c, Date__c = System.today(),
                                Total_Points_Remaining__c = 0, Total_Hours_Remaining__c = 0,
                                Unique_Sprint_Burndown__c = work.Sprint__c + '-' + String.valueOf(System.today()));
            }

            // add Work Story Points to SprintBurndown
            sprintBurndown.Total_Points_Remaining__c += work.Story_Points__c;

            // loop child Work Tasks
            for (Work_Task__c workTask : work.Work_Tasks__r) {
                // add Hours Remaining to SprintBurndown
                sprintBurndown.Total_Hours_Remaining__c += workTask.Remaining_Hours__c;
            }

            // put SprintBurndown (back) into Map
            System.debug(System.LoggingLevel.DEBUG, '##DEBUG: sprintBurndown before put into map: ' + sprintBurndown);
            mapSprintIdToSprintBurndown.put(work.Sprint__c, sprintBurndown);
        }
    }

    global void finish(Database.BatchableContext BC) {
	    System.debug(System.LoggingLevel.DEBUG, '##DEBUG: finish');
        if (!mapSprintIdToSprintBurndown.values().isEmpty()) {
            // attempt to insert list of SprintBurndown records that have been populated during the batch process
            System.debug(System.LoggingLevel.INFO, '##DEBUG: about to upsert Sprint Burndowns: ' + mapSprintIdToSprintBurndown.values());
            // Upserting rather than inserting so can run test methods without duplicate errors 
            upsert mapSprintIdToSprintBurndown.values() Unique_Sprint_Burndown__c;
        } else {
            System.debug(System.LoggingLevel.INFO, '##DEBUG: no records to insert');
        }
    }
}