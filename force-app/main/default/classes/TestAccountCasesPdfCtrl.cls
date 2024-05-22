@isTest
private class TestAccountCasesPdfCtrl {

    @isTest
    static void testGetAccountCasesPrevWeek() {
        Account testAccount = new Account(Name='Test Account');
        insert testAccount;
        
        Case testCase1 = new Case(AccountId=testAccount.Id, Status='New', Priority='High', Origin='Phone');
        Case testCase2 = new Case(AccountId=testAccount.Id, Status='Closed', Priority='Low', Origin='Email');
        
        insert new List<Case>{testCase1, testCase2};
            
        
        Test.setCreatedDate(testCase1.Id, DateTime.newInstance(Date.today().addDays(-7), Time.newInstance(12, 0, 0, 0)));
        Test.setCreatedDate(testCase2.Id, DateTime.newInstance(Date.today(), Time.newInstance(12, 0, 0, 0)));
        
        Test.startTest();
        List<Case> result = AccountCasesPdfCtrl.getAccountCasesPrevWeek();
        Test.stopTest();
        
        // Verify the results
        System.assertEquals(1, result.size(), 'Expected 1 case');
        
        Case retrievedCase = result[0];
        System.assertEquals(testAccount.Name, retrievedCase.Account.Name, 'Account Name does not match');
        System.assertEquals('New', retrievedCase.Status, 'Status does not match');
        System.assertEquals('High', retrievedCase.Priority, 'Priority does not match');
        System.assertEquals('Phone', retrievedCase.Origin, 'Origin does not match');
    }
}