public with sharing class testingPageLinking {
	public static List<Erx_Page__c> pages = new List<Erx_Page__c>();
    private static Map<Integer, String> pageOrderMap = null;
    private static Map<Integer, String> customPagesMap = null;
    public static List<Erx_Section__c> sectionList = new  List<Erx_Section__c>();
    public static Id pId = null;
    public static String pageName = null;
    public HtmlPage objPage {get;set;}
    
    public void initPageLoad() {
        try {            
            IPageBuilder buildPage = new PageBuilder(); 
            buildPage.getRawPageData();	
            objPage = buildPage.getFinalPage();
            objPage.nextPageId = 'a0X61000001Rz2tEAC';
            system.debug(objPage);
        } catch (Exception e) { 
            ERx_PortalPackUtil.logException(e);
        }
    }
    
    @RemoteAction
    public static Id test() {      	
        pages = [Select Name, Id, Page_Name__c, IsActive__c, Order__c From Erx_Page__c where IsActive__c = true order by Order__c];     
        system.debug(pages);
        Integer i = 1;
        pageOrderMap = new Map<Integer, String>();
            for(Erx_Page__c page : pages) {
                pageOrderMap.put(i, page.Id);
                i++;
            }
        system.debug(pageOrderMap);
        for(String pageIds : pageOrderMap.values()) {
            pid = pageIds;
        }
        return pid;
    }  
}