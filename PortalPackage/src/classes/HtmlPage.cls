public with sharing class HtmlPage {
	public String jsonModalFields {get;set;}
	public String jsonViewlayout {get;set;}
	public String pageHeader {get;set;}
	public String pageTabs {get;set;}
	public String pageProgressBar {get;set;}
	public String pageFooter {get;set;}
    public String pageCSS {get;set;}
    public Boolean isDesktop {get;set;}
    public Boolean isAuthorized{get;set;}
    public String errorMessage{get;set;} 
    
    public String currentPageId {get;set;}
    public String nextPageId {get;set;}
    public String prevPageId {get;set;}
    public String nextSectionId {get;set;}
    public String prevSectionId {get;set;}
    public Boolean isNextSection {get;set;}
    public Boolean isPrevSection {get;set;}
    public Boolean isNextPage {get;set;}
    public Boolean isPrevPage {get;set;}
    
    public String attachmentMap {get;set;}
    public String paramMap {get;set;}
    public List<sObject> pageList {get;set;}
    //public Map<String, Map<String, List<String>>> mapOfOptionList {get;set;}
    //public String jsonOptionListMap {get;set;}
    
    public String helperIcon {get;set;}
    public Map<String, String> modelObjectMap {get;set;} //map of model and object
    public String modelObjectMapJSON {get;set;}
    
    public Boolean isCustomPage {get;set;}
    public String customPageName {get;set;}
    public Boolean isCustomHeaderFooter{get;set;}
    
    public String environmentErrorMessage{get; set;}
    
    //Depending upon the model criteria while fetching records, some fields can be autopopulated. for eg. While fetching all test records for current application object, 
    //we need to populate Application__c field on test record object. And a field can be populated if that field is editable and in criteria having equal operator.
    public Map<String, Map<String, String>> fieldToPopulateMap {get;set;} //key => modelName, value = map of field and respective value to be populated.
    public Map<String, Boolean> isAddAnotherAllowedMap {get;set;} //key => modelName, value = if add another record is allowed or not. 
    public String fieldToPopulateMapJSON {get;set;}
    public String isAddAnotherAllowedMapJSON {get;set;}
}