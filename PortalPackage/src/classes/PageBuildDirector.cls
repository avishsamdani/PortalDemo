public with sharing class PageBuildDirector {
    
    public HtmlPage objPage {get;set;}
    public List<Erx_Page__c> pages {get;set;} 
    public static String customPageName {get;set;}
    
    //constructor
    public PageBuildDirector(){
        
    }
    
    public void initPageLoad() {
        try {
            customPageName = 'Test_Custom_Page';
            IPageBuilder buildPage = new PageBuilder();  
            if(buildPage.checkIsAuthorized()){
                buildPage.getRawPageData(); 
            }
            objPage = buildPage.getFinalPage();
        } catch (Exception e) { 
            ERx_PortalPackUtil.logException(e);
        }
    }
    
    @RemoteAction
      public static Boolean deleteData(String deletedId, String objectName) {
       try{
            //delete (Sobject)JSON.deserialize(deletedId, Sobject.class);
            if(!String.Isblank(deletedId)) {
                sObject obj = Database.query('select Id from ' + objectName + ' where id=\'' + deletedId + '\'');
                delete obj;
            } 
            return true; 
       }catch(Exception e){
          ERx_PortalPackUtil.logException(e);
       }
       return false;
    }
    
    @RemoteAction
    public static Map<String, List<sObject>> updateData(String data, String isAddAnotherAllowedMapString, String fieldToPopulateMapString) {
          Map<String, List<sObject>> mapOfSobjectList = new Map<String, List<sObject>>();
          try {
              mapOfSobjectList = (Map<String, List<sObject>>)JSON.deserialize(data, Map<String, List<sObject>>.class);
              Map<String, Map<String, String>> fieldToPopulateMap = (Map<String, Map<String, String>>)JSON.deserialize(fieldToPopulateMapString, Map<String, Map<String, String>>.class);
              Map<String, Boolean> isAddAnotherAllowedMap = (Map<String, Boolean>)JSON.deserialize(isAddAnotherAllowedMapString, Map<String, Boolean>.class);
              List<Sobject> objectsToInsert = new List<Sobject>();
              List<Sobject> objectsToUpdate = new List<Sobject>();
              //ERx_PortalPackUtil.logMessage(String.valueOf(mapOfSobjectList));
              for(String modelName : mapOfSobjectList.keySet()) {
				  for(Sobject t : mapOfSobjectList.get(modelName)){
					if(t.Id != null) {
						objectsToUpdate.add(t);
					} else {
						if(isAddAnotherAllowedMap.get(modelName)) {
							for(String field : fieldToPopulateMap.get(modelName).keySet()) {
								t.put(field, fieldToPopulateMap.get(modelName).get(field));
							}
						}
						objectsToInsert.add(t);
					}
				  }
			  } 
              ERx_PortalPackUtil.logMessage('Sandeep***' + String.valueOf(mapOfSobjectList.values()));
              insert objectsToInsert;
              update objectsToUpdate;
          } catch (Exception e) {
              ERx_PortalPackUtil.logException(e);
              throw new PortalPackageException(e.getMessage());
          }
          return mapOfSobjectList;         
     }
     
    @RemoteAction
    public static sObject insertRecord (String data, String modelName, String isAddAnotherAllowedMapString, String fieldToPopulateMapString) {
          sObject obj;
          try {
          	  Map<String, Map<String, String>> fieldToPopulateMap = (Map<String, Map<String, String>>)JSON.deserialize(fieldToPopulateMapString, Map<String, Map<String, String>>.class);
              Map<String, Boolean> isAddAnotherAllowedMap = (Map<String, Boolean>)JSON.deserialize(isAddAnotherAllowedMapString, Map<String, Boolean>.class);	
              obj = (sObject)JSON.deserialize(data, sObject.class);
              if(isAddAnotherAllowedMap.get(modelName)) {
				for(String field : fieldToPopulateMap.get(modelName).keySet()) {
					obj.put(field, fieldToPopulateMap.get(modelName).get(field));
				}
			  }
              insert obj;
          } catch (Exception e) {
              ERx_PortalPackUtil.logException(e);
          }
          return obj;         
     }
     
    @RemoteAction
    public static List<sObject> getLookupDataByObjectAndName(String objectName, String fieldName, String searchStringValue) {
        List<sObject> returnObjectList;
        try {
            String query = 'SELECT ID, NAME from ' + ERx_PortalPackUtil.getReferenceObjectName(objectName, fieldName) + ' WHERE NAME LIKE \'%' + JSON.deserialize(searchStringValue, String.class) + '%\' limit 8';
            returnObjectList = DataBase.query(query);
            //system.assert(false, returnObjectList);
        } catch(Exception e) {
            ERx_PortalPackUtil.logException(e); 
        }
        return returnObjectList;
    }
    
    @RemoteAction
    public static ERx_PageEntities.AttachmentWrapper uploadAttachment (String attachmentName, String parentID, String base64BlobValue) {
        //system.assert(false, attachmentName + '***' + parentID + '***' + base64BlobValue);
        ERx_PageEntities.AttachmentWrapper attachmentWrapper = new ERx_PageEntities.AttachmentWrapper(); 
        Attachment attach;
        try {
            if(!String.Isblank(attachmentName) && !String.Isblank(base64BlobValue)) {
                attach = new Attachment();
                attach.Name = attachmentName;
                attach.parentId = parentID;
                attach.Body = EncodingUtil.Base64Decode(base64BlobValue);
                insert attach;
                attachmentWrapper = new ERx_PageEntities.AttachmentWrapper(String.valueOf(attach.id), String.valueOf(attach.parentId), attach.name, attach.description, String.valueOf(system.now()));
            }
        } catch(Exception e) {
            throw new PortalPackageException(e.getMessage());
        }
        return attachmentWrapper;
    }
    
    @RemoteAction
    public static boolean removeAttachment (String attachmentId) {
        try {
            delete [Select Id from Attachment where id =: attachmentId];
            return true;
        } catch(Exception e) {
            ERx_PortalPackUtil.logException(e);
        }
        return false;
    }
    
    @RemoteAction
    public static List<ERx_PageEntities.SelectOpWrap> populateDependentPicklistValues(String controllingFieldName, String controllingFieldValue, String modelApidata, String dependentField, String conditionString, Boolean isFirstValueBlank) { 
        //system.assert(false, controllingFieldName + '***' + controllingFieldValue + '@@@' + dependentField + '***' + conditionString + '&&&' + isFirstValueBlank + '^^^^^^' + data);
        List<ERx_PageEntities.SelectOpWrap> optionList = new List<ERx_PageEntities.SelectOpWrap>();
        try {  
            String conditionStr = controllingFieldName + PortalPackageConstants.EQUALS + '\'' + controllingFieldValue + '\' and ';
            List<String> dependentFieldList = dependentField.split('----'); // model----dependentFieldName
            //system.assert(false, modelApidata);   
            Map<String, String> modelApi = (Map<String, String>)JSON.deserialize(modelApidata, Map<String, String>.class);
            //String objectName = obj.getSObjectType().getDescribe().getName(); //SchemaCache.getSobjectDescribe(obj).Name;
            //system.assert(false, conditionWrapper);
            //system.assert(false, conditionString);
            List<ERx_PageEntities.ConditionWrapper> conditionWrapper = (List<ERx_PageEntities.ConditionWrapper>)JSON.deserialize(conditionString, List<ERx_PageEntities.ConditionWrapper>.class);
            // system.assert(false, conditionWrapper);
            if(conditionWrapper != null && conditionWrapper.size() > 0) { 
                for(ERx_PageEntities.ConditionWrapper w : conditionWrapper) {
                    conditionStr += w.fieldAPIName + w.fieldOperator;
                    if(w.valueType == 'STATIC') {
                        if(w.fieldDisplayType == 'STRING' && w.fieldDisplayType == 'REFERENCE' && w.fieldDisplayType == 'ID') {
                            conditionStr += '\'' + w.value + '\'';
                        } else if(w.fieldDisplayType == 'BOOLEAN') {
                            //system.assert(false, w.value.toLowerCase());
                            if(!String.IsBlank(w.value) && w.value.toLowerCase() != 'true' && w.value.toLowerCase() != 'false') {
                                w.value = 'true';
                            }
                            conditionStr += w.value;
                        } else {
                            conditionStr += w.value;
                        }
                    } else if(w.valueType == 'MODEL') {
                        conditionStr += w.value;
                    } else if(w.valueType == 'PARAM') {
                        conditionStr += w.value;
                    }
                    conditionStr += ' and '; 
                }
            } 
            conditionStr = conditionStr.substring(0, conditionStr.length() - 4);
            
            DescribeFieldResult selectedField = SchemaCache.getFieldDescribe(modelApi.get(dependentFieldList[0]), dependentFieldList[1]);
            //system.assert(false, selectedField);
            List<SelectOption> lookUpRecords = PortalPackageHelper.getLookUpData(selectedField, conditionStr, isFirstValueBlank);  
            for(SelectOption opt : lookUpRecords) {
                optionList.add(new ERx_PageEntities.SelectOpWrap(opt.getValue(), opt.getLabel()));
            }   
            //system.assert(false, optionList);
        } catch(Exception e) {
            ERx_PortalPackUtil.logException(e); 
        }
        return optionList;
    }
}