public with sharing class ServiceCaseQueueService {

    @AuraEnabled(cacheable=true)
    public static List<Case> getUserCases() {
        
        return getUserCasesHandler();
    }

    @AuraEnabled
    public static List<Case> getUserCasesNonCacheable() {
        
        return getUserCasesHandler();
    }

    private static List<Case> getUserCasesHandler() {

        String currentUserId = UserInfo.getUserId();
        List<String> currentUserQueues = getQueuesForUser(currentUserId);
        return [
            SELECT Id, CaseNumber, Owner.Name, Status, Priority, Origin, IsOwner__c
            FROM Case
            WHERE
            (
                OwnerId = :currentUserId OR
                OwnerId IN :currentUserQueues
            )
            ORDER BY IsOwner__c DESC, Owner.Name ASC, Priority ASC, CreatedDate DESC
            LIMIT 25
        ];
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getStatusPicklistValues() {

        List<String> picklistValues = new List<String>();
        Schema.DescribeFieldResult fieldDescribe = Case.Status.getDescribe();
        List<Schema.PicklistEntry> picklistEntries = fieldDescribe.getPicklistValues();
        for (Schema.PicklistEntry picklistEntry : picklistEntries) {
            picklistValues.add(picklistEntry.getValue());
        }
        return picklistValues;
    }

    @AuraEnabled
    public static void updateStatus(String newStatus, String caseId) {

        Case caseToUpdate = [SELECT Id, Status FROM Case WHERE Id =: caseId];
        caseToUpdate.Status = newStatus;
        update caseToUpdate;
    }

    @TestVisible
    private static List<String> getQueuesForUser(String currentUserId) {

        String currentUser = currentUserId;
        List<String> queueIds = new List<String>();
        List<Group> groups = [
            SELECT Id 
            FROM Group 
            WHERE Type = 'Queue' 
            AND Id IN (
                SELECT GroupId FROM GroupMember WHERE UserOrGroupId = :currentUser
            )
        ];
        for (GroupMember qm : [SELECT UserOrGroupId FROM GroupMember WHERE GroupId IN :groups]) {
            queueIds.add(qm.UserOrGroupId);
        }
        return queueIds;
    }
}