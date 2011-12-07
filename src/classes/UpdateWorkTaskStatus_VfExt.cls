public with sharing class UpdateWorkTaskStatus_VfExt {

    public UpdateWorkTaskStatus_VfExt(ApexPages.StandardController controller) {
    }

    public List<Work_Task__c> listWorkTasks {
        get {
            if (listWorkTasks == null) {
                listWorkTasks = [SELECT Id, Name
                                FROM Work_Task__c
                                WHERE Work__c = 'a0d60000000u8KJ'];
            }
            return listWorkTasks;
        }
        set;
    }
}