@isTest
private class UserStoryTasksToGrandParents_Test {

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
}