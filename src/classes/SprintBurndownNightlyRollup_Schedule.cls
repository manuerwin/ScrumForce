global class SprintBurndownNightlyRollup_Schedule implements Schedulable {
	global void execute(SchedulableContext SC) {
		SprintBurndownNightlyRollup sprintBurnBatch = new SprintBurndownNightlyRollup();
		Database.executeBatch(sprintBurnBatch);
	}
}