public with sharing class HomeWidgetMakerController {
    public HtmlPage objPage {get;set;} 
    public HomeWidgetMakerController() { 
    }
    
    public void initPageLoad() {
        try {
            
            IPageBuilder buildPage = new PageBuilder();  
            if(buildPage.checkIsAuthorized()){
                buildPage.getRawPageData(); 
            }
            objPage = buildPage.getFinalPage();
        } catch (Exception e) { 
            ERx_PortalPackUtil.logException(e);  
        }
    }
}