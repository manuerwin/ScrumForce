public class WorkAndTasks {
    public Work__c theWork {
        get {
            if (theWork == null) {
                theWork = new Work__c();
            }
            return theWork;
        }
        set;
    }
    public List<Work_Task__c> listTasksToDo {
        get {
            if (listTasksToDo == null) {
                listTasksToDo = new List<Work_Task__c>();
            }
            return listTasksToDo;
        }
        set;
    }
    public List<Work_Task__c> listTasksDoing {
        get {
            if (listTasksDoing == null) {
                listTasksDoing = new List<Work_Task__c>();
            }
            return listTasksDoing;
        }
        set;
    }
    public List<Work_Task__c> listTasksVerify {
        get {
            if (listTasksVerify == null) {
                listTasksVerify = new List<Work_Task__c>();
            }
            return listTasksVerify;
        }
        set;
    }
    public List<Work_Task__c> listTasksDone {
        get {
            if (listTasksDone == null) {
                listTasksDone = new List<Work_Task__c>();
            }
            return listTasksDone;
        }
        set;
    }
}