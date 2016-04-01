/* **************************************************************************************
* ? 2013 Enrollment Rx, LLC. All Rights Reserved
*
* Public class: ERx_PortalPackUtil
  Stores util methods related to portal package 
*  
* Created by Sandeep Kumar, Enrollmentrx: Feb/25/2016
*
*****************************************************************************************/
public  class ERx_PortalPackUtil {
	
	private static Map<String, String> objReferenceDescribeMap = null;
	
	//returns name of reference object
    public static String getReferenceObjectName(String objectName,String fieldName){
    	if(objReferenceDescribeMap == null) {
    		objReferenceDescribeMap = new Map<String, String>(); 
    	}
    	String key = objectName + '----' + fieldName;
    	if(!objReferenceDescribeMap.containsKey(key)) {
    		objReferenceDescribeMap.put(key, SchemaCache.getFieldDescribe(objectName, fieldName).getReferenceTo()[0].getDescribe().getName());
    	} 
    	return objReferenceDescribeMap.get(key);
    }
    
    //throw error
	public static void logAndThrow(string msg){
        throw new Portal_Exception(msg); 
    }
	
	public static List<SelectOption> getPickListValues(Schema.Describefieldresult fldDesc, boolean blankFirstValue) {
            List<SelectOption> rtnValue = new List<SelectOption>();
            
            if (blankFirstValue){
                rtnValue.add(new SelectOption('', '--None--'));
            }
            
            for (Schema.Picklistentry p : fldDesc.getPicklistValues()) {
                if (p.isActive()){
                    rtnValue.add(new SelectOption(p.getValue(), p.getLabel())); 
                }
            }
            return rtnValue;
    }
    
    public static List<sObject> constructSQlList (HtmlPage htmlPage, String modelName, Map<String, List<sObject>> mapOfSobjectList, String objectName, List<ERx_PageEntities.ModelFieldObjectWrapper> fieldList, List<ERx_PageEntities.ModelCriteriaConditionWrapper> conditionWrapper) {
        htmlPage.fieldToPopulateMap = new Map<String, Map<String, String>>();
        htmlPage.fieldToPopulateMap.put(modelName, new Map<String, String>());
        htmlPage.isAddAnotherAllowedMap = new Map<String, Boolean>();
        htmlPage.isAddAnotherAllowedMap.put(modelName, true);
        
        Set<String> whereConditionFields = new Set<String>();
        for(ERx_PageEntities.ModelCriteriaConditionWrapper c : conditionWrapper) {
        	//ERx_PortalPackUtil.logMessage('San***' + c.fieldOperator + SchemaCache.getFieldDescribe(objectName, c.fieldAPIName).isUpdateable());
        	if(c.fieldAPIName != 'ID' && !SchemaCache.getFieldDescribe(objectName, c.fieldAPIName).isCalculated() && c.fieldOperator == PortalPackageConstants.EQUALS_TO) {
        		whereConditionFields.add(c.fieldAPIName);
        	} else {
        		htmlPage.isAddAnotherAllowedMap.put(modelName, false);
        	}
        }
        
        String sqlString = 'Select ID,'; 
        Boolean isNoRecordReturn = false;
        //logMessage(string.valueOf(fieldList)); 
        for(ERx_PageEntities.ModelFieldObjectWrapper f : fieldList) {
        	if(f.fieldAPIName.toUpperCase() != 'ID' && !whereConditionFields.contains(f.fieldAPIName)) {
            	sqlString += f.fieldAPIName + ','; 
        	}
        	if(SchemaCache.getFieldDescribe(objectName, f.fieldAPIName).Type == DisplayType.REFERENCE) {
	        	sqlString += PortalPackageHelper.getReferenceNameField(f.fieldAPIName) + ','; 
	    	}
        }
        for(String whereConditionField : whereConditionFields) {
        	sqlString += whereConditionField + ','; 
	        if(SchemaCache.getFieldDescribe(objectName, whereConditionField).Type == DisplayType.REFERENCE) {
	        	sqlString += PortalPackageHelper.getReferenceNameField(whereConditionField) + ','; 
	    	}
        }
        sqlString = sqlString.substring(0, sqlString.length() - 1);     
        sqlString += ' from ' + objectName; 
        
        if(conditionWrapper != null) { 
        	String conditionString = '';
        	for(ERx_PageEntities.ModelCriteriaConditionWrapper c : conditionWrapper) {
        		if(c.valueType == PortalPackageConstants.STATIC_CONS) {
    				populateModelFieldMap(htmlPage, modelName, c.fieldAPIName, c.value);
        			conditionString += handleStaticCondition(c, c.value);
        		} else if(c.valueType == PortalPackageConstants.GLOBAL_VARIABLE) {
        			String value = getGlobalVarId(c.value);
        			populateModelFieldMap(htmlPage, modelName, c.fieldAPIName, value);
    				if(c.fieldOperator == PortalPackageConstants.EQUALS_TO || c.fieldOperator == PortalPackageConstants.NOT_EQUALS_TO) {
    					if(value != null) {
							conditionString += c.fieldAPIName + PortalPackageConstants.NUMBER_OPERATOR_MAP.get(c.fieldOperator) + encloseWithQuotes(value) + PortalPackageConstants.AND_OPERATOR;
    					} else {
    						conditionString += c.fieldAPIName + PortalPackageConstants.NUMBER_OPERATOR_MAP.get(c.fieldOperator) + value + PortalPackageConstants.AND_OPERATOR;
    					}
					} else {
						isNoRecordReturn = true;
						logMessage(c.fieldOperator + ' operator is not valid for Global Type variables');
					}
        		} else if(c.valueType == PortalPackageConstants.PARAM) {
        			String value = ApexPages.currentPage().getParameters().get(c.value);
        			populateModelFieldMap(htmlPage, modelName, c.fieldAPIName, value);
        			if(value == null) {
        				isNoRecordReturn = true;
        			} else {
        				conditionString += handleStaticCondition(c, value);
        			}
        		} else if(c.valueType == PortalPackageConstants.MODEL) {
        			if(mapOfSobjectList.get(c.modelName) != null && mapOfSobjectList.get(c.modelName).size() > 0) {
        				String value = String.valueOf(mapOfSobjectList.get(c.modelName)[0].get(c.value));
        				populateModelFieldMap(htmlPage, modelName, c.fieldAPIName, value);
        				conditionString += handleStaticCondition(c, value);
        			} else {
        				isNoRecordReturn = true;
        			}
        		}
        	}
        	try {
	        	conditionString = conditionString.substring(0, conditionString.length() - 4);
	        	sqlString += ' where ' + conditionString;
	        	system.debug(sqlString + '***sandeep');
        	} catch (Exception e) {
        		system.debug(e.getMessage());
        	}
        }
        
        htmlPage.fieldToPopulateMapJSON = JSON.serialize(htmlPage.fieldToPopulateMap); 
        htmlPage.isAddAnotherAllowedMapJSON = JSON.serialize(htmlPage.isAddAnotherAllowedMap);
        ERx_PortalPackUtil.logMessage('Sandeep1***' + htmlPage.fieldToPopulateMapJSON + '***********' + htmlPage.isAddAnotherAllowedMapJSON);
        ERx_PortalPackUtil.logMessage('Sandeep2***' + String.valueOf(htmlPage.fieldToPopulateMap) + '***********' + String.valueOf(htmlPage.isAddAnotherAllowedMap));
        
        if(isNoRecordReturn) {
        	return new List<sObject>();
        } else {
        	return Database.query(sqlString);
        }
    }
    
    private static void populateModelFieldMap(HtmlPage h, String modelName, String fieldApi, String value) {
    	if(h.isAddAnotherAllowedMap.get(modelName)) {
			h.fieldToPopulateMap.get(modelName).put(fieldApi, value);
		}
    }
    public static String handleStaticCondition(ERx_PageEntities.ModelCriteriaConditionWrapper c, String value) {
    	String conditionString = '';
    	if(PortalPackageConstants.STRING_TYPE_FIELDS.contains(c.fieldDisplayType)) {
			if(PortalPackageConstants.NUMBER_OPERATORS.contains(c.fieldOperator)) {
				if(c.fieldOperator == PortalPackageConstants.EQUALS_TO || c.fieldOperator == PortalPackageConstants.NOT_EQUALS_TO) {
					if(value != null) {
						conditionString += c.fieldAPIName + PortalPackageConstants.NUMBER_OPERATOR_MAP.get(c.fieldOperator) + encloseWithQuotes(value) + PortalPackageConstants.AND_OPERATOR;
					} else {
						conditionString += c.fieldAPIName + PortalPackageConstants.NUMBER_OPERATOR_MAP.get(c.fieldOperator) + value + PortalPackageConstants.AND_OPERATOR;
					}
				} else {
					if(value != null) {
						conditionString += c.fieldAPIName + PortalPackageConstants.NUMBER_OPERATOR_MAP.get(c.fieldOperator) + encloseWithQuotes(value) + PortalPackageConstants.AND_OPERATOR;
					} else {
						logMessage(c.fieldOperator + ' operator can\'t be applied for null values');
					}
				}
			} else if(c.fieldOperator == PortalPackageConstants.CONTAINS) {
				if(value != null) {
					conditionString += c.fieldAPIName + PortalPackageConstants.LIKE_OPERATOR + encloseWithQuotes('%' + value + '%') + PortalPackageConstants.AND_OPERATOR; 
				}
			} else if(c.fieldOperator == PortalPackageConstants.DOES_NOT_CONTAINS) { 
				if(value != null) {
					conditionString += '(' + PortalPackageConstants.NOT_OPERATOR + c.fieldAPIName + PortalPackageConstants.LIKE_OPERATOR + encloseWithQuotes('%' + value + '%') + ')' + PortalPackageConstants.AND_OPERATOR;
				} else {
					conditionString += '(' + PortalPackageConstants.NOT_OPERATOR + c.fieldAPIName + PortalPackageConstants.LIKE_OPERATOR + encloseWithQuotes('%%') + ')' + PortalPackageConstants.AND_OPERATOR;
				}
			} else if(c.fieldOperator == PortalPackageConstants.STARTS_WITH) {
				if(value != null) {
					conditionString += c.fieldAPIName + PortalPackageConstants.LIKE_OPERATOR + encloseWithQuotes('%' + value ) + PortalPackageConstants.AND_OPERATOR;
				}
			} else if(c.fieldOperator == PortalPackageConstants.ENDS_WITH) {
				if(value != null) {
					conditionString += c.fieldAPIName + PortalPackageConstants.LIKE_OPERATOR + encloseWithQuotes(value + '%') + PortalPackageConstants.AND_OPERATOR;
				}
			} 
		} else if(PortalPackageConstants.NUMBER_TYPE_FIELDS.contains(c.fieldDisplayType)) {
			if(PortalPackageConstants.NUMBER_OPERATORS.contains(c.fieldOperator)) {
				if(c.fieldOperator == PortalPackageConstants.EQUALS_TO || c.fieldOperator == PortalPackageConstants.NOT_EQUALS_TO) {
					conditionString += c.fieldAPIName + PortalPackageConstants.NUMBER_OPERATOR_MAP.get(c.fieldOperator) + value + PortalPackageConstants.AND_OPERATOR;
				} else {
					if(value != null) {
						conditionString += c.fieldAPIName + PortalPackageConstants.NUMBER_OPERATOR_MAP.get(c.fieldOperator) + value + PortalPackageConstants.AND_OPERATOR;
    				} else {
    					logMessage(c.fieldOperator + ' operator can\'t be applied for null values');
					}
				}
			}
		}
		return conditionString;
    }
    public static Id getGlobalVarId(String globalVar) {
    	Id globalVarId = null;
    	if(globalVar == PortalPackageConstants.CURRENTUSERID) {
    		globalVarId = UserInfo.getUserId();
    	} else if(globalVar == PortalPackageConstants.CURRENTCONTACTID) {
    		globalVarId = getCurrentContactId();
    	} else if(globalVar == PortalPackageConstants.CURRENTPROFILEID) {
    		globalVarId = getCurrentProfileId();
    	} else if(globalVar == PortalPackageConstants.CURRENTCOMMUNITYID) {
    		globalVarId = Network.getNetworkId();
    	}
    	return globalVarId;
    }
    
    //Returns current user's contact id.
    public static Id getCurrentContactId() {
    	List<User> userList = [Select Id, contactId from User where id =: UserInfo.getUserId()];
		if(userList.size() > 0 && userList[0].contactId != null) {
			return userList[0].contactId;
		} else {
			logMessage('Current User ' + UserInfo.getName() + ' has no contact Id');
			return null;
		}		
    }
    
    //Returns current user's profile id.
    public static Id getCurrentProfileId() {
    	List<User> userList = [Select Id, contactId, profileId from User where id =: UserInfo.getUserId()];
		return userList[0].profileId;	
    }
    
    public static string encloseWithQuotes(String str) {
		return '\'' + str + '\'';
	}

    public static String populateAttachment (Set<String> parentIds) { 
    	Map<String, List<ERx_PageEntities.AttachmentWrapper>> attachmentWrapperMap = new Map<String, List<ERx_PageEntities.AttachmentWrapper>>();
	    try {
	    	List<Attachment> attachment = [Select Id, ParentId, name, description, createdDate from Attachment where parentId in: parentIds];
	    	//ERx_PortalPackUtil.logMessage(parentIds + '****' + String.valueOf(attachment)); 
	    	for(Attachment att : attachment) {
	    		if(!attachmentWrapperMap.containsKey(att.parentId)) {
	    			attachmentWrapperMap.put(att.parentId, new List<ERx_PageEntities.AttachmentWrapper> {new ERx_PageEntities.AttachmentWrapper(String.valueOf(att.id), String.valueOf(att.parentId), att.name, att.description, String.valueOf(att.createdDate))});
	    		} else {
	    			attachmentWrapperMap.get(att.parentId).add(new ERx_PageEntities.AttachmentWrapper(String.valueOf(att.id), String.valueOf(att.parentId), att.name, att.description, String.valueOf(att.createdDate)));
	    		}
	    	} 
    	} catch (Exception e) {
    		ERx_PortalPackUtil.logException(e);
    	}
    	//ERx_PortalPackUtil.logMessage(String.valueOf(attachmentWrapperMap) + '@@@@@'); 
    	return JSON.serialize(attachmentWrapperMap);
    }
    
    public static Set<String> fetchParentIds(Map<String, List<sObject>> mapOfSobjectList, List<ERx_PageEntities.SectionModelWrapper> sectionmodelWrap) {
    	Set<String> parentIds = new Set<String>();
    	Set<String> modelNames = new Set<String>();
    	Set<String> paramList = new Set<String>();
    	for(ERx_PageEntities.SectionModelWrapper section : sectionmodelWrap) {
    		for(ERx_PageEntities.FieldModelWrapper field : section.field) {
    			if(field.type == 'UPLOAD' && field.parentIdSource == 'STATIC') {
    				parentIds.add(field.parentId);	
    			} else if(field.type == 'UPLOAD' && field.parentIdSource == 'MODEL') {
    				modelNames.add(field.parentId);
    			} 
    		}
    	}
    	for(String modelName : modelNames) {
    		if(mapOfSobjectList.get(modelName) != null && mapOfSobjectList.get(modelName).size() > 0) {
    			for(sObject obj : mapOfSobjectList.get(modelName)) {
    				parentIds.add((String)obj.get('Id'));
    			}
    		}
    	}
    	parentIds.addAll(returnUploadFileParamMap(sectionmodelWrap).values());
    	return parentIds; 
    }
    
    //returns map of params and their values for which we need to show documents
    public static Map<String, String> returnUploadFileParamMap (List<ERx_PageEntities.SectionModelWrapper> sectionmodelWrap) {
    	Set<String> paramList = new Set<String>();
    	Map<String, String> paramMap = new  Map<String, String>();
    	for(ERx_PageEntities.SectionModelWrapper section : sectionmodelWrap) {
    		for(ERx_PageEntities.FieldModelWrapper field : section.field) {
    			if(field.type == 'UPLOAD' && field.parentIdSource == 'PARAM') {
    				paramList.add(field.parentId);
    			}
    		}
    	}
    	for(String param : paramList) {
    		if(apexpages.currentpage().getparameters().get(param) != null) {
    			paramMap.put(param, apexpages.currentpage().getparameters().get(param));
    		}
    	}
    	return paramMap;
    }
    
    //insert exception into logger object.
    public static void logException(Exception ex) {
    	Portal_Package_Logger__c logger = new Portal_Package_Logger__c();
    	logger.LineNumber__c = ex.getLineNumber();
    	logger.Message__c = ex.getMessage();
    	logger.StackTraceString__c = ex.getStackTraceString();
    	logger.TypeName__c = ex.getTypeName();
    	insert logger;
    }
    
    //insert message into logger object
    public static void logMessage(String message) {
    	Portal_Package_Logger__c logger = new Portal_Package_Logger__c();
    	logger.Message__c = message;
    	insert logger;
    }
    
    //Returns env mode for current user
    public static EnvMode getEnvModeForCurrentUser() {
    	EnvMode appMode = EnvMode.Live;
	    Map<String, Test_Records__c> testRecordMap = Test_Records__c.getAll();
	    if(testRecordMap != null) {
	    	if(testRecordMap.containsKey(String.valueOf(UserInfo.getUserId()).substring(0, String.valueOf(UserInfo.getUserId()).length() - 3))) {
	    		appMode = EnvMode.Test;	
	    	} else {
	    		appMode = EnvMode.Live;	
	    	}
	    }
	    return appMode;
	}

	
	//Returns env mode for site user
    public static EnvMode getEnvModeForSite(Boolean isTest) {
    	EnvMode appMode = EnvMode.Live;
	    if(isTest) {
	    	appMode = EnvMode.Test;
	    }
	    return appMode;
	}
	
	//Returns env id for site user
    public static Id getCurrentEnvId(Boolean isTest) {
    	Id currentEnvId = null, envId = null; 
    	String envName = null;
    	
    	//getting current network id & setting envId and envName
        List<Network> networkList = [Select Id, Name from Network where id =: Network.getNetworkId()];
        if(networkList.size() > 0) {
            envId = networkList[0].Id;
            envName = networkList[0].Name;
        }
        List<Erx_Page__c> pages = new List<Erx_Page__c>();
        if(!isTest) {
            List<Live_Env__c> liveEnvs = [Select l.Env__c From Live_Env__c l where l.Env__r.Env_Id__c =: envId and l.Env__r.Name =: envName];
            //ERx_PortalPackUtil.logMessage(envId + '***' + envName);
            currentEnvId = liveEnvs[0].Env__c;
        } else {
            List<Test_Env__c> testEnvs = [Select l.Env__c From Test_Env__c l where l.Env__r.Env_Id__c =: envId and l.Env__r.Name =: envName];
            currentEnvId = testEnvs[0].Env__c;
        }
        return currentEnvId;
	}

    /************************************/
    //Added by Joey, retrieve current ENV 
    /************************************/
    public static Env__c getCurrentEnv() {
        Env__c returnMe = null;

        string eMode = (ERx_PortalPackUtil.getEnvModeForCurrentUser() == EnvMode.Live)? 'Live' : 'Test' ;
        string siteId = Site.getSiteId();   
        string queryString= 'SELECT ';
        for(string fieldName : Schema.getGlobalDescribe().get('Env__c').getDescribe().fields.getMap().keySet()){
            queryString += fieldName;
            queryString += ',';
        }
        queryString = queryString.subString(0, queryString.length() - 1);
        queryString += ' FROM Env__c WHERE Env_Status__c = \''+ eMode + '\' AND Env_Site_Id__c = \''+ siteId+ '\' LIMIT 1';

        //query env with all fields
        try{
            returnMe = Database.query(queryString);
        }catch(Exception e){
            ERx_PortalPackUtil.logException(e);
        }
        return returnMe;
    }

    
    public static Current_Env__c getCurrentEnvForConfiguration() {
        Map<String, Current_Env__c> testRecordMap = Current_Env__c.getAll();
        if(testRecordMap != null) {
            return testRecordMap.get(UserInfo.getUserId());
        }
        return null;
    }
    
    public static String getCurrentEnvIdGlobal(){
    	List<Current_Env__c> envList = Current_Env__c.getAll().values();
    	if(envList != null && envList.size() > 0){
    		return envList[0].ActiveEnvId__c;
    	}
    	return null;
    }

}