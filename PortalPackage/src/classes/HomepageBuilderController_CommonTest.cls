@isTest
private class HomepageBuilderController_CommonTest {
    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        
        Homepage_Widget_Layout__c hwl=new Homepage_Widget_Layout__c();
		hwl.Name='testLayoutDante';
		hwl.Displaying_Application_Status__c='Inquiry';
		insert hwl;
        
        ApexPages.currentPage().getParameters().put('id',hwl.Id);
        ngForceController ngcon=new ngForceController();
        HomepageBuilderController_Common con=new HomepageBuilderController_Common(ngcon);
    }
}