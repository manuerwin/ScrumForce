public with sharing class VirtualWall_VfExt {

    public VirtualWall_VfExt() {}
    public VirtualWall_VfExt(ApexPages.StandardController controller) {}

    public List<WorkAndTasks> listWorkAndTasks {
        get {
            if (listWorkAndTasks == null) {
                // TODO: filter this by the target sprint
                for (Work__c oneWork : [SELECT Id, Name, (SELECT Id, Name, Description__c FROM Work_Tasks__r)
                            			FROM Work__c] ) {
                	WorkAndTasks oneWorkAndTasks = new WorkAndTasks();
                	//List<Work_Task__c> listTasksNotStarted = new List<Work_Task__c>();
                	//List<Work_Task__c> listTasksInProgress = new List<Work_Task__c>();
                	//List<Work_Task__c> listTasksDone = new List<Work_Task__c>();
/*
					oneWorkAndTasks.theWork = oneWork;
					for (Work_Task__c oneWorkTask : oneWork) {
						if (oneWorkTask.Status == 'Not Started') {
							oneWorkAndTasks.listTasksToDo.add(oneWorkTask);
						} else if (oneWorkTask.Status == 'In Progress') {
							oneWorkAndTasks.listTasksDoing.add(oneWorkTask);
						} else if (oneWorkTask.Status == 'Done') {
							oneWorkAndTasks.listTasksDone.add(oneWorkTask);
						}
					}
*/
                }
            }
            return listWorkAndTasks;
        }
        set;
    }
}