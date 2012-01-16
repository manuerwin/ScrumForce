@isTest
private class AddUserStoryTasksToGrandParents_Test {

    static testMethod void sprintIsAndNotPopulated_Test() {
        Sprint__c sprint01 = new Sprint__c();
        sprint01.Name = 'sprintIsAndNotPopulated_Test';
        sprint01.Start_Date__c = System.today().addDays(-5);
        sprint01.End_Date__c = System.today().addDays(5);
        sprint01.Status__c = 'Not Started';
        insert sprint01;

		List<User_Story__c> listUserStories = new List<User_Story__c>();
		
        
        List<User_Story_Task__c> listUserStoryTasks = new List<User_Story_Task__c>();
        for (Integer intCounter = 0; intCounter < 300; intCounter++) {
            User_Story_Task__c userStoryTask = new User_Story_Task__c();
            userStoryTask.Description__c = String.valueOf(intCounter);
            userStoryTask.Estimated_Hours__c = intCounter;

            userStoryTask.Sprint__c = sprint01.Id;
        }
        // Purpose: When a User Story Task is created, associate the Sprint lookup field to the grandparent Sprint record.
        
    }
}