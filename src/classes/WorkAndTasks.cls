public class WorkAndTasks {
    // TODO: move this into VirtualWallWork_VfExt
    Work__c theWork;
    List<Work_Task__c> listTasksToDo;
    List<Work_Task__c> listTasksDoing;
    List<Work_Task__c> listTasksDone;

	// Constructor
	public WorkAndTasks() {
		listTasksToDo = new List<Work_Task__c>();
		listTasksDoing = new List<Work_Task__c>();
		listTasksDone = new List<Work_Task__c>();
	}
}