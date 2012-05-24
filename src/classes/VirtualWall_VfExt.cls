public with sharing class VirtualWall_VfExt {
	/*
		Purpose:
				- Provide list of existing User Stories and Tasks to be displayed to users on a VF page
				- Provide RemoteAction that updates Tasks after drag and drop to update Task Status.

		Used By:
				VirtualWall.page

		History:
		Created: 30-Dec-2012 By: Manu Erwin
	*/

    public VirtualWall_VfExt(ApexPages.StandardController stdController) {
    	this.sprint = (Sprint__c)stdController.getRecord();
    }

    private Sprint__c sprint;

    public List<StoryAndTasks> listStoryAndTasks {
        get {
            if (listStoryAndTasks == null) {
			    listStoryAndTasks = new List<StoryAndTasks>();
                for (User_Story__c oneUserStory : [SELECT Id, Name, Owner.Alias, Sprint__c, Story_Number__c, Status__c, Story_Indicator__c, 
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
    public Boolean userStoriesAndTasksExist {
    	get {
    		if (userStoriesAndTasksExist == null) {
				userStoriesAndTasksExist = false;
    			if (!listStoryAndTasks.isEmpty()) {
    				userStoriesAndTasksExist = true;
    			}
    		}
    		return userStoriesAndTasksExist;
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

	/* TEST METHODS */
    @isTest static void noStoriesAndTasksExist_Test() {
		Sprint__c sprint = new Sprint__c (Name = 'noStoriesAndTasksExist_Test',
								Status__c = 'In Progress',
								Start_Date__c = System.today().addDays(-2),
								End_Date__c = System.today().addDays(+2));
		insert sprint;

		Test.startTest();
		Test.setCurrentPage(Page.VirtualWall);
		// Requery Sprint so that formula field retrieved
		sprint = [SELECT Id, Name, Status__c, Start_Date__c, End_Date__c, Total_Sprint_Days__c FROM Sprint__c WHERE Id = :sprint.Id];
		ApexPages.StandardController controller = new ApexPages.StandardController(sprint);
		VirtualWall_VfExt virtualWallCon = new VirtualWall_VfExt(controller);

		Boolean bolUserStoriesTasksExist = virtualWallCon.userStoriesAndTasksExist;
		Test.stopTest();

		System.assert(!bolUserStoriesTasksExist, 'There should be no User Story and Tasks: ' + bolUserStoriesTasksExist);
    }
    @isTest static void storiesAndTasksExist_Test() {
		Sprint__c sprint = new Sprint__c (Name = 'storiesAndTasksExist_Test-',
							Status__c = 'In Progress',
							Start_Date__c = System.today().addDays(-2),
							End_Date__c = System.today().addDays(+2));
		insert sprint;

		List<User_Story__c> listUserStories = new List<User_Story__c>();
		for (Integer intCounter = 0; intCounter < 4; intCounter++) {
			User_Story__c userStory = new User_Story__c(Name = 'storiesAndTasksExist_Test-' + sprint.Id + intCounter,
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
		insert listUserStories;

		List<User_Story_Task__c> listUserStoryTasks = new List<User_Story_Task__c>();
		for (User_Story__c userStory : listUserStories) {
			if (userStory.Status__c == 'Not Started' || userStory.Status__c == 'In Progress') {
				System.debug('##DEBUG: userStory.Status not Done - create USTs: ' + userStory);
				for (Integer intCounter = 0; intCounter < 4; intCounter++) {
					User_Story_Task__c userStoryTask = new User_Story_Task__c(Name = 'storiesAndTasksExist_Test-' + userStory.Id + intCounter,
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
						userStoryTask.Remaining_Hours__c = 0;
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
		Test.setCurrentPage(Page.VirtualWall);
		// Requery Sprint so that formula field retrieved
		sprint = [SELECT Id, Name, Status__c, Start_Date__c, End_Date__c, Total_Sprint_Days__c FROM Sprint__c WHERE Id = :sprint.Id];
		ApexPages.StandardController controller = new ApexPages.StandardController(sprint);
		VirtualWall_VfExt virtualWallCon = new VirtualWall_VfExt(controller);

		Boolean bolUserStoriesTasksExist = virtualWallCon.userStoriesAndTasksExist;
		System.assert(bolUserStoriesTasksExist, 'There should be User Stories and Tasks: ' + bolUserStoriesTasksExist);

		List<StoryAndTasks> listStoryAndTasks = virtualWallCon.listStoryAndTasks;
		System.assert(!listStoryAndTasks.isEmpty(), 'There should be User Stories and Tasks: ' + listStoryAndTasks);

		Test.stopTest();
    }
}