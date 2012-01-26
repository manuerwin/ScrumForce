@isTest
private class UpdateParentUserStoryStatus_Test {

    static testMethod void insertInProgress_Test() {
		List<User_Story__c> listUserStories = new List<User_Story__c>();
		for (Integer intCounter = 0; intCounter < 4; intCounter++) {
			User_Story__c userStory = new User_Story__c(Name = 'insertInProgress_Test-' + intCounter,
										Status__c = 'Not Started');
			listUserStories.add(userStory);
		}
		insert listUserStories;

		Test.startTest();
		List<User_Story_Task__c> listUserStoryTasks = new List<User_Story_Task__c>();
		for (Integer intCounter = 0; intCounter < 300; intCounter++) {
			User_Story_Task__c usTask = new User_Story_Task__c();
			usTask.Name = 'insertInProgress_Test: ' + intCounter;
			usTask.Estimated_Hours__c = 23;

			Integer intCounterMod4 = Math.mod(intCounter, 4);
			if (intCounterMod4 == 0) {
				usTask.Status__c = 'Not Started';
			} else if (intCounterMod4 == 1) {
				usTask.Status__c = 'In Progress';
			} else if (intCounterMod4 == 2) {
				usTask.Status__c = 'Verify';
			} else if (intCounterMod4 == 3) {
				usTask.Status__c = 'Closed';
			}

			// Groups of four
			Integer intCounterMod16 = Math.mod(intCounter, 16);
			if (intCounterMod16 <= 3) {
				usTask.User_Story__c = listUserStories[0].Id;
			} else if (intCounterMod16 > 3 && intCounterMod16 < 8) {
				usTask.User_Story__c = listUserStories[1].Id;
			} else if (intCounterMod16 > 7 && intCounterMod16 < 12) {
				usTask.User_Story__c = listUserStories[2].Id;
			} else if (intCounterMod16 > 11) {
				usTask.User_Story__c = listUserStories[3].Id;
			}

			listUserStoryTasks.add(usTask);
		}
		insert listUserStoryTasks;

		User_Story__c userStoryCheck1 = [SELECT Id, Status__c FROM User_Story__c WHERE Id = :listUserStories[0].Id];
		System.assert(userStoryCheck1.Status__c == 'In Progress', 'US1 status SHOULD be _In Progress_');
		User_Story__c userStoryCheck2 = [SELECT Id, Status__c FROM User_Story__c WHERE Id = :listUserStories[1].Id];
		System.assert(userStoryCheck2.Status__c == 'In Progress', 'US2 status SHOULD be _In Progress_');
		User_Story__c userStoryCheck3 = [SELECT Id, Status__c FROM User_Story__c WHERE Id = :listUserStories[2].Id];
		System.assert(userStoryCheck3.Status__c == 'In Progress', 'US3 status SHOULD be _In Progress_');
		User_Story__c userStoryCheck4 = [SELECT Id, Status__c FROM User_Story__c WHERE Id = :listUserStories[3].Id];
		System.assert(userStoryCheck4.Status__c == 'In Progress', 'US4 status SHOULD be _In Progress_');
		Test.stopTest();
    }
    static testMethod void updateToInProgress_Test() {
		User_Story__c userStory01 = new User_Story__c(Name = 'updateToInProgress_Test', Status__c = 'Not Started');
		insert userStory01;

		Test.startTest();
		List<User_Story_Task__c> listUserStoryTasks = new List<User_Story_Task__c>();
		for (Integer intCounter = 0; intCounter < 300; intCounter++) {
			User_Story_Task__c usTask = new User_Story_Task__c();
			usTask.Name = 'updateToInProgress_Test: ' + intCounter;
			usTask.Estimated_Hours__c = 23;
			usTask.User_Story__c = userStory01.Id;
			usTask.Status__c = 'Not Started';
			listUserStoryTasks.add(usTask);
		}
		insert listUserStoryTasks;

		User_Story__c userStoryCheck = [SELECT Id, Status__c FROM User_Story__c WHERE Id = :userStory01.Id];
		System.assert(userStoryCheck.Status__c == 'Not Started', 'US status should STILL be _Not Started_');

		for (Integer intCounter = 0; intCounter < 300; intCounter++) {
			 User_Story_Task__c usTask = listUserStoryTasks[intCounter];
			Integer intCounterMod4 = Math.mod(intCounter, 4);
			if (intCounterMod4 == 0) {
				usTask.Status__c = 'Not Started';
			} else if (intCounterMod4 == 1) {
				usTask.Status__c = 'In Progress';
			} else if (intCounterMod4 == 2) {
				usTask.Status__c = 'Verify';
			} else if (intCounterMod4 == 3) {
				usTask.Status__c = 'Closed';
			}
		}
		update listUserStoryTasks;

		userStoryCheck = [SELECT Id, Status__c FROM User_Story__c WHERE Id = :userStory01.Id];
		System.assert(userStoryCheck.Status__c == 'In Progress', 'US status SHOULD be _In Progress_');
		Test.stopTest();
    }
    static testMethod void userStoryAlreadyInProgress_Test() {
		User_Story__c userStory01 = new User_Story__c(Name = 'userStoryAlreadyInProgress_Test', Status__c = 'In Progress');
		insert userStory01;

		Test.startTest();
		List<User_Story_Task__c> listUserStoryTasks = new List<User_Story_Task__c>();
		for (Integer intCounter = 0; intCounter < 300; intCounter++) {
			User_Story_Task__c usTask = new User_Story_Task__c();
			usTask.Name = 'userStoryAlreadyInProgress_Test: ' + intCounter;
			usTask.Estimated_Hours__c = 23;
			usTask.User_Story__c = userStory01.Id;
			usTask.Status__c = 'Not Started';
			listUserStoryTasks.add(usTask);
		}
		insert listUserStoryTasks;

		User_Story__c userStoryCheck = [SELECT Id, Status__c FROM User_Story__c WHERE Id = :userStory01.Id];
		System.assert(userStoryCheck.Status__c == 'In Progress', 'US status should STILL be _In Progress_');
		Test.stopTest();
    }
    static testMethod void oneInProgressOneNotStarted_Test() {
		User_Story__c userStory01 = new User_Story__c(Name = 'oneInProgressOneNotStarted_Test', Status__c = 'Not Started');
		insert userStory01;

		List<User_Story_Task__c> listUserStoryTasks = new List<User_Story_Task__c>();
		User_Story_Task__c usTask01 = new User_Story_Task__c(User_Story__c = userStory01.Id,
										Name = 'oneInProgressOneNotStarted_Test', Status__c = 'Not Started',
										Estimated_Hours__c = 23);
		listUserStoryTasks.add(usTask01);
		User_Story_Task__c usTask02 = new User_Story_Task__c(User_Story__c = userStory01.Id,
										Name = 'oneInProgressOneNotStarted_Test', Status__c = 'In Progress',
										Estimated_Hours__c = 23);
		listUserStoryTasks.add(usTask02);
		insert listUserStoryTasks;

		Test.startTest();
		usTask01.Status__c = 'In Progress';
		update usTask01;

		User_Story__c userStoryCheck = [SELECT Id, Status__c FROM User_Story__c WHERE Id = :userStory01.Id];
		System.assert(userStoryCheck.Status__c == 'In Progress', 'US status SHOULD be _In Progress_');
		Test.stopTest();
    }
}