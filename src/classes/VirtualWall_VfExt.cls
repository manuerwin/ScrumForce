public with sharing class VirtualWall_VfExt {

    public VirtualWall_VfExt() {}
    public VirtualWall_VfExt(ApexPages.StandardController stdController) {
    	this.sprint = (Sprint__c)stdController.getRecord();
    }

    private Sprint__c sprint;

    public List<StoryAndTasks> listStoryAndTasks {
        get {
            if (listStoryAndTasks == null) {
			    listStoryAndTasks = new List<StoryAndTasks>();
                for (User_Story__c oneUserStory : [SELECT Id, Name, Owner.Alias, Sprint__c, Story_Number__c,
	                						(SELECT Id, Name, Description__c,
	                						Status__c, Owner.Alias, Remaining_Hours__c
	                						FROM User_Story_Tasks__r ORDER BY Rank__c ASC)
                            			FROM User_Story__c
                            			WHERE Sprint__c = :sprint.Id
                            			ORDER BY Rank__c ASC] ) {
                	StoryAndTasks oneStoryAndTasks = new StoryAndTasks();
					oneStoryAndTasks.theStory = oneUserStory;
					for (User_Story_Task__c oneUserStoryTask : oneUserStory.User_Story_Tasks__r) {
						if (oneUserStoryTask.Status__c == 'Not Started') {
							oneStoryAndTasks.listTasksToDo.add(oneUserStoryTask);
						} else if (oneUserStoryTask.Status__c == 'In Progress') {
							oneStoryAndTasks.listTasksDoing.add(oneUserStoryTask);
						} else if (oneUserStoryTask.Status__c == 'Verify') {
							oneStoryAndTasks.listTasksVerify.add(oneUserStoryTask);
						} else if (oneUserStoryTask.Status__c == 'Done') {
							oneStoryAndTasks.listTasksDone.add(oneUserStoryTask);
						}
					}
					listStoryAndTasks.add(oneStoryAndTasks);
                }
            }
            System.debug(System.LoggingLevel.DEBUG, '## DEBUG: listStoryAndTasks before return: ' + listStoryAndTasks);
            return listStoryAndTasks;
        }
        set;
    }

	@RemoteAction
	public static Boolean updateTasks (String strKeyValuePairs) {
		Boolean bolSuccess = false;

		if (strKeyValuePairs != null && strKeyValuePairs != '') {
			System.debug(System.LoggingLevel.DEBUG, 'strKeyValuePairs has a value - process it: ' + strKeyValuePairs);
			// Split on & to get key/value pairs
			List<String> listKeyValuePairs = strKeyValuePairs.split('&');
			System.debug(System.LoggingLevel.DEBUG, 'listKeyValuePairs: ' + listKeyValuePairs);
			
			Set<Id> setTaskIds = new Set<Id>();
			Map<Id, String> mapTaskIdToStatus = new Map<Id, String>();
			Map<Id, Integer> mapTaskIdToRank = new Map<Id, Integer>();
	
			// ASSUMPTION: format is status~UserStoryId[]=taskId by this point
			//	e.g., done~a0d60000000vKjfAAE[]=a0o600000026wD8AAI
			Integer intCounter = 1;
			for (String strKeyValuePair : listKeyValuePairs) {
				System.debug(System.LoggingLevel.DEBUG, 'strKeyValuePair: ' + strKeyValuePair);
				Integer intLocationOfTilde = strKeyValuePair.indexOf('~');
				Integer intLocationOfEquals = strKeyValuePair.indexOf('=');
				String strStatus = strKeyValuePair.substring(0, intLocationOfTilde);
				String strTaskId = strKeyValuePair.substring(intLocationOfEquals + 1);
				setTaskIds.add(strTaskId);
				mapTaskIdToStatus.put(strTaskId, strStatus);
				mapTaskIdToRank.put(strTaskId, intCounter);
				intCounter++;
			}
			
			List<User_Story_Task__c> listTasksToUpdate = new List<User_Story_Task__c>();
			// Query for tasks and loop - ASSUMPTION: Less than 200 Tasks per User Story
			for (User_Story_Task__c oneTask : [SELECT Id, Status__c, Rank__c
										FROM User_Story_Task__c
										WHERE Id IN :setTaskIds]) {
				// for each task apply the status and rank from the map
				oneTask.Rank__c = mapTaskIdToRank.get(oneTask.Id);
				String strTaskStatus = mapTaskIdToStatus.get(oneTask.Id);
				if (strTaskStatus == 'toDo') {
					oneTask.Status__c = 'Not Started';
				} else if (strTaskStatus == 'doing') {
					oneTask.Status__c = 'In Progress';
				} else if (strTaskStatus == 'verify') {
					oneTask.Status__c = 'Verify';
				} else if (strTaskStatus == 'done') {
					oneTask.Status__c = 'Done';
				}
				listTasksToUpdate.add(oneTask);
			}
			
			// Update all Tasks
			System.debug(System.LoggingLevel.DEBUG, 'listTasksToUpdate before update: ' + listTasksToUpdate);
			// TODO: Handle errors with the DML and return false to force a revert
			update listTasksToUpdate;
			bolSuccess = true;
		} else {
			System.debug(System.LoggingLevel.DEBUG, 'strKeyValuePairs is null - nothing to process');
		}
		return bolSuccess;
	}
}