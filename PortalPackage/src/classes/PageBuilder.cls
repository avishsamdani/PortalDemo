public with sharing class PageBuilder implements IPageBuilder {  
    private HtmlPage finalPage; 
    private String pageName {get;set;}
    private List<ERx_PageEntities.WrapperModel> wrapperModelList;
    private List<ERx_PageEntities.SectionModelWrapper> sectionmodelWrap;
    private Map<Integer, String> pageOrderMap = null;
    private Map<String, Integer> pageIdMap = null;
    private EnvMode appMode = null;
    
    public PageBuilder(){ 
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
                    pages = [Select Name, Id, Page_Name__c, IsActive__c, Order__c, is_Custom_Page__c, Custom_Page_Name__c, is_Custom_Header_Footer__c, (Select Id, Modal_Data__c, View_Layout__c, Order__c From Erx_Sections__r order by Order__c) From Erx_Page__c where IsActive__c = true and Env__c =: liveEnvs[0].Env__c order by Order__c];
                    this.finalPage.pageHeader = liveEnvs[0].Env__r.TP_Manage_Active_Template__r.SiteTemplateHeader__c; //TP_Manage_TemplateController.getHeaderFooterMap().get('header');
                    this.finalPage.pageFooter = liveEnvs[0].Env__r.TP_Manage_Active_Template__r.SiteTemplateFooter__c; //TP_Manage_TemplateController.getHeaderFooterMap().get('footer');
                    this.finalPage.helperIcon = liveEnvs[0].Env__r.Helper_Icon__c; 
                } else {
                	this.finalPage.environmentErrorMessage = 'Live Environment Error Message';
                }
            } else {
                List<Test_Env__c> testEnvs = [Select l.Env__r.Helper_Icon__c, l.Env__r.TP_Manage_Active_Template__r.SiteTemplateHeader__c, l.Env__r.TP_Manage_Active_Template__r.SiteTemplateFooter__c, l.Env__r.Name, l.Env__r.Env_Id__c, l.Env__c From Test_Env__c l where l.Env__r.Env_Id__c =: envId and l.Env__r.Name =: envName];
                if(testEnvs.size() > 0) {
                    pages = [Select Name, Id, Page_Name__c, IsActive__c, Order__c, is_Custom_Page__c, Custom_Page_Name__c, is_Custom_Header_Footer__c, (Select Id, Modal_Data__c, View_Layout__c, Order__c From Erx_Sections__r order by Order__c) From Erx_Page__c where IsActive__c = true and Env__c =: testEnvs[0].Env__c order by Order__c];
                    this.finalPage.pageHeader = testEnvs[0].Env__r.TP_Manage_Active_Template__r.SiteTemplateHeader__c; //TP_Manage_TemplateController.getHeaderFooterMap().get('header');
                    this.finalPage.pageFooter = testEnvs[0].Env__r.TP_Manage_Active_Template__r.SiteTemplateFooter__c; //TP_Manage_TemplateController.getHeaderFooterMap().get('footer');
                    this.finalPage.helperIcon = testEnvs[0].Env__r.Helper_Icon__c;
                } else {
                	this.finalPage.environmentErrorMessage = 'Test Environment Error Message';
                	
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
            
            this.finalPage.fieldToPopulateMap = new Map<String, Map<String, String>>();
        	this.finalPage.isAddAnotherAllowedMap = new Map<String, Boolean>();
        	this.finalPage.fieldToPopulateMapJSON = JSON.serialize(this.finalPage.fieldToPopulateMap); 
			this.finalPage.isAddAnotherAllowedMapJSON = JSON.serialize(this.finalPage.isAddAnotherAllowedMap);
        	Map<String, List<ERx_PageEntities.AttachmentWrapper>> attachmentWrapperMap = new Map<String, List<ERx_PageEntities.AttachmentWrapper>>();
			this.finalPage.attachmentMap = JSON.serialize(attachmentWrapperMap);	
			Map<String, String> paramMap = new  Map<String, String>();
			this.finalPage.paramMap = JSON.serialize(paramMap);	
			
            //getting section list of the current page
            for(Erx_Page__c page : pages) {
                if(page.Id == pageId) {
                	this.finalPage.isCustomPage = page.is_Custom_Page__c; 
                	this.finalPage.customPageName = page.Custom_Page_Name__c; 
                	this.finalPage.currentPageId = page.Id;
                	this.finalPage.isCustomHeaderFooter = page.is_Custom_Header_Footer__c; 
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
                    //ERx_PortalPackUtil.logMessage(String.valueOf(this.finalPage.jsonModalFields));
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
                List<sObject>  sList = ERx_PortalPackUtil.constructSQlList(this.finalPage, w.modelName, mapOfSobjectList, w.objectAPIName, w.field, w.condition);
                ERx_PortalPackUtil.logMessage(String.valueOf(sList)); 
                if(sList.size() == 0){
                       sObject sobj  = Schema.getGlobalDescribe().get(w.objectAPIName).newSObject() ;   
                       for(ERx_PageEntities.ModelFieldObjectWrapper f : w.field) {
                       		if(SchemaCache.getFieldDescribe(w.objectAPIName, f.fieldAPIName).isUpdateable()) {
                            	sobj.put(f.fieldAPIName, null);
                       		}
                       } 
                       sList.add(sobj); 
                }
                mapOfSobjectList.put(w.modelName, sList);
            }
            
            //ERx_PortalPackUtil.logMessage(String.valueOf(mapOfSobjectList));
            for(ERx_PageEntities.SectionModelWrapper s : sectionmodelWrap){
                for(ERx_PageEntities.FieldModelWrapper f : s.field){
                    if(!f.rendered){
                        finalConditionExpression(f, s, 'RENDERED');
                    }else{
                        f.rendredExpression = 'true';
                    }
                    if(f.required.toUpperCase() == 'CONDITION'){
                        finalConditionExpression(f, s, 'REQUIRED');
                    } else if(f.required.toUpperCase() == 'TRUE'){
                        f.requiredExpressionFinal = 'true';
                    } else {
                        f.requiredExpressionFinal = 'false';
                    }
                    
                    String modelName = '';
                    if(s.modelType == 'SECTIONMODEL') {
                        modelName = s.modelName;
                    } else {
                        modelName = f.modelName;
                    }
                    if(f.type == PortalPackageConstants.REFERENCEFLD || f.type == PortalPackageConstants.TYPE_AHEAD_FLD || f.type == PortalPackageConstants.LOOKUP_FLD) {
                    	f.displayValueAPIName = new List<ERx_PageEntities.SelectOpWrap>(); 
                    	for(Integer size = 0; size < mapOfSobjectList.get(modelName).size(); size++) {
                    		if(mapOfSobjectList.get(modelName)[size].get(f.fieldAPIName) != null) {
                    			String referenceFieldName = PortalPackageHelper.getReferenceNameField(f.fieldAPIName);
                    			List<String> referenceFieldApiNames = referenceFieldName.split('\\.');
                    			f.displayValueAPIName.add(new ERx_PageEntities.SelectOpWrap((String)mapOfSobjectList.get(modelName)[size].get(f.fieldAPIName), (String)mapOfSobjectList.get(modelName)[size].getSobject(referenceFieldApiNames[0]).get(referenceFieldApiNames[1])));
                    		} else {
                    			f.displayValueAPIName.add(new ERx_PageEntities.SelectOpWrap('', '--None--'));
                    		}
                    	}
                    }
                    
                    
                    //populated multipicklist values
                    if(f.type == PortalPackageConstants.MULTIPICKLISTFLD) { 
                    	DescribeFieldResult selectedField = SchemaCache.getFieldDescribe(modelAPI.get(modelName), f.fieldAPIName);
                    	List<SelectOption> opList = ERx_PortalPackUtil.getPickListValues(selectedField, false);
                    	f.selectedValues = new List<List<String>>();
                    	f.availableValues = new List<List<String>>();
                        for(Integer size = 0; size < mapOfSobjectList.get(modelName).size(); size++) {
                    		f.selectedValues.add(new List<String>());
                    		f.selectedValues[size] = new List<String>();
                    		f.availableValues.add(new List<String>());
                    		f.availableValues[size] = new List<String>();
                    		ERx_PortalPackUtil.logMessage(mapOfSobjectList.get(modelName) + '***sandeep');
                        	Object fldValue = mapOfSobjectList.get(modelName).get(size).get(f.fieldApiName);
                        	
                        	if(fldValue != null) {
		                        List<String> picklistValues = String.valueOf(fldValue).split(';');
		                        for(String so : picklistValues){
		                        	f.selectedValues[size].add(so);
		                        }	
                        	}
	                        Set<String> selectedValuesSet = new Set<String>();
	                        selectedValuesSet.addAll(f.selectedValues[size]);
	                        for(SelectOption so : opList){
	                        	if(!selectedValuesSet.contains(so.getValue())) {
	                        		f.availableValues[size].add(so.getValue());
	                        	}
	                        }
	                        //ERx_PortalPackUtil.logMessage(String.valueOf(f.availableValues[size]) + '***' + String.valueOf(f.selectedValues[size]));
                        }
                    }
                       
                    if(f.type == 'PICKLIST'){ 
                        
                        DescribeFieldResult selectedField = SchemaCache.getFieldDescribe(modelAPI.get(modelName), f.fieldAPIName);
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
                            for(Integer size = 0; size < mapOfSobjectList.get(modelName).size(); size++) {
                                f.selectOptionList.add(optionList);
                                if(f.isControllingField) {
                                	system.debug('size' + size + '***' + s.modelName + '@@@@' + mapOfSobjectList.get(modelName).size());
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
            ERx_PortalPackUtil.logMessage(string.valueOf(this.finalPage.attachmentMap));
        } catch (Exception e) { 
            ERx_PortalPackUtil.logException(e);
        }
    } 
    
    //createRequiredConditionForField
    
    /*
        @description this method take field as argument and 
        create rendred condition for that field. 
        @param field - for which we are creating rendred condition.  
    */
    //type can be rendered or required
    private void finalConditionExpression(ERx_PageEntities.FieldModelWrapper fieldObj, ERx_PageEntities.SectionModelWrapper sectionObj, String type) {
    	List<ERx_PageEntities.RenderedRequiredConditionWrapper> criteriaList = new List<ERx_PageEntities.RenderedRequiredConditionWrapper>();
        String conditionExpression = '';
        if(type.toUpperCase() == 'RENDERED') {
        	criteriaList = fieldObj.renderCriteriaList;
        	conditionExpression = fieldObj.renderedExpression;
        } else {
        	criteriaList = fieldObj.requiredCriteriaList;
        	conditionExpression = fieldObj.requiredExpression;
        }
        
        String resultExpression = '';
        String fieldModel = ''; 
   		if(sectionObj.modelType == PortalPackageConstants.SECTION_MODEL) {
        	fieldModel = sectionObj.modelName;
        } else {
        	fieldModel = fieldObj.modelName;
        }
        List<String> conditionList = new List<String>();
        for(ERx_PageEntities.RenderedRequiredConditionWrapper renderCriteriaObj : criteriaList){
            conditionList.add(getExpression(renderCriteriaObj, fieldModel));
        }
        
        for(Integer currentIndex = 0 ; currentIndex < conditionList.size() ; currentIndex++){
            conditionExpression = conditionExpression.replace(String.valueOf(currentIndex+1),'%%%%'+String.valueOf(currentIndex+1)+'%%%%');
        }
        conditionExpression = conditionExpression.replace('AND','&&');
     	conditionExpression = conditionExpression.replace('OR','||');
        for(Integer currentIndex = 0 ; currentIndex < conditionList.size() ; currentIndex++){
            conditionExpression = conditionExpression.replace('%%%%'+String.valueOf(currentIndex+1)+'%%%%',conditionList[currentIndex]);
        }
        if(type.toUpperCase() == 'RENDERED') {
        	fieldObj.rendredExpression = conditionExpression;	
        } else {
        	fieldObj.requiredExpressionFinal = conditionExpression;
        }		
    }
    
    private String getExpression(ERx_PageEntities.RenderedRequiredConditionWrapper criteriaObj, String fieldModelName) {
    	String pageVariable = '';
        if(criteriaObj.modelName.toUpperCase().trim() == fieldModelName.toUpperCase().trim()){
            pageVariable = ' obj[\'';
        } else{
            pageVariable = ' modelList[\'' + criteriaObj.modelName + '\'][0][\'';
        }
        
        String currentValueExpression = '(';
        List<String> valuesList =  criteriaObj.value.split(',');
        
        for(Integer valueIndex = 0; valueIndex < valuesList.size() ; valueIndex++){
           // currentValueExpression = currentValueExpression + pageVariable + criteriaObj.fieldAPIName+'\''+']' +  getOperator(renderCriteriaObj.fieldOperator, valuesList[valueIndex]);
            
        	if(criteriaObj.fieldDisplayType.toUpperCase() == 'BOOLEAN'){
				if((criteriaObj.fieldOperator.toUpperCase() == PortalPackageConstants.EQUALS_TO && valuesList[valueIndex].toUpperCase() == 'TRUE') ||
					(criteriaObj.fieldOperator.toUpperCase() == PortalPackageConstants.NOT_EQUALS_TO && valuesList[valueIndex].toUpperCase() == 'FALSE')){
					currentValueExpression = currentValueExpression + pageVariable + criteriaObj.fieldAPIName+'\']' + '==true';
				}else if((criteriaObj.fieldOperator.toUpperCase() == PortalPackageConstants.NOT_EQUALS_TO && valuesList[valueIndex].toUpperCase() == 'TRUE') ||
					(criteriaObj.fieldOperator.toUpperCase() == PortalPackageConstants.EQUALS_TO && valuesList[valueIndex].toUpperCase() == 'FALSE')){
					currentValueExpression = currentValueExpression + pageVariable + criteriaObj.fieldAPIName+'\']' + '==false';
				}
			} else {
				currentValueExpression = currentValueExpression + pageVariable + criteriaObj.fieldAPIName+'\']' +  getOperator(criteriaObj.fieldOperator, valuesList[valueIndex]);
			} 
            
            if(valuesList.size() -1 != valueIndex){
             	if(criteriaObj.fieldOperator.toUpperCase() == PortalPackageConstants.NOT_EQUALS_TO.toUpperCase().trim() || criteriaObj.fieldOperator.toUpperCase() == PortalPackageConstants.DOES_NOT_CONTAINS.toUpperCase().trim()){
					currentValueExpression = currentValueExpression + ' && ';
				}else{
					currentValueExpression = currentValueExpression + ' || ';
				}
            }
        }
        //fieldDisplayType
        currentValueExpression = currentValueExpression + ')';
        return currentValueExpression;
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
        	return '.split(\';\').indexOf(\'' + indexOfString + '\') > -1';
        }else if(operator.toUpperCase().trim() == PortalPackageConstants.EXCLUDES.toUpperCase().trim()){
            return '.split(\';\').indexOf(\'' + indexOfString + '\') == -1';
        }else if(operator.toUpperCase().trim() == PortalPackageConstants.LESS_THAN.toUpperCase().trim()){
            return '< '+indexOfString;
        }else if(operator.toUpperCase().trim() == PortalPackageConstants.GREATER_THAN.toUpperCase().trim()){
            return '> '+indexOfString;
        }else if(operator.toUpperCase().trim() == PortalPackageConstants.LESS_THAN_EQUALS.toUpperCase().trim()){
            return '<= '+indexOfString;
        }else if(operator.toUpperCase().trim() == PortalPackageConstants.GREATER_THAN_EQUALS.toUpperCase().trim()){
            return '>= '+indexOfString;
        }
        return null;
    }
    
    private void setNextPageInfo() {
        this.finalPage.isNextPage = false; 
        system.debug(pageOrderMap + '***' + pageIdMap + '***' + this.finalPage.currentPageId);
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