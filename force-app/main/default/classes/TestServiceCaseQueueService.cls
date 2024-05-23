@isTest
private class TestServiceCaseQueueService {

    @TestSetup
    static void dataCreation() {
        TestFactory.getUserAndCases();
        TestFactory.getUsersAndCasesAndQueues();
    }
	
    @isTest
    static void testGetUserCasesHandlerPriority() {

        User testUser = [SELECT Id FROM User WHERE Name = 'Tester' LIMIT 1];
        
        System.runAs(testUser) {
            Test.startTest();
            List<Case> result = ServiceCaseQueueService.getUserCases();
            List<Case> resultNonCacheable = ServiceCaseQueueService.getUserCasesNonCacheable();
            Test.stopTest();
            
            System.assertEquals(2, result.size(), 'Expected 2 case');
            System.assertEquals(result, resultNonCacheable, 'Methods should work correctly');
            
            Case firstCase = result[0];
            System.assertEquals('High', firstCase.Priority, 'Priority does not match');

            Case secondCase = result[1];
            System.assertEquals('Medium', secondCase.Priority, 'Priority does not match');
        }
    }

    @isTest
    static void testGetUserCasesHandlerOrderByOwner() {

        User testUser = [SELECT Id FROM User WHERE Name = 'Smith' LIMIT 1];

        System.runAs(testUser) {
            Test.startTest();
            List<Case> result = ServiceCaseQueueService.getUserCases();
            List<Case> resultNonCacheable = ServiceCaseQueueService.getUserCasesNonCacheable();
            Test.stopTest();

            System.assertEquals(18, result.size(), 'Expected 18 case');

            Case firstCase = result[0];
            System.assertEquals('Smith', firstCase.Owner.Name, 'ORDER BY doesn\'t work properly');

            Case secondCase = result[9];
            System.assertEquals('Bradley', secondCase.Owner.Name, 'ORDER BY doesn\'t work properly');
        }
    }
    
    @isTest
    static void testGetQueuesForUser() {

        User testUser = [SELECT Id FROM User WHERE Name = 'Smith' LIMIT 1];
        Group testGroup = [SELECT Id FROM Group WHERE Name = 'Test Queue' LIMIT 1];
        List<GroupMember> groupMembers = [SELECT UserOrGroupId FROM GroupMember WHERE GroupId = :testGroup.Id];
        
        System.runAs(testUser) {
            Test.startTest();
            Set<String> result = new Set<String>(ServiceCaseQueueService.getQueuesForUser(testUser.Id));
            Test.stopTest();
            
            System.assertEquals(2, result.size(), 'Expected 2 queue Id');

            Set<String> groupMembersId = new Set<String>();
            for (GroupMember gm : groupMembers) {
                groupMembersId.add(gm.UserOrGroupId);
            }
            System.assertEquals(groupMembersId, result, 'Queue Id does not match');
        }
    }

    @isTest
    static void testGetStatusPicklistValues() {

        List<Schema.PicklistEntry> picklistEntries = new List<Schema.PicklistEntry>();
        Schema.DescribeFieldResult fieldDescribe = Case.Status.getDescribe();
        picklistEntries = fieldDescribe.getPicklistValues();

        Test.startTest();
        List<String> result = ServiceCaseQueueService.getStatusPicklistValues();
        Test.stopTest();

        System.assertEquals(picklistEntries.size(), result.size(), 'Expected number of picklist values do not match');
        for (Integer i = 0; i < picklistEntries.size(); i++) {
            System.assertEquals(picklistEntries[i].getValue(), result[i], 'Picklist value does not match');
        }
    }

    @isTest
    static void testPositiveUpdateStatus() {

        Case testCase = new Case(Subject = 'Test Case', Status = 'New');
        insert testCase;
        
        Test.startTest();
        ServiceCaseQueueService.updateStatus('Closed', testCase.Id);
        Test.stopTest();
        
        Case updatedCase = [SELECT Id, Status FROM Case WHERE Id =: testCase.Id];
        System.assertEquals('Closed', updatedCase.Status, 'Case status was not updated successfully');
    }

    @isTest
    static void testNegativeUpdateStatus() {

        Case testCase = new Case(Subject = 'Test Case', Status = 'New');
        insert testCase;

        try {
            ServiceCaseQueueService.updateStatus('Closed', null);
            System.assert(false, 'Exception should have been thrown for null caseId');
        } catch (Exception e) {
            System.assert(e.getMessage().contains('List has no rows for assignment to SObject'), 'Incorrect exception message for null caseId');
        }
        
        try {
            ServiceCaseQueueService.updateStatus('Closed', '001aj00000GqTeDAAV');
            System.assert(false, 'Exception should have been thrown for unexisting caseId');
        } catch (Exception e) {
            System.assert(e.getMessage().contains('List has no rows for assignment to SObject'), 'Incorrect exception message for unexisting caseId');
        }
    }
}