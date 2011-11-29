@isTest
private class SprintBurndownNightlyRollup_Test {
	static testMethod void moreThan200WorksPerSprintTest() {
		// What if there are more than 200 Work records for the Sprint? i.e., >Batch context
		// The Sprint Burndown should only be created once.
		Sprint__c sprint01 = new Sprint__c (Name = 'moreThan200WorksPerSprintTest',
								Status__c = 'In Progress',
								Start_Date__c = System.today().addDays(-2),
								End_Date__c = System.today().addDays(+2));
		insert sprint01;

		List<Work__c> listWorks = new List<Work__c>();
		for (Integer intCounter = 0; intCounter < 300; intCounter++) {
			Work__c work = new Work__c(Name = 'moreThan200WorksPerSprintTest-' + intCounter,
							Sprint__c = sprint01.Id,
							Status__c = 'In Progress',
							Story_Points__c = 2);
		}

		insert listWorks;

		Test.startTest();
			SprintBurndownNightlyRollup sch = new SprintBurndownNightlyRollup();
			Database.executeBatch(sch);
		Test.stopTest();

		List<Sprint_Burndown__c> listSprintBurns =	[SELECT Id, Sprint__c
													FROM Sprint_Burndown__c
													WHERE Sprint__c = :sprint01.Id];
		System.assert(listSprintBurns.size() == 0, 'There should be only one Sprint Burndown');
	}

	static testMethod void closedWorksShouldBeIgnoredTest() {
	}

	static testMethod void inProgressAndNotStartedWorksShouldBeProcessedTest() {
	}
}