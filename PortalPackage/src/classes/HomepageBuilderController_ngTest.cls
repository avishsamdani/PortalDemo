@isTest
private class HomepageBuilderController_ngTest {
    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        Homepage_Widget_Layout__c hwl=new Homepage_Widget_Layout__c();
		hwl.Name='testLayoutDante';
		hwl.Displaying_Application_Status__c='Inquiry';
		insert hwl;
        
        ngForceController ngcon=new ngForceController();
        HomepageBuilderController_ng con=new HomepageBuilderController_ng(ngcon);
    }
}