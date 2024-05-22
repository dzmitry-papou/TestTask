public without sharing class AccountCasesPdfCtrl {

    public static List<Case> getAccountCasesPrevWeek() {
        Date startDate = Date.today().toStartOfWeek().addDays(-7);
        Date endDate = startDate.addDays(7);
        
        List<Case> cases = [SELECT Account.Name, Account.Owner.Name, CaseNumber, Status, Priority, Origin
                            FROM Case
                            WHERE CreatedDate >= :startDate AND CreatedDate < :endDate
                            ORDER BY Account.Name];
        
        return cases;
    }
}