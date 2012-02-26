@isTest
private class SprintBurndown_VfExt_Test {

    static testMethod void noSprintBurndownsExist_Test() {
        Sprint__c sprint = new Sprint__c(Name = 'noSprintBurndownsExist', Status__c = 'In Progress',
        					Start_Date__c = System.today(), End_Date__c = System.today().addDays(30));
        insert sprint;

		Test.startTest();
		Test.setCurrentPage(Page.SprintBurndown);
		// Requery Sprint so that formula field retrieved
		sprint = [SELECT Id, Name, Status__c, Start_Date__c, End_Date__c, Total_Sprint_Days__c FROM Sprint__c WHERE Id = :sprint.Id];
		ApexPages.StandardController controller = new ApexPages.StandardController(sprint);
		SprintBurndown_VfExt sprintBurnCon = new SprintBurndown_VfExt(controller);

		Boolean bolBurndownsExist = sprintBurnCon.sprintBurndownsExist;
		System.assert(!bolBurndownsExist, 'There should be no Sprint Burndowns: ' + bolBurndownsExist);
    }
    static testMethod void sprintBurndownsExist_Test() {
        Sprint__c sprint = new Sprint__c(Name = 'sprintBurndownsExist_Test', Status__c = 'In Progress',
        					Start_Date__c = System.today(), End_Date__c = System.today().addDays(30));
        insert sprint;

		List<Sprint_Burndown__c> listSprintBurndowns = new List<Sprint_Burndown__c>();
		Integer intCountDays = 0;
		for (Integer intCount = 25; intCount > 0; intCount--) {
			Sprint_Burndown__c sprintBurn = new Sprint_Burndown__c(Sprint__c = sprint.Id, Date__c = System.today().addDays(intCountDays),
									Total_Points_Remaining__c = intCount, Total_Hours_Remaining__c = intCount);
			intCountDays++;
			listSprintBurndowns.add(sprintBurn);
		}
		insert listSprintBurndowns;

		Test.startTest();
		Test.setCurrentPage(Page.SprintBurndown);
		// Requery Sprint so that formula field retrieved
		sprint = [SELECT Id, Name, Status__c, Start_Date__c, End_Date__c, Total_Sprint_Days__c FROM Sprint__c WHERE Id = :sprint.Id];
		ApexPages.StandardController controller = new ApexPages.StandardController(sprint);
		SprintBurndown_VfExt sprintBurnCon = new SprintBurndown_VfExt(controller);

		Boolean bolBurndownsExist = sprintBurnCon.sprintBurndownsExist;
		System.assert(bolBurndownsExist, 'There should be Sprint Burndowns: ' + bolBurndownsExist);

		String strHoursRemaining = sprintBurnCon.getHoursRemainingOverTime();
		String strPointsRemaining = sprintBurnCon.getPointsRemainingOverTime();
    }
}