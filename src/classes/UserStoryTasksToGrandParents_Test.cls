@isTest
private class UserStoryTasksToGrandParents_Test {

	// ASSOCIATE User Story Task TO GRANDPARENT SPRINT on INSERT
    static testMethod void sprintIsAndNotPopulated_Test() {
        Sprint__c sprint01 = new Sprint__c();
        sprint01.Name = 'sprintIsAndNotPopulated_Test';
        sprint01.Start_Date__c = System.today().addDays(-5);
        sprint01.End_Date__c = System.today().addDays(5);
        sprint01.Status__c = 'Not Started';
        insert sprint01;

        List<User_Story__c> listUserStories = new List<User_Story__c>();
        User_Story__c userStory01 = new User_Story__c();
        userStory01.Name = 'no sprint';
        userStory01.Story_Points__c = 13;
        listUserStories.add(userStory01);
        User_Story__c userStory02 = new User_Story__c();
        userStory02.Name = 'have a sprint';
        userStory02.Story_Points__c = 13;
        userStory02.Sprint__c = sprint01.Id;
        listUserStories.add(userStory02);
        insert listUserStories;

        Test.startTest();
        List<User_Story_Task__c> listUserStoryTasks = new List<User_Story_Task__c>();
        for (Integer intCounter = 0; intCounter < 300; intCounter++) {
            User_Story_Task__c userStoryTask = new User_Story_Task__c();
            userStoryTask.Description__c = String.valueOf(intCounter);
            userStoryTask.Estimated_Hours__c = (intCounter + 1) / 30;

            if (System.Math.mod(intCounter, 2) == 0) {
                userStoryTask.User_Story__c = userStory02.Id;
            }
            listUserStoryTasks.add(userStoryTask);
        }
        insert listUserStoryTasks;

        User_Story_Task__c userStoryTaskHasSprint = [SELECT Id, Sprint__c
                                                    FROM User_Story_Task__c
                                                    WHERE Id = :listUserStoryTasks[0].Id];
        System.assert(userStoryTaskHasSprint.Sprint__c == sprint01.Id, 'The sprint should be the grandparent');
        Test.stopTest();
    }
	// Ensure User Story Task associated to grandparent Sprint on User Story Update
	static testMethod void userStorySprintValueToValue_Test() {
        List<Sprint__c> listSprints = new List<Sprint__c>();
        Sprint__c sprint01 = new Sprint__c();
        sprint01.Name = 'userStorySprintValueToValue_Test - 1';
        sprint01.Start_Date__c = System.today().addDays(-5);
        sprint01.End_Date__c = System.today().addDays(5);
        sprint01.Status__c = 'In Progress';
        listSprints.add(sprint01);
        Sprint__c sprint02 = new Sprint__c();
        sprint02.Name = 'userStorySprintValueToValue_Test - 2';
        sprint02.Start_Date__c = System.today().addDays(-5);
        sprint02.End_Date__c = System.today().addDays(5);
        sprint02.Status__c = 'In Progress';
        listSprints.add(sprint02);

        Sprint__c sprint03 = new Sprint__c();
        sprint03.Name = 'userStorySprintValueToValue_Test - 3';
        sprint03.Start_Date__c = System.today().addDays(-5);
        sprint03.End_Date__c = System.today().addDays(5);
        sprint03.Status__c = 'In Progress';
        listSprints.add(sprint03);
        Sprint__c sprint04 = new Sprint__c();
        sprint04.Name = 'userStorySprintValueToValue_Test - 4';
        sprint04.Start_Date__c = System.today().addDays(-5);
        sprint04.End_Date__c = System.today().addDays(5);
        sprint04.Status__c = 'In Progress';
        listSprints.add(sprint04);
        insert listSprints;
		
		List<User_Story__c> listUserStories = new List<User_Story__c>();
		for (Integer intCounter = 0; intCounter < 300; intCounter++) {
	        User_Story__c userStory = new User_Story__c();
	        userStory.Name = 'value to value: ' + intCounter;
	        userStory.Story_Points__c = (intCounter + 1) / 30;
            if (System.Math.mod(intCounter, 2) == 0) {
                userStory.Sprint__c = sprint01.Id;
            } else {
                userStory.Sprint__c = sprint02.Id;
            }
	        listUserStories.add(userStory);
		}
		insert listUserStories;

        List<User_Story_Task__c> listUserStoryTasks = new List<User_Story_Task__c>();
        for (Integer intCounter = 0; intCounter < 300; intCounter++) {
            User_Story_Task__c userStoryTask = new User_Story_Task__c();
            userStoryTask.Name = String.valueOf(intCounter);
            userStoryTask.Description__c = String.valueOf(intCounter);
            userStoryTask.Estimated_Hours__c = (intCounter + 1) / 30;
            userStoryTask.User_Story__c = listUserStories[intCounter].Id;
            listUserStoryTasks.add(userStoryTask);
        }
        insert listUserStoryTasks;

        Test.startTest();
        for (Integer intCounter = 0; intCounter < 300; intCounter++) {
        	User_Story__c userStory = listUserStories[intCounter];
            if (System.Math.mod(intCounter, 2) == 0) {
                userStory.Sprint__c = sprint03.Id;
            } else {
                userStory.Sprint__c = sprint04.Id;
            }
        }
        update listUserStories;

		List<User_Story_Task__c> listUserStoryTasksSprint =	[SELECT Id, Sprint__c
																FROM User_Story_Task__c
																WHERE Sprint__c = :sprint04.Id];
        System.assert(listUserStoryTasksSprint.size() == 150, 'There should NOW be 150 Tasks under Sprint 4');
        Test.stopTest();
	}
	static testMethod void userStorySprintBlankToValue_Test() {
        List<Sprint__c> listSprints = new List<Sprint__c>();
        Sprint__c sprint01 = new Sprint__c();
        sprint01.Name = 'userStorySprintBlankToValue_Test - 1';
        sprint01.Start_Date__c = System.today().addDays(-5);
        sprint01.End_Date__c = System.today().addDays(5);
        sprint01.Status__c = 'In Progress';
        listSprints.add(sprint01);
        Sprint__c sprint02 = new Sprint__c();
        sprint02.Name = 'userStorySprintBlankToValue_Test - 2';
        sprint02.Start_Date__c = System.today().addDays(-5);
        sprint02.End_Date__c = System.today().addDays(5);
        sprint02.Status__c = 'In Progress';
        listSprints.add(sprint02);
        insert listSprints;
		
		List<User_Story__c> listUserStories = new List<User_Story__c>();
		for (Integer intCounter = 0; intCounter < 300; intCounter++) {
	        User_Story__c userStory = new User_Story__c();
	        userStory.Name = 'blank to value: ' + intCounter;
	        userStory.Story_Points__c = (intCounter + 1) / 30;
	        listUserStories.add(userStory);
		}
		insert listUserStories;

        List<User_Story_Task__c> listUserStoryTasks = new List<User_Story_Task__c>();
        for (Integer intCounter = 0; intCounter < 300; intCounter++) {
            User_Story_Task__c userStoryTask = new User_Story_Task__c();
            userStoryTask.Name = String.valueOf(intCounter);
            userStoryTask.Description__c = String.valueOf(intCounter);
            userStoryTask.Estimated_Hours__c = (intCounter + 1) / 30;
            userStoryTask.User_Story__c = listUserStories[intCounter].Id;
            listUserStoryTasks.add(userStoryTask);
        }
        insert listUserStoryTasks;

        Test.startTest();
        for (Integer intCounter = 0; intCounter < 300; intCounter++) {
        	User_Story__c userStory = listUserStories[intCounter];
            if (System.Math.mod(intCounter, 2) == 0) {
                userStory.Sprint__c = sprint01.Id;
            } else {
                userStory.Sprint__c = sprint02.Id;
            }
        }
        update listUserStories;

		List<User_Story_Task__c> listUserStoryTasksSprint =	[SELECT Id, Sprint__c
																FROM User_Story_Task__c
																WHERE Sprint__c = :sprint01.Id];
        System.assert(listUserStoryTasksSprint.size() == 150, 'There should NOW be 150 Tasks under Sprint 1');
        Test.stopTest();
	}
	static testMethod void userStorySprintValueToBlank_Test() {
		List<Sprint__c> listSprints = new List<Sprint__c>();
        Sprint__c sprint01 = new Sprint__c();
        sprint01.Name = 'userStorySprintValueToValue_Test - 1';
        sprint01.Start_Date__c = System.today().addDays(-5);
        sprint01.End_Date__c = System.today().addDays(5);
        sprint01.Status__c = 'In Progress';
        listSprints.add(sprint01);
        Sprint__c sprint02 = new Sprint__c();
        sprint02.Name = 'userStorySprintValueToValue_Test - 2';
        sprint02.Start_Date__c = System.today().addDays(-5);
        sprint02.End_Date__c = System.today().addDays(5);
        sprint02.Status__c = 'In Progress';
        listSprints.add(sprint02);
        insert listSprints;
		
		List<User_Story__c> listUserStories = new List<User_Story__c>();
		for (Integer intCounter = 0; intCounter < 300; intCounter++) {
	        User_Story__c userStory = new User_Story__c();
	        userStory.Name = 'value to value: ' + intCounter;
	        userStory.Story_Points__c = (intCounter + 1) / 30;
            if (System.Math.mod(intCounter, 2) == 0) {
                userStory.Sprint__c = sprint01.Id;
            } else {
                userStory.Sprint__c = sprint02.Id;
            }
	        listUserStories.add(userStory);
		}
		insert listUserStories;

        List<User_Story_Task__c> listUserStoryTasks = new List<User_Story_Task__c>();
        for (Integer intCounter = 0; intCounter < 300; intCounter++) {
            User_Story_Task__c userStoryTask = new User_Story_Task__c();
            userStoryTask.Name = String.valueOf(intCounter);
            userStoryTask.Description__c = String.valueOf(intCounter);
            userStoryTask.Estimated_Hours__c = (intCounter + 1) / 30;
            userStoryTask.User_Story__c = listUserStories[intCounter].Id;
            listUserStoryTasks.add(userStoryTask);
        }
        insert listUserStoryTasks;

        Test.startTest();
        for (Integer intCounter = 0; intCounter < 300; intCounter++) {
        	User_Story__c userStory = listUserStories[intCounter];
            userStory.Sprint__c = null;
        }
        update listUserStories;

		List<User_Story_Task__c> listUserStoryTasksSprint =	[SELECT Id, Sprint__c
																FROM User_Story_Task__c
																WHERE Sprint__c = :sprint01.Id];
        System.assert(listUserStoryTasksSprint.size() == 0, 'There should NOW be 0 Tasks under Sprint 1');
        Test.stopTest();
	}
}