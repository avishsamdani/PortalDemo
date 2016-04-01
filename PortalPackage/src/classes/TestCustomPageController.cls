public class TestCustomPageController {
    public String pageId {get;set;}
    
    public TestCustomPageController () {
        pageId = apexpages.currentpage().getparameters().get('pageId');
    }
}