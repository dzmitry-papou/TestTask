@isTest
public class TestFactory {

    public static void getUserAndCases() {

        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];

        User testUser = new User(Alias = 'teste', Email='tester@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Tester', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='d.papou@farm.tester'
        );
        insert testUser;

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
    }

    public static void getUsersAndCasesAndQueues() {
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];

        List<User> users = new List<User>();
        User testUser1 = new User(Alias = 'smith', Email='smith@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Smith', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='d.papou@farm.smith'
        );
        users.add(testUser1);
        User testUser2 = new User(Alias = 'bradl', Email='bradley@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Bradley', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='d.papou@farm.bradley'
        );
        users.add(testUser2);
        User testUser3 = new User(Alias = 'moria', Email='moriarty@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Moriarty', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='d.papou@farm.moriarty'
        );
        users.add(testUser3);
        insert users;

        List<Case> cases = new List<Case>();
        for (User caseOwner : users) {
            for (Integer i = 0; i < 3; i++) {
                cases.add(
                    new Case(
                        Status = 'Working',
                        Priority = 'Medium',
                        Origin = 'Phone',
                        OwnerId = caseOwner.Id
                    )
                );
                cases.add(
                    new Case(
                        Status = 'New',
                        Priority = 'Low',
                        Origin = 'Email',
                        OwnerId = caseOwner.Id
                    )
                );
                cases.add(
                    new Case(
                        Status = 'New',
                        Priority = 'High',
                        Origin = 'Web',
                        OwnerId = caseOwner.Id
                    )
                );
            }
        }
        insert cases;

        getGroupMembers(testUser1.Id, testUser2.Id);
    }

    @future
    public static void getGroupMembers(Id us1, Id us2) {
        Group testGroup = new Group(
            Name = 'Test Queue',
            Type = 'Queue'
        );
        insert testGroup;
        
        GroupMember testGroupMember1 = new GroupMember(
            GroupId = testGroup.Id,
            UserOrGroupId = us1
        );
        GroupMember testGroupMember2 = new GroupMember(
            GroupId = testGroup.Id,
            UserOrGroupId = us2
        );
        insert new List<GroupMember>{testGroupMember1, testGroupMember2};
    }
}