public with sharing class Page_Builder_Copy implements IPageBuilder {  
    private HtmlPage finalPage;
    private String pageName {get;set;}
    private List<ERx_PageEntities.WrapperModel> wrapperModelList;
    private List<ERx_PageEntities.SectionModelWrapper> sectionmodelWrap;
    private Map<Integer, String> pageOrderMap = null;
    private Map<String, Integer> pageIdMap = null;
    private EnvMode appMode = null;
    
    public Page_Builder_Copy(){ 
        try {
            //pageName is the name of the page provided as querying string parameter 
            pageName = ApexPages.currentPage().getParameters().get('pageName');
            finalPage = new HtmlPage(); 
            finalPage.isAuthorized = true;
            if(ApexPages.currentPage().getParameters().get('mode') == 'desktop') {
                finalPage.isDesktop = true;
            } else {
                finalPage.isDesktop = false;
            }    
            //finalPage.mapOfOptionList = new Map<String, Map<String, List<String>>>();
        } catch (Exception e) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() + '***' + e.getStackTraceString());
            ApexPages.addMessage(myMsg);
            ERx_PortalPackUtil.logException(e);
            //ApexPages.addMessages(e + '***' + e.getStackTraceString());
        }
    }
    
    public Boolean checkIsAuthorized(){
        finalPage.errorMessage = 'You are not authorized to view this page!!';
        return finalPage.isAuthorized;
    }
    
    public HtmlPage getFinalPage(){
        return this.finalPage;
    }
    
    public void getRawPageData(){
        try {
            //getting profileId of current user
            Id profileId = userinfo.getProfileId();
            String envId, envName;
            
            //getting current network id & setting envId and envName
            List<Network> networkList = [Select Id, Name from Network where id =: Network.getNetworkId()];
            if(networkList.size() > 0) {
                envId = networkList[0].Id;
                envName = networkList[0].Name;
            }
            
            //set appMode to test if there is record exists for current user in Test_Records__c custom setting
            appMode = ERx_PortalPackUtil.getEnvModeForCurrentUser();
            //ERx_PortalPackUtil.logMessage(string.valueOf(appMode)); 
            //fetch page information and set header and footer based on the env mode
            List<Erx_Page__c> pages = new List<Erx_Page__c>();
            if(appMode == EnvMode.Live) {
                List<Live_Env__c> liveEnvs = [Select l.Env__r.Helper_Icon__c, l.Env__r.TP_Manage_Active_Template__r.SiteTemplateHeader__c, l.Env__r.TP_Manage_Active_Template__r.SiteTemplateFooter__c, l.Env__r.Name, l.Env__r.Env_Id__c, l.Env__c From Live_Env__c l where l.Env__r.Env_Id__c =: envId and l.Env__r.Name =: envName];
                //ERx_PortalPackUtil.logMessage(string.valueOf(liveEnvs)); 
                if(liveEnvs.size() > 0) {
                    pages = [Select Name, Id, Page_Name__c, IsActive__c, Order__c, (Select Id, Modal_Data__c, View_Layout__c, Order__c From Erx_Sections__r order by Order__c) From Erx_Page__c where IsActive__c = true and Env__c =: liveEnvs[0].Env__c order by Order__c];
                    this.finalPage.pageHeader = liveEnvs[0].Env__r.TP_Manage_Active_Template__r.SiteTemplateHeader__c; //TP_Manage_TemplateController.getHeaderFooterMap().get('header');
                    this.finalPage.pageFooter = liveEnvs[0].Env__r.TP_Manage_Active_Template__r.SiteTemplateFooter__c; //TP_Manage_TemplateController.getHeaderFooterMap().get('footer');
                    this.finalPage.helperIcon = liveEnvs[0].Env__r.Helper_Icon__c;  
                }
            } else {
                List<Test_Env__c> testEnvs = [Select l.Env__r.Helper_Icon__c, l.Env__r.TP_Manage_Active_Template__r.SiteTemplateHeader__c, l.Env__r.TP_Manage_Active_Template__r.SiteTemplateFooter__c, l.Env__r.Name, l.Env__r.Env_Id__c, l.Env__c From Test_Env__c l where l.Env__r.Env_Id__c =: envId and l.Env__r.Name =: envName];
                if(testEnvs.size() > 0) {
                    pages = [Select Name, Id, Page_Name__c, IsActive__c, Order__c, (Select Id, Modal_Data__c, View_Layout__c, Order__c From Erx_Sections__r order by Order__c) From Erx_Page__c where IsActive__c = true and Env__c =: testEnvs[0].Env__c order by Order__c];
                    this.finalPage.pageHeader = testEnvs[0].Env__r.TP_Manage_Active_Template__r.SiteTemplateHeader__c; //TP_Manage_TemplateController.getHeaderFooterMap().get('header');
                    this.finalPage.pageFooter = testEnvs[0].Env__r.TP_Manage_Active_Template__r.SiteTemplateFooter__c; //TP_Manage_TemplateController.getHeaderFooterMap().get('footer');
                    this.finalPage.helperIcon = testEnvs[0].Env__r.Helper_Icon__c;
                }
            }
            //populating pageOrder map so that we can calculate previous and next page information
            Integer i = 1;
            pageOrderMap = new Map<Integer, String>();
            pageIdMap = new Map<String, Integer>();
            for(Erx_Page__c page : pages) {
                pageOrderMap.put(i, page.Id);
                pageIdMap.put(page.Id, i);
                i++;
            }
            //ERx_PortalPackUtil.logMessage(string.valueOf(pages));
            //setting page list for the sidebar check list
            this.finalPage.pageList = pages;
            
            wrapperModelList = new List<ERx_PageEntities.WrapperModel>();
            sectionModelWrap = new List<ERx_PageEntities.SectionModelWrapper>();
            
            //current pageId
            String pageId = ApexPages.currentPage().getParameters().get('pageId');
            
            
            List<Erx_Section__c> sectionList = new  List<Erx_Section__c>();
            
            //getting section list of the current page
            for(Erx_Page__c page : pages) {
                if(page.Id == pageId) {
                    sectionList = page.Erx_Sections__r;
                }
            }
            
            //populating section maps so that we can calculate previous and next section information
            Integer secCount = 1;
            Map<Integer, String> sectionOrderMap = new Map<Integer, String>();
            Map<String, Integer> sectionIdMap = new Map<String, Integer>();
            Map<String, Erx_Section__c> sectionMap = new Map<String, Erx_Section__c>();
            for(Erx_Section__c sec : sectionList) {
                sectionOrderMap.put(secCount, sec.Id);
                sectionIdMap.put(sec.Id, secCount);
                sectionMap.put(sec.Id, sec);
                secCount++;
            }
            
            if(sectionList.size() > 0) {
                this.finalPage.currentPageId = pageId;
                //In case of mobile
                if(!this.finalPage.isDesktop) {
                    //fetching current section Info. If sectionId is not passed, first section is considered as the current section
                    String sectionId = ApexPages.currentPage().getParameters().get('sectionId');
                    Erx_Section__c currentSection = new Erx_Section__c();
                    if(!String.Isblank(sectionId)) {
                        currentSection = sectionMap.get(sectionId);
                    } else {
                        currentSection = sectionList[0];
                        sectionId = sectionList[0].Id;
                    }
                    
                    //setting next section navigation info
                    this.finalPage.isNextSection = false; 
                    this.finalPage.nextSectionId = sectionOrderMap.get(sectionIdMap.get(sectionId) + 1);
                    if(!String.Isblank(this.finalPage.nextSectionId)) {
                        this.finalPage.isNextSection = true;
                    } else {
                        setNextPageInfo();
                    }
                    
                    //fetching section and model list and adding them to their respective list
                    this.finalPage.jsonViewlayout = currentSection.View_Layout__c; 
                    this.finalPage.jsonModalFields = currentSection.Modal_Data__c;
                    wrapperModelList.addAll((List<ERx_PageEntities.WrapperModel>) JSON.deserialize(this.finalPage.jsonModalFields, List<ERx_PageEntities.WrapperModel>.class));
                    sectionModelWrap.add((ERx_PageEntities.SectionModelWrapper) JSON.deserialize(this.finalPage.jsonViewlayout, ERx_PageEntities.SectionModelWrapper.class));
                } else { //In case of desktop
                    //set next page info
                    setNextPageInfo();
                    //setPrevPageInfo();
                    
                    //fetching section and model list and adding them to their respective list
                    this.finalPage.jsonViewlayout = '';  
                    for(Erx_Section__c sec : sectionList) {
                        this.finalPage.jsonViewlayout = sec.View_Layout__c;
                        this.finalPage.jsonModalFields = sec.Modal_Data__c;
                        wrapperModelList.addAll((List<ERx_PageEntities.WrapperModel>) JSON.deserialize(this.finalPage.jsonModalFields, List<ERx_PageEntities.WrapperModel>.class));
                        sectionModelWrap.add((ERx_PageEntities.SectionModelWrapper) JSON.deserialize(this.finalPage.jsonViewlayout, ERx_PageEntities.SectionModelWrapper.class));
                    }
                }
                //page is authorised as sections are found for current page and all info successfully processed
                finalPage.isAuthorized = true; 
            } else {
                finalPage.isAuthorized = true;
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Unauthorised Access');
                ApexPages.addMessage(myMsg);
            }
            
            Map<String,String> modelAPI = new  Map<String,String>();
            for(ERx_PageEntities.WrapperModel w : wrapperModelList){
                modelAPI.put(w.modelName, w.objectAPIName); 
            }
            this.finalPage.modelObjectMap = modelAPI;
            this.finalPage.modelObjectMapJSON = JSON.serialize(modelAPI);
            Map<String, List<sObject>> mapOfSobjectList = new Map<String, List<sObject>>(); 
            
            for(ERx_PageEntities.WrapperModel w : wrapperModelList) { 
                List<sObject>  sList = ERx_PortalPackUtil.constructSQlList(w.objectAPIName, w.field, w.condition);
                if(sList.size() == 0){
                       sObject sobj  = Schema.getGlobalDescribe().get(w.objectAPIName).newSObject() ;   
                       for(ERx_PageEntities.ModelFieldObjectWrapper f : w.field) {
                            sobj.put(f.fieldAPIName, null);
                       } 
                       sList.add(sobj); 
                }
                mapOfSobjectList.put(w.modelName, sList);
            }
            
            for(ERx_PageEntities.SectionModelWrapper s : sectionmodelWrap){
                for(ERx_PageEntities.FieldModelWrapper f : s.field){
                    if(!f.rendered){
                        createRendredConditionForField(f,s);
                    }else{
                        f.rendredExpression = 'true';
                    }
                    if(f.type == 'PICKLIST'){ 
                        String modelName = '';
                        if(s.modelType == 'SECTIONTYPE') {
                            modelName = s.modelName;
                        } else {
                            modelName = f.modelName;
                        }
                        DescribeFieldResult selectedField = SchemaCache.getFieldDescribe(modelAPI.get(s.modelName), f.fieldAPIName);
                        List<ERx_PageEntities.SelectOpWrap> optionList = new List<ERx_PageEntities.SelectOpWrap>();
                        if(f.isFirstValueBlank != null && f.isFirstValueBlank) { 
                            optionList.add(new ERx_PageEntities.SelectOpWrap('', '--None--'));
                        }
                        if(f.isdependentField == null || f.isdependentField == false) {
                            if(selectedField.type == DisplayType.Reference) { 
                                //ERx_PortalPackUtil.logMessage(PortalPackageHelper.getConditionString(f.lookupRecordCriteria));
                                List<SelectOption> lookUpRecords = PortalPackageHelper.getLookUpData(selectedField, PortalPackageHelper.getConditionString(selectedField, modelName, modelAPI, 0, mapOfSobjectList, f.lookupRecordCriteria), false);  
                                for(SelectOption opt : lookUpRecords) {
                                    optionList.add(new ERx_PageEntities.SelectOpWrap(opt.getValue(), opt.getLabel()));
                                }
                            } else {
                                //if f.customPicklistValues is not null, initialise picklist from this f.customPicklistValues otherwise from back-end
                                if(f.customPicklistValues != null) { 
                                    List<String> picklistValues = f.customPicklistValues.split(';');
                                    for(String val : picklistValues) {
                                        optionList.add(new ERx_PageEntities.SelectOpWrap(val, val));
                                    }
                                } else {
                                    List<SelectOption> opList = ERx_PortalPackUtil.getPickListValues(selectedField, false);
                                    for(SelectOption so : opList){
                                        optionList.add(new ERx_PageEntities.SelectOpWrap(so.getLabel(), so.getLabel()));
                                    }
                                }
                            }
                            f.selectOptionList = new List<List<ERx_PageEntities.SelectOpWrap>>();
                            for(Integer size = 0; size < mapOfSobjectList.get(s.modelName).size(); size++) {
                                f.selectOptionList.add(optionList);
                                if(f.isControllingField) {
                                	system.debug('size' + size + '***' + s.modelName + '@@@@' + mapOfSobjectList.get(s.modelName).size());
                                    PortalPackageHelper.populateDependentField(selectedField, modelAPI, size, mapOfSobjectList, sectionModelWrap, s, f);   
                                }
                            }
                        } 
                    }
                }
            }
            
            
            this.finalPage.jsonViewlayout = JSON.serialize(sectionModelWrap); 
            //ERx_PortalPackUtil.logMessage(this.finalPage.jsonViewlayout);
            
            this.finalPage.jsonModalFields = JSON.serialize(mapOfSobjectList);
            
            //getting map of params and their values for which we need to show documents
            this.finalPage.paramMap = JSON.serialize(ERx_PortalPackUtil.returnUploadFileParamMap(sectionModelWrap));
            //getting all ids against which documents need to uploaded or shown.
            Set<String> parentIds = ERx_PortalPackUtil.fetchParentIds(mapOfSobjectList, sectionModelWrap);
            this.finalPage.attachmentMap = ERx_PortalPackUtil.populateAttachment(parentIds);
        } catch (Exception e) { 
            ERx_PortalPackUtil.logException(e);
        }
    } 
    
    /*
        @description this method take field as argument and 
        create rendred condition for that field. 
        @param field - for which we are creating rendred condition.  
    */
    private void createRendredConditionForField(ERx_PageEntities.FieldModelWrapper fieldObj, ERx_PageEntities.SectionModelWrapper sectionObj){
        List<ERx_PageEntities.RenderedConditionWrapper> renderCriteriaList = fieldObj.renderCriteriaList;
        String rendredExpression = fieldObj.renderedExpression;
        String resultExpression = ''; 
   
        List<String> conditionList = new List<String>();
        for(ERx_PageEntities.RenderedConditionWrapper renderCriteriaObj : renderCriteriaList){
            
            String pageVariable = '';
            
            if(renderCriteriaObj.modelName.toUpperCase().trim() == fieldObj.modelName.toUpperCase().trim()){
                pageVariable = ' obj[\'';
            }else{
                pageVariable = ' modelList[0].';
            }
            
            String currentValueExpression = '(';
            List<String> valuesList =  renderCriteriaObj.value.split(',');
            
            for(Integer valueIndex = 0; valueIndex < valuesList.size() ; valueIndex++){
                currentValueExpression = currentValueExpression + pageVariable + renderCriteriaObj.fieldAPIName+'\''+']' +  getOperator(renderCriteriaObj.fieldOperator, valuesList[valueIndex]);
                if(valuesList.size() -1 != valueIndex){
                    currentValueExpression = currentValueExpression + ' || ';
                }
            }
            //fieldDisplayType
            currentValueExpression = currentValueExpression + ')';
            conditionList.add(currentValueExpression);
        }
        
        for(Integer currentIndex = 0 ; currentIndex < conditionList.size() ; currentIndex++){
            rendredExpression = rendredExpression.replace(String.valueOf(currentIndex+1),'%%%%'+String.valueOf(currentIndex+1)+'%%%%');
        }
        
        for(Integer currentIndex = 0 ; currentIndex < conditionList.size() ; currentIndex++){
            rendredExpression = rendredExpression.replace('%%%%'+String.valueOf(currentIndex+1)+'%%%%',conditionList[currentIndex]);
        }
        fieldObj.rendredExpression = rendredExpression;
   //   System.assert(false,rendredExpression);
    }
    
    /*
        @description this method operator as argument and return that operator
        @param field - operator value
    */
    private String getOperator(String operator,String indexOfString){
        if(operator.toUpperCase().trim() == PortalPackageConstants.EQUALS_TO.toUpperCase().trim()){
            return '=='+'\'' + indexOfString + '\'';
        }else if(operator.toUpperCase().trim() == PortalPackageConstants.NOT_EQUALS_TO.toUpperCase().trim()){
            return '!='+'\'' + indexOfString + '\'';
        }else if(operator.toUpperCase().trim() == PortalPackageConstants.CONTAINS.toUpperCase().trim()){
            return '.indexOf('+'\''+indexOfString + '\''+')> -1';
        }else if(operator.toUpperCase().trim() == PortalPackageConstants.DOES_NOT_CONTAINS.toUpperCase().trim()){
            return '.indexOf('+'\''+indexOfString + '\''+') == -1';
        }else if(operator.toUpperCase().trim() == PortalPackageConstants.STARTS_WITH.toUpperCase().trim()){
            return '.indexOf('+'\''+indexOfString + '\''+') == 0';
        }else if(operator.toUpperCase().trim() == PortalPackageConstants.ENDS_WITH.toUpperCase().trim()){
            return '.match('+'\''+indexOfString +'$'+ '\''+')=='+'\''+indexOfString + '\'';
        }else if(operator.toUpperCase().trim() == PortalPackageConstants.INCLUDES.toUpperCase().trim()){
            return '';
        }else if(operator.toUpperCase().trim() == PortalPackageConstants.EXCLUDES.toUpperCase().trim()){
            return '';
        }else if(operator.toUpperCase().trim() == PortalPackageConstants.LESS_THAN.toUpperCase().trim()){
            return '<';
        }else if(operator.toUpperCase().trim() == PortalPackageConstants.GREATER_THAN.toUpperCase().trim()){
            return '>';
        }else if(operator.toUpperCase().trim() == PortalPackageConstants.LESS_THAN_EQUALS.toUpperCase().trim()){
            return '<=';
        }else if(operator.toUpperCase().trim() == PortalPackageConstants.GREATER_THAN_EQUALS.toUpperCase().trim()){
            return '>=';
        }
        return null;
    }
    
    private void setNextPageInfo() {
        this.finalPage.isNextPage = false; 
        this.finalPage.nextPageId = pageOrderMap.get(pageIdMap.get(this.finalPage.currentPageId) + 1);
        if(!String.Isblank(this.finalPage.nextPageId)) {
            this.finalPage.isNextPage = true;
        }
    } 
    
    private void setPrevPageInfo() { 
        this.finalPage.isPrevPage = false; 
        this.finalPage.prevPageId = pageOrderMap.get(pageIdMap.get(this.finalPage.currentPageId) - 1);
        if(!String.Isblank(this.finalPage.prevPageId)) {
            this.finalPage.isPrevPage = true;
        }  
    }
    /*
    private List<ERx_PageEntities.SelectOpWrap> getOptionListForDependentFields(DescribeFieldResult selectedField, List<ERx_PageEntities.ConditionWrapper> conditionString, Boolean isFirstValueBlank) {
        List<ERx_PageEntities.SelectOpWrap> optionList = new List<ERx_PageEntities.SelectOpWrap>();
        List<SelectOption> lookUpRecords = PortalPackageHelper.getLookUpData(selectedField, PortalPackageHelper.getConditionString(modelAPI, 0, mapOfSobjectList, conditionString), isFirstValueBlank);   
        for(SelectOption opt : lookUpRecords) {
            optionList.add(new ERx_PageEntities.SelectOpWrap(opt.getValue(), opt.getLabel()));
        }
        return optionList;   
    }*/ 
    
    //Returns env mode for current user
    public EnvMode getEnvModeForCurrent() {
        Map<String, Test_Records__c> testRecordMap = Test_Records__c.getAll();
        if(testRecordMap == null) {
            appMode = EnvMode.Live;  
        } else {
            if(testRecordMap.containsKey(String.valueOf(UserInfo.getUserId()).substring(0, String.valueOf(UserInfo.getUserId()).length() - 3))) {
                appMode = EnvMode.Test; 
            } else {
                appMode = EnvMode.Live; 
            }
        }
        return appMode;
    }
}