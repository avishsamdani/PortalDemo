/**
 * @author : Avish Samdani (Metacube)
 * @date : 25-01-2016
 * @description : Admin Panel Controller class to create page and assosiate with environment.
 * @name : PortalPageConfigureController.cls
 * @type: Controller 
 */
 public with sharing class PortalPageConfigureController {
    // Private data Members of class
    private Map < String, Schema.SObjectType > GlobalDescribeMap = null;
    private Schema.SObjectType SObjectTypeObj = null;
    private List<Schema.FieldSetMember> fieldSetMember;
    private List<String> filterFieldsDisplayList;
    private Map<String, String> filterFieldsDisplayMap;
    
    // Public data member of class
    public String filterFieldsDisplayListString {get;set;}
    public String filterFieldsDisplayMapString {get;set;}
    public String popupErrorMessage {get;set;}
    public String pageErrorMessage {get;set;}
    public String pageName {get;set;}
    public ID envId {get;set;}
    public Boolean isActive {get;set;}
    public String pageIdToBeDeleted {get;set;}
    public String envNameToSearch {get;set;}
    public String packageName {get;set;}
    public String visualForcePagesJson {get;set;}
    
    // Default constructor
    public PortalPageConfigureController() {
        try{
        	// Getting all visualforce pages for custom page linking.
        	List<String> visualForcePages = new List<String>();
        	List<ApexPage> lstpages = [select name from ApexPage];
        	for(ApexPage apexPage : lstpages) {
        		visualForcePages.add(apexPage.name);
        	}
        	visualForcePagesJson = JSON.serialize(visualForcePages);
        	// Getting current selected env id
        	Current_Env__c curEnv = ERx_PortalPackUtil.getCurrentEnvForConfiguration();
        	if(curEnv != null) {
        		envId = curEnv.Env__c;
        	}
        	// getting package name
            packageName = PortalPackageUtility.getNameSpacePerfix();
            if(packageName  != null && packageName  != ''){
                packageName  =  packageName+'__' ;
            }
            GlobalDescribeMap = Schema.getGlobalDescribe();
            SObjectTypeObj = GlobalDescribeMap.get(packageName + 'Erx_Page__c');
            if(SObjectTypeObj == null) {
                throw new PortalPackageException('Invalid Object. Object does not exists.');
            }
            //getting the field set fields
            fieldSetMember = PortalPackageUtility.readFieldSetbyFieldSetNameAndObj('displayed_field_columns', SObjectTypeObj);
            // Creating List and Map for Displaying on Page in a Table format.
            filterFieldsDisplayMap = new Map<String, String>();
            filterFieldsDisplayList = new List<String>();
            filterFieldsDisplayMap.put('Page_Name__c', 'Page Name');
            filterFieldsDisplayList.add('Page_Name__c');
            if(fieldSetMember != null) {
                for(Schema.FieldSetMember fsm: fieldSetMember){
                    if(fsm.getFieldPath().trim().toUpperCase() != 'PAGE_NAME__C') {
                        filterFieldsDisplayMap.put(fsm.getFieldPath(), fsm.getLabel());
                        filterFieldsDisplayList.add(fsm.getFieldPath());
                    }
                }
            }
            filterFieldsDisplayListString = JSON.serialize(filterFieldsDisplayList);
            filterFieldsDisplayMapString = JSON.serialize(filterFieldsDisplayMap);
        } catch(Exception e) {
        }
    }
    
    /** 
    * Method is used to Create Query to fetch the all the page records
    *
    */
    private String createQuery(){
    	String query = 'SELECT ID,';
        if(filterFieldsDisplayList != null) {
            for(String field : filterFieldsDisplayList){
            	//modify by sandeep
                if(field != 'is_Custom_Page__c' && field != 'Custom_Page_Name__c' && field != 'is_Custom_Header_Footer__c' && field != 'IsActive__c' && field != 'Env__c') {
                	query += field + ',';
                }
            }
            //Added by sandeep
            query += 'is_Custom_Page__c,Custom_Page_Name__c,is_Custom_Header_Footer__c,IsActive__c,Env__c,';
        }
        return query.subString(0,query.length()-1) + ' FROM ' + packageName + 'Erx_Page__c where Env__c = \'' + envId + '\'';
    }
    
    /**
    * Method Execute the query and return the result.
    *
    */    
    public String getRecords() {
        try {
        	if(envId == null) {
        		return JSON.serialize(new List<Erx_Page__c>());
        	}
        	return JSON.serialize(Database.query(createQuery()));
        }catch (QueryException e) {
            return null;
        }
    }
    
    /**
    * Method is used to create new page.
    *
    */
    @RemoteAction
    public static Map<String, String> createNewPage(String pageObject, Boolean isUpdatePage) {
    	
    	PageObjWrapper pageObj = (PageObjWrapper) JSON.deserialize(pageObject, PageObjWrapper.class);
        AggregateResult[] groupedResults = [select max(Order__c)maxOrder from Erx_Page__c where Env__c = :pageObj.envId];
        Integer maxOrder;
        if(groupedResults != null && groupedResults.size() > 0) {
            maxOrder = Integer.valueOf(groupedResults[0].get('maxOrder'));
        }
        if(maxOrder == null) {
            maxOrder = 0;
        }
        Map<String, String> returnString = new Map<String, String>();
        try {
        	// Creating New Page Instance
        	Erx_Page__c new_page = new Erx_Page__c();
        	new_page.order__c = (maxOrder + 1);
        	new_page.IsActive__c = pageObj.isActive;
        	new_page.Env__c = pageObj.envId;
        	new_page.ModelList__c = '[]';
        	if(pageObj.pageType == 'Custom') {
        		new_page.is_Custom_Page__c = true;
        		new_page.Custom_Page_Name__c = pageObj.customPageName;
        		new_page.is_Custom_Header_Footer__c = pageObj.isCustomHeaderFooter;
        		new_page.Page_Name__c = pageObj.customPageName;
        	} else {
        		new_page.Page_Name__c = pageObj.pageName;
        	}
        	if(isUpdatePage) {
        		//if request is update request.
        		new_page.Id = pageObj.pageId;
        	}
            upsert new_page;
            ERx_PortalPackUtil.logMessage(String.valueOf(new_page));
            returnString.put('Success', new_page.Id);
        } catch(Exception e) {
        	ERx_PortalPackUtil.logException(e);
            returnString.put(e.getMessage(), null);
        }
        
        return returnString;
    }
    
    /**
    * Method is used to delete the page
    *
    */
    @RemoteAction
    public static Boolean deletePage(String pageId) {
        boolean isSuccess;
        try {
            isSuccess = true;
            Erx_Page__c deletePage = [Select (Select ID from Erx_Sections__r) from Erx_Page__c where ID = :pageId];
            // Deleting All the sections related to that page.
            delete deletePage.Erx_Sections__r;
            // Deleting the page.
            delete deletePage;
        } catch(Exception e) {
            isSuccess = false;
        }
        return isSuccess;
    }
    
    /**
	 * @author : Avish Samdani (Metacube)
	 * @date : 25-01-2016
	 * @description : Page Object Wrapper Class
	 * @name : PageObjWrapper.cls
	 * @type: Wrapper 
	 */
    private class PageObjWrapper {
        private String pageName;
        private boolean isActive;
        private String envId;
        private String customPageName;
        private String pageType;
        private Boolean isCustomHeaderFooter;
        private Id pageId;
    }
    
}