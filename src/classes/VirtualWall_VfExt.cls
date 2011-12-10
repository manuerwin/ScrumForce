public with sharing class VirtualWall_VfExt {

    public VirtualWall_VfExt() {}
    public VirtualWall_VfExt(ApexPages.StandardController controller) {}

    public List<WorkAndTasks> listWorkAndTasks {
        get {
            if (listWorkAndTasks == null) {
			    listWorkAndTasks = new List<WorkAndTasks>();
                // TODO: filter this by the target sprint
                for (Work__c oneWork : [SELECT Id, Name, Work_Number__c, (SELECT Id, Name, Description__c, Status__c
                						FROM Work_Tasks__r)
                            			FROM Work__c] ) {
                	WorkAndTasks oneWorkAndTasks = new WorkAndTasks();
					oneWorkAndTasks.theWork = oneWork;
					for (Work_Task__c oneWorkTask : oneWork.Work_Tasks__r) {
						if (oneWorkTask.Status__c == 'Not Started') {
							oneWorkAndTasks.listTasksToDo.add(oneWorkTask);
						} else if (oneWorkTask.Status__c == 'In Progress') {
							oneWorkAndTasks.listTasksDoing.add(oneWorkTask);
						} else if (oneWorkTask.Status__c == 'Done') {
							oneWorkAndTasks.listTasksDone.add(oneWorkTask);
						}
					}
					listWorkAndTasks.add(oneWorkAndTasks);
                }
            }
            System.debug(System.LoggingLevel.DEBUG, '## DEBUG: listWorkAndTasks before return: ' + listWorkAndTasks);
            return listWorkAndTasks;
        }
        set;
    }
}