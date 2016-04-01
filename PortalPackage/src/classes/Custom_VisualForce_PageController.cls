public class Custom_VisualForce_PageController {
    public Id currentPageId {get;set;}
    public Id nextPageId {get;set;}
    public Id prevPageId {get;set;}
    public Contact student {get;set;}
    
    public Custom_VisualForce_PageController () {
        currentPageId = ApexPages.currentPage().getParameters().get('pageId'); //ApexPages.currentPage.get('pageId');
        student = [Select FirstName, LastName from Contact where id = '0036100000JtNji'];
        nextPageId = PortalPackageHelper.nextPageId(currentPageId);
        prevPageId = PortalPackageHelper.previousPageId(currentPageId);
    }
    
    public void save() {
    	update student;
    }
}