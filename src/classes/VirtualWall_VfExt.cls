public with sharing class VirtualWall_VfExt {

    public VirtualWall_VfExt() {
    }

    public VirtualWall_VfExt(ApexPages.StandardController controller) {
    }

    public List<Work__c> listWorks {
        get {
            if (listWorks == null) {
                listWorks = [SELECT Id, Name,
                                (SELECT Id, Name
                                FROM Work_Tasks__r)
                            FROM Work__c];
            }
            return listWorks;
        }
        set;
    }
}