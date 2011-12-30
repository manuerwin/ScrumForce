public without sharing class PrioritisationAssignUserStory_VfExt {

    public PrioritisationAssignUserStory_VfExt(ApexPages.StandardController stdController) {
    }

    public List<User_Story__c> listUserStoriesUnassigned {
        get {
            if (listUserStoriesUnassigned == null) {
                listUserStoriesUnassigned = [SELECT Id, Name
                                    FROM User_Story__c
                                    ORDER BY Sprint__c];
            }
            return listUserStoriesUnassigned;
        }
        set;
    }

    @RemoteAction
    public static Boolean updateuserStories (String strKeyValuePairs) {
        // TODO: Handle errors with the DML and return false to force a revert
        Boolean bolSuccess = false;
        System.debug(System.LoggingLevel.DEBUG, 'strKeyValuePairs: ' + strKeyValuePairs);
        // Split on & to get key/value pairs
        List<String> listKeyValuePairs = strKeyValuePairs.split('&');
        System.debug(System.LoggingLevel.DEBUG, 'listKeyValuePairs: ' + listKeyValuePairs);
        
        Set<Id> setUserStoryIds = new Set<Id>();
        Map<Id, String> mapTaskIdToStatus = new Map<Id, String>();
        Map<Id, Integer> mapTaskIdToRank = new Map<Id, Integer>();

        // ASSUMPTION: format is status~userStoryId[]=taskId by this point e.g., done~a0d60000000vKjfAAE[]=a0o600000026wD8AAI
        Integer intCounter = 1;
        for (String strKeyValuePair : listKeyValuePairs) {
            System.debug(System.LoggingLevel.DEBUG, 'strKeyValuePair: ' + strKeyValuePair);
            Integer intLocationOfTilde = strKeyValuePair.indexOf('~');
            Integer intLocationOfEquals = strKeyValuePair.indexOf('=');
            String strStatus = strKeyValuePair.substring(0, intLocationOfTilde);
            String strTaskId = strKeyValuePair.substring(intLocationOfEquals + 1);
            setUserStoryIds.add(strTaskId);
            mapTaskIdToStatus.put(strTaskId, strStatus);
            mapTaskIdToRank.put(strTaskId, intCounter);
            intCounter++;
        }
        
        List<User_Story__c> listUserStoriesToUpdate = new List<User_Story__c>();
        // Query for UserStory records
        for (User_Story__c oneUserStory : [SELECT Id, Rank__c
                                    FROM User_Story__c
                                    WHERE Id IN :setUserStoryIds]) {
            // for each User Story apply the rank from the map
            oneUserStory.Rank__c = mapTaskIdToRank.get(oneUserStory.Id);
            listUserStoriesToUpdate.add(oneUserStory);
        }
        
        // Update all User Story records
        System.debug(System.LoggingLevel.DEBUG, 'listUserStoriesToUpdate before update: ' + listUserStoriesToUpdate);
        update listUserStoriesToUpdate;
        bolSuccess = true;
        return bolSuccess;
    }
}