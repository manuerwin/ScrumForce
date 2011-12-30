public class StoryAndTasks {
    public User_Story__c theStory {
        get {
            if (theStory == null) {
                theStory = new User_Story__c();
            }
            return theStory;
        }
        set;
    }
    public List<User_Story_Task__c> listTasksToDo {
        get {
            if (listTasksToDo == null) {
                listTasksToDo = new List<User_Story_Task__c>();
            }
            return listTasksToDo;
        }
        set;
    }
    public List<User_Story_Task__c> listTasksDoing {
        get {
            if (listTasksDoing == null) {
                listTasksDoing = new List<User_Story_Task__c>();
            }
            return listTasksDoing;
        }
        set;
    }
    public List<User_Story_Task__c> listTasksVerify {
        get {
            if (listTasksVerify == null) {
                listTasksVerify = new List<User_Story_Task__c>();
            }
            return listTasksVerify;
        }
        set;
    }
    public List<User_Story_Task__c> listTasksDone {
        get {
            if (listTasksDone == null) {
                listTasksDone = new List<User_Story_Task__c>();
            }
            return listTasksDone;
        }
        set;
    }
}