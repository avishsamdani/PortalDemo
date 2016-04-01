public class CurrencyController {
    public Contact con {get;set;}
    
    public CurrencyController() {
        con = [Select Id, Test_Currency__c,Test_Percent__c From Contact where Id = '0036100000JtNji'];
       System.debug(con);
    }
    
    public void saveContact() {
        upsert con;
    }
}