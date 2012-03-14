@isTest
private class VirtualWall_VfExt_Test {

    static testMethod void noStoriesAndTasksExist_Test() {
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
    static testMethod void storiesAndTasksExist_Test() {
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