public without sharing class PrioritisationAssignUserStory_VfExt {

    public PrioritisationAssignUserStory_VfExt(ApexPages.StandardController stdController) {}

    public List<User_Story__c> listStoriesUnassigned {
        get {
            if (listStoriesUnassigned == null) {
                listStoriesUnassigned = [SELECT Id, Name
                                    FROM User_Story__c
                                    ORDER BY Rank__c];
            }
            return listStoriesUnassigned;
        }
        set;
    }

    @RemoteAction
    public static Boolean updateUserStories (String strKeyValuePairs) {
        Boolean bolSuccess = false;
        System.debug(System.LoggingLevel.DEBUG, 'strKeyValuePairs: ' + strKeyValuePairs);
        // Split on & to get key/value pairs
        List<String> listKeyValuePairs = strKeyValuePairs.split('&');
        System.debug(System.LoggingLevel.DEBUG, 'listKeyValuePairs: ' + listKeyValuePairs);
        
        Set<Id> setUserStoryIds = new Set<Id>();
        Map<Id, Id> mapStoryIdToSprintId = new Map<Id, Id>();
        Map<Id, Integer> mapTaskIdToRank = new Map<Id, Integer>();

        // ASSUMPTION: format is sprintId~userStoryId[]=taskId by this point
        //	e.g., a0p60000000MTzn~a0d60000000vKjf[]=a0o600000026wDB
        Integer intCounter = 1;
        for (String strKeyValuePair : listKeyValuePairs) {
            System.debug(System.LoggingLevel.DEBUG, 'strKeyValuePair: ' + strKeyValuePair);
			Integer intLocationOfTilde = strKeyValuePair.indexOf('~');
            Integer intLocationOfEquals = strKeyValuePair.indexOf('=');
            System.debug(System.LoggingLevel.DEBUG, 'intLocationOfEquals: ' + intLocationOfEquals);
			Id sprintId = strKeyValuePair.substring(0, intLocationOfTilde);
            System.debug(System.LoggingLevel.DEBUG, 'sprintId: ' + sprintId);
            String strUserStoryId = strKeyValuePair.substring(intLocationOfEquals + 1);
            System.debug(System.LoggingLevel.DEBUG, 'strUserStoryId: ' + strUserStoryId);
            setUserStoryIds.add(strUserStoryId);
			mapStoryIdToSprintId.put(strUserStoryId, sprintId);
            mapTaskIdToRank.put(strUserStoryId, intCounter);
            intCounter++;
        }
        
        List<User_Story__c> listUserStoriesToUpdate = new List<User_Story__c>();
        // Query for UserStory records
        for (User_Story__c oneUserStory : [SELECT Id, Rank__c
                                    FROM User_Story__c
                                    WHERE Id IN :setUserStoryIds]) {
            // for each User Story apply the rank from the map and set the parent Sprint 
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