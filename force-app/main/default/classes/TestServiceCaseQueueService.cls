@isTest(SeeAllData=true)
private class TestServiceCaseQueueService {
	
    @isTest
    static void testGetUserCasesHandler() {

        User testUser = [SELECT Id FROM User WHERE IsActive = true LIMIT 1];
        
        Case testCase1 = new Case(
            Status = 'Working',
            Priority = 'Medium',
            Origin = 'Web',
            OwnerId = testUser.Id
        );
        Case testCase2 = new Case(
            Status = 'Closed',
            Priority = 'Low',
            Origin = 'Email'
        );
        Case testCase3 = new Case(
            Status = 'New',
            Priority = 'High',
            Origin = 'Phone',
            OwnerId = testUser.Id
        );
        insert new List<Case>{testCase1, testCase2, testCase3};
        
        System.runAs(testUser) {
            Test.startTest();
            List<Case> result = ServiceCaseQueueService.getUserCases();
            List<Case> resultNonCacheable = ServiceCaseQueueService.getUserCasesNonCacheable();
            Test.stopTest();
            
            System.assertEquals(2, result.size(), 'Expected 2 case');
            System.assertEquals(result, resultNonCacheable, 'Methods should work correctly');
            
            Case firstCase = result[0];
            System.assertEquals('New', firstCase.Status, 'Status does not match');
            System.assertEquals('High', firstCase.Priority, 'Priority does not match');
            System.assertEquals('Phone', firstCase.Origin, 'Origin does not match');
            System.assertEquals(true, firstCase.IsOwner__c, 'IsOwner__c does not match');
            System.assertEquals(testUser.Id, firstCase.OwnerId, 'Owner Id does not match');

            Case secondCase = result[1];
            System.assertEquals('Working', secondCase.Status, 'Status does not match');
            System.assertEquals('Medium', secondCase.Priority, 'Priority does not match');
            System.assertEquals('Web', secondCase.Origin, 'Origin does not match');
            System.assertEquals(true, secondCase.IsOwner__c, 'IsOwner__c does not match');
            System.assertEquals(testUser.Id, secondCase.OwnerId, 'Owner Id does not match');
        }
    }
    
    @isTest
    static void testGetQueuesForUser() {

        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u1 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.comaSARJHGF'
        );
        User u2 = new User(Alias = 'standt12', Email='standarduser@testorg.c43om', 
            EmailEncodingKey='UTF-8', LastName='Testing54', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.comaSARJH78GF'
        );
        insert new List<User>{u1, u2};
        
        Group testGroup = new Group(
            Name = 'Test Queue',
            Type = 'Queue'
        );
        insert testGroup;
        
        GroupMember testGroupMember1 = new GroupMember(
            GroupId = testGroup.Id,
            UserOrGroupId = u1.Id
        );
        GroupMember testGroupMember2 = new GroupMember(
            GroupId = testGroup.Id,
            UserOrGroupId = u2.Id
        );
        insert new List<GroupMember>{testGroupMember1, testGroupMember2};
        
        System.runAs(u1) {
            Test.startTest();
            Set<String> result = new Set<String>(ServiceCaseQueueService.getQueuesForUser(u1.Id));

            Test.stopTest();
            
            System.assertEquals(2, result.size(), 'Expected 2 queue Id');
            System.assertEquals(new Set<String>{testGroupMember1.UserOrGroupId, testGroupMember2.UserOrGroupId}, result, 'Queue Id does not match');
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
    static void testUpdateStatus() {
        Case testCase = new Case(Subject = 'Test Case', Status = 'New');
        insert testCase;
        
        Test.startTest();
        ServiceCaseQueueService.updateStatus('Closed', testCase.Id);
        Test.stopTest();
        
        
        Case updatedCase = [SELECT Id, Status FROM Case WHERE Id =: testCase.Id];
        System.assertEquals('Closed', updatedCase.Status, 'Case status was not updated successfully');
    }
}