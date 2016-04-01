/**
	@author: Sandeep Kumar, EnrollmentRx
	@date: 21/01/2016
	@description: Helper class for execution related functionality
	@name: PortalPackageHelper
	@type: Helper class
*/
public with sharing class PortalPackageHelper {
	private static final String SELECT_CLAUSE = ' SELECT ';
    private static final String WHERE_CLAUSE = ' WHERE ';
    private static final String FROM_CLAUSE = ' FROM ';
    private static final String EQUAL = ' = ';
	
	//get live envs
	public static Set<Id> getliveEnvIds (Set<Id> envIds) { // envIds is set of id of env__c object records object.
		List<Live_Env__c> liveEnvs = [Select Id, Env__c from Live_Env__c where Env__c in: envIds];
		Set<Id> liveEnvIds = new Set<Id>();
		for(Live_Env__c lv : liveEnvs) {
			liveEnvIds.add(lv.Env__c);
		}	
		return liveEnvIds;
	}
	
	//get live pages
	public static Set<ID> getLivePageIds (List<Erx_Page__c> pageList) { //pageList must query on env__c field.
		Map<Id, Set<Id>> mapOfLiveEnvAndRespectivePages = new Map<Id, Set<Id>>();
		Set<Id> livePageIds = new Set<Id>();
		for(Erx_Page__c page : pageList) {
			if(!mapOfLiveEnvAndRespectivePages.containsKey(page.Env__c)) {
				mapOfLiveEnvAndRespectivePages.put(page.Env__c, new Set<Id>{page.Id});
			} else {
				mapOfLiveEnvAndRespectivePages.get(page.Env__c).add(page.Id);
			}
		}
		Set<Id> liveEnvIds = getliveEnvIds(mapOfLiveEnvAndRespectivePages.keySet());
		for(Id liveEnvId: liveEnvIds) {
			livePageIds.addAll(mapOfLiveEnvAndRespectivePages.get(liveEnvId));
		}
		return livePageIds;
	}
	
	//get live pages
	public static Set<ID> getLivePageIds (Set<Id> pageIds) { 
		List<Erx_Page__c> pageList = [Select Id, Env__c from Erx_Page__c where id in: pageIds];
		return getLivePageIds(pageList);
	}
	
	//get live sections
	public static Set<ID> getLiveSectionIds (List<Erx_Section__c> sectionList) {
		Map<Id, Set<Id>> pageSectionMap = new Map<Id, Set<Id>>();
		//system.assert(false, sectionList);
		for(Erx_Section__c section : sectionList) {
			if(!pageSectionMap.containsKey(section.Erx_Page__c)) {
				pageSectionMap.put(section.Erx_Page__c, new Set<Id>{section.Id});
			} else {
				pageSectionMap.get(section.Erx_Page__c).add(section.Id);
			}
		}
		Set<Id> livePageIds = getLivePageIds(pageSectionMap.keySet());
		Set<Id> liveSectionIds = new Set<Id>();
		for(Id pageId: livePageIds) {
			liveSectionIds.addAll(pageSectionMap.get(pageId));
		}
		return liveSectionIds;
	}
	
	//get live sections
	public static Set<ID> getLiveSectionIds (Set<Id> sectionIds) {
		List<Erx_Section__c> sectionList = [Select Id, Erx_Page__c from Erx_Section__c where id in: sectionIds];
		return getLiveSectionIds(sectionList);
	}
	
	//get list of live template Ids
	public static Set<ID> getLiveTemplateIds (Set<Id> siteLoginTemplateIds) {
		List<SiteLoginTemplate__c> templateList = [Select Id, (Select Id from Envs__r) from SiteLoginTemplate__c where id in: siteLoginTemplateIds];
		Set<ID> listOfEnvs = new Set<Id>();
		for(SiteLoginTemplate__c template : templateList) {
			for(Env__c env : template.Envs__r) {
				listOfEnvs.add(env.Id);
			}
		}
		Set<Id> liveEnvIds = getliveEnvIds(listOfEnvs);
		Set<Id> liveTemplateIDs = new Set<Id>();
		Boolean isTemplateLive = false;
		for(SiteLoginTemplate__c template : templateList) {
			isTemplateLive = false;
			for(Env__c env : template.Envs__r) {
				if(liveEnvIds.contains(env.Id)) {
					isTemplateLive = true;
					break;
				}
			}
			if(isTemplateLive) {
				liveTemplateIDs.add(template.Id);
			}
		}
		return liveTemplateIDs;
	}
	
	public static List<SelectOption> getLookUpData(DescribeFieldResult lookUpFieldDescribe, String conditionString, Boolean blankFirstValue) {
		System.debug('conditionString***' + conditionString);
		List<Schema.sObjectType> sObjectTypeList = lookUpFieldDescribe.getReferenceTo();
		List<SelectOption> options = new List<SelectOption>();
		if (blankFirstValue){
            options.add(new SelectOption('', '--None--')); 
        }
		for(Schema.sObjectType objType : sObjectTypeList) {
			DescribeSObjectResult describeObject = objType.getDescribe();
			List<sObject> objList = getObjectWithFields(describeObject.getName(), conditionString, null, new List<String>{'Id', 'Name'}, RequiredFieldTypes.ONLY_CUSTOM_FIELDS);
			for(sObject obj : objList) {
				options.add(new SelectOption((String)obj.get('Id'), (String)obj.get('Name')));
			}
		}
		return options;
	}
	
	/****************************************************************************************
           This method returns list of all fieldSetMembers for passed object.
          @param objectName    Object Name
          @param fieldSetName    fieldset Name
          @return list of fieldset members
     *****************************************************************************************/ 
    public static List<sObject> getObjectWithFields(String objectName, String conditionString, List<schema.fieldsetmember> fieldSetValues, List<String> customFields, RequiredFieldTypes fType) {  
        try{
        	if((customFields == null || customFields.size() == 0) && fType == RequiredFieldTypes.ONLY_CUSTOM_FIELDS) {
        		system.debug('There is no custom field for ' + objectName + ' so Id field is added by default');
        		customFields = new List<String>{'Id'};
        	}
            String query = SELECT_CLAUSE ;
            Map<String, Schema.SObjectType> globalDescribeMap = Schema.getGlobalDescribe(); 
            Schema.SObjectType sObjectTypeObj = globalDescribeMap.get(objectName);
            
            if(fType == RequiredFieldTypes.ALL_FIELDS || fType == RequiredFieldTypes.ALL_FIELDS_WITH_CUSTOM_FIELDS || fType == RequiredFieldTypes.ONLY_CUSTOM_FIELDS){
                if(fType == RequiredFieldTypes.ALL_FIELDS || fType == RequiredFieldTypes.ALL_FIELDS_WITH_CUSTOM_FIELDS) {
                    Schema.DescribeSObjectResult describeSObjectResultObj = sObjectTypeObj .getDescribe(); 
                    Map<String,Schema.SObjectField> fields = describeSObjectResultObj.fields.getMap() ;          
                    List<Schema.SObjectField> fieldMapValues = fields.values(); 
                    for(Schema.SObjectField field : fieldMapValues) {    
                        query += field.getDescribe().getName();                
                        query += ',';
                    }   
                }
                
                if(fType == RequiredFieldTypes.ALL_FIELDS_WITH_CUSTOM_FIELDS || fType == RequiredFieldTypes.ONLY_CUSTOM_FIELDS) {
                    if(customFields != null) {
                        for(String customeField : customFields) {
                            query += customeField+',';
                        }   
                    }   
                }
                
            } else if(fType == RequiredFieldTypes.ONLY_FIELDSET_FIELDS){
                for(schema.fieldsetmember f : fieldSetValues) {
                    query += f.getFieldPath() + ',';
                }
            }
            
            query = query.subString(0, query.length() - 1);
            query += FROM_CLAUSE + objectName;
            
            if(!String.IsBlank(conditionString)){  
                query += WHERE_CLAUSE + conditionString;
            }            
            System.debug('###'+query ); 
            //system.assert(false, query);     
            return Database.query(query);
        } catch(Exception e) {
        	ERx_PortalPackUtil.logException(e);
            return null;
        }
    }  
    
    public static String getConditionString(DescribeFieldResult selectedField, String currentFieldModel, Map<String,String> modelAPI, Integer recordIndex, Map<String, List<sObject>> mapOfSobjectList, List<ERx_PageEntities.ConditionWrapper> conditionString) {
    	String conditionStr = '';
    	Set<DisplayType> numbericDisplayTypeList = new Set<DisplayType>{DisplayType.Integer, DisplayType.Currency, DisplayType.Double, DisplayType.Percent, DisplayType.Boolean};
    	if(conditionString != null && conditionString.size() > 0) {
    		for(ERx_PageEntities.ConditionWrapper w : conditionString) {
        		conditionStr += w.fieldAPIName + PortalPackageConstants.NUMBER_OPERATOR_MAP.get(w.fieldOperator);
        		if(w.valueType == 'STATIC') {
        			if(numbericDisplayTypeList.contains(selectedField.getReferenceTo()[0].getDescribe().fields.getMap().get(w.fieldAPIName).getDescribe().getType())) {
        				conditionStr += w.value; 
        			} else {
        				conditionStr += '\'' + w.value + '\'';
        			}
        		} else if(w.valueType == 'MODEL') {
        			if(currentFieldModel != w.modelName) {
        				recordIndex = 0;
        			}
        			if(numbericDisplayTypeList.contains(selectedField.getReferenceTo()[0].getDescribe().fields.getMap().get(w.fieldAPIName).getDescribe().getType())) {
        				conditionStr += (String)mapOfSobjectList.get(w.modelName)[recordIndex].get(w.value);
        			} else {
        				conditionStr += '\'' + (String)mapOfSobjectList.get(w.modelName)[recordIndex].get(w.value) + '\'';
        			}
        		} else if(w.valueType == 'PARAM') {
        			String value = ApexPages.currentPage().getParameters().get(w.value);
        			if(numbericDisplayTypeList.contains(selectedField.getReferenceTo()[0].getDescribe().fields.getMap().get(w.fieldAPIName).getDescribe().getType())) {
        				conditionStr += value;
        			} else {
        				conditionStr += '\'' + value + '\'';
        			}
        		}
        		conditionStr += 'and';
        	}
        	conditionStr = conditionStr.substring(0, conditionStr.length() - 3);
        	//ERx_PortalPackUtil.logMessage(String.valueOf(conditionString) + '***' + conditionStr);
    	}
    	 
    	return conditionStr;
    }
    
    public static ERx_PageEntities.FieldModelWrapper getFieldModelWrapper(List<ERx_PageEntities.SectionModelWrapper> sectionModelWrap, String modelName, String fieldAPIName) {
		for(ERx_PageEntities.SectionModelWrapper sectionWrapper : sectionModelWrap) {
			if(sectionWrapper.modelType == 'SECTIONMODEL' && sectionWrapper.modelName == modelName) {
				for(ERx_PageEntities.FieldModelWrapper fieldWrapper : sectionWrapper.field) {
					if(fieldWrapper.fieldAPIName == fieldAPIName) {
						return 	fieldWrapper;
					}			
				}
			} 
			if(sectionWrapper.modelType == 'FIELDMODEL') {
				for(ERx_PageEntities.FieldModelWrapper fieldWrapper : sectionWrapper.field) {
					if(fieldWrapper.fieldAPIName == fieldAPIName && fieldWrapper.modelName == modelName) {
						return 	fieldWrapper;
					}			
				}
			} 
		} 
		return null;
	}
	
	public static ERx_PageEntities.SectionModelWrapper getCurrentSectionModelWrapper (List<ERx_PageEntities.SectionModelWrapper> sectionModelWrap, String modelName, String fieldAPIName) {
		for(ERx_PageEntities.SectionModelWrapper sectionWrapper : sectionModelWrap) {
			if(sectionWrapper.modelType == 'SECTIONMODEL' && sectionWrapper.modelName == modelName) {
				return 	sectionWrapper;
			} 
			if(sectionWrapper.modelType == 'FIELDMODEL') {
				for(ERx_PageEntities.FieldModelWrapper fieldWrapper : sectionWrapper.field) {
					if(fieldWrapper.fieldAPIName == fieldAPIName && fieldWrapper.modelName == modelName) {
						return 	sectionWrapper;
					}			
				}
			} 
		} 
		return null;
	}
	
	public static void populateDependentField(DescribeFieldResult selectedField, Map<String,String> modelAPI, Integer recordIndex, Map<String, List<sObject>> mapOfSobjectList, List<ERx_PageEntities.SectionModelWrapper> sectionModelWrap, ERx_PageEntities.SectionModelWrapper currentSectionModelWrapper, ERx_PageEntities.FieldModelWrapper currentFieldModelWrapper) {
		system.debug(selectedField.getName() + '***' + modelAPI + '&&&' + recordIndex + '^^^^'+ mapOfSobjectList + '###' + sectionModelWrap + '@@@' + currentSectionModelWrapper + '###' + currentFieldModelWrapper);
		List<String> dependentFieldList = new List<String>();
		dependentFieldList.addAll(currentFieldModelWrapper.dependentCriteriaMap.keySet());  
		String dependentFieldModelName = '';
		String dependentFieldAPIName = '';
		for(String dpField : dependentFieldList) {
			List<String> modelAndDepField = dpField.split('----'); 
			dependentFieldModelName = modelAndDepField[0];
			dependentFieldAPIName = modelAndDepField[1];
			//if controlling and dependent fields are from same section, populate the same record.
			ERx_PageEntities.SectionModelWrapper dependentSectionModelWrap = getCurrentSectionModelWrapper(sectionmodelWrap, dependentFieldModelName, dependentFieldAPIName);
			if(currentSectionModelWrapper.modelType == 'SECTIONMODEL' && currentSectionModelWrapper.modelName == dependentFieldModelName) {
				DescribeFieldResult dependentFieldResult = SchemaCache.getFieldDescribe(modelAPI.get(dependentFieldModelName), dependentFieldAPIName);
				ERx_PageEntities.FieldModelWrapper fieldModelWrap = getFieldModelWrapper(sectionmodelWrap, dependentFieldModelName, dependentFieldAPIName);
				
				String currentFieldValue = (String)(mapOfSobjectList.get(currentSectionModelWrapper.modelName)[recordIndex].get(currentFieldModelWrapper.fieldAPIName));
				List<ERx_PageEntities.SelectOpWrap> depOptionList = new List<ERx_PageEntities.SelectOpWrap>();
				//if controlling field value is not null, then populate dependent field.
				if(fieldModelWrap.isFirstValueBlank) {
					depOptionList.add(new ERx_PageEntities.SelectOpWrap(null, '--None--'));			
				}
				if(currentFieldValue == null && !currentFieldModelWrapper.isFirstValueBlank) {
					mapOfSobjectList.get(currentSectionModelWrapper.modelName)[recordIndex].put(currentFieldModelWrapper.fieldAPIName, (Object)(currentFieldModelWrapper.selectOptionList[recordIndex][0].id));
					currentFieldValue = (String)(mapOfSobjectList.get(currentSectionModelWrapper.modelName)[recordIndex].get(currentFieldModelWrapper.fieldAPIName));
				}
				if(currentFieldValue != null) { 
					if(currentFieldModelWrapper.picklistDependencyMap == null || currentFieldModelWrapper.picklistDependencyMap.size() == 0) {
						depOptionList.addAll(getDependentReferenceValues(currentSectionModelWrapper.modelName, selectedField, dependentFieldResult, currentSectionModelWrapper, currentFieldModelWrapper, modelAPI, fieldModelWrap, mapOfSobjectList, dpField, currentFieldValue, recordIndex));
					} else {
						depOptionList.addAll(getDependentPicklistValues(currentFieldValue, currentFieldModelWrapper, dpField));
					}
					if(fieldModelWrap.isControllingField) {
		                PortalPackageHelper.populateDependentField(dependentFieldResult, modelAPI, recordIndex, mapOfSobjectList, sectionModelWrap, dependentSectionModelWrap, fieldModelWrap);   
		            }
				} 
				if(fieldModelWrap.selectOptionList == null) {
					fieldModelWrap.selectOptionList = new List<List<ERx_PageEntities.SelectOpWrap>>();
				}
				fieldModelWrap.selectOptionList.add(depOptionList);
			} else {  
				String currentModel = getModelName(currentSectionModelWrapper, currentFieldModelWrapper);
				DescribeFieldResult dependentFieldResult = SchemaCache.getFieldDescribe(modelAPI.get(dependentFieldModelName), dependentFieldAPIName);
				ERx_PageEntities.FieldModelWrapper fieldModelWrap = getFieldModelWrapper(sectionmodelWrap, dependentFieldModelName, dependentFieldAPIName);
				if(fieldModelWrap != null) {
					List<ERx_PageEntities.SelectOpWrap> depOptionList = new List<ERx_PageEntities.SelectOpWrap>();
					//ERx_PortalPackUtil.logMessage('fieldModelWrap.isFirstValueBlank' + fieldModelWrap.isFirstValueBlank+dependentFieldModelName);
					if(fieldModelWrap.isFirstValueBlank) {
						depOptionList.add(new ERx_PageEntities.SelectOpWrap('', '--None--'));			
					}
					String currentFieldValue = null;
					if(mapOfSobjectList.get(currentModel) != null && mapOfSobjectList.get(currentModel).size() != 0) {
						//ERx_PortalPackUtil.logMessage(currentModel + '***' + String.valueOf(mapOfSobjectList.get(currentModel).size()));
						currentFieldValue = (String)(mapOfSobjectList.get(currentModel)[recordIndex].get(currentFieldModelWrapper.fieldAPIName));
					}
					if(currentFieldValue == null && !currentFieldModelWrapper.isFirstValueBlank) {
						mapOfSobjectList.get(currentModel)[recordIndex].put(currentFieldModelWrapper.fieldAPIName, (Object)(currentFieldModelWrapper.selectOptionList[recordIndex][0].id));
						currentFieldValue = (String)(mapOfSobjectList.get(currentModel)[recordIndex].get(currentFieldModelWrapper.fieldAPIName));
					}
					if(currentFieldValue != null) {
						if(currentFieldModelWrapper.picklistDependencyMap == null || currentFieldModelWrapper.picklistDependencyMap.size() == 0) {
							depOptionList.addAll(getDependentReferenceValues(currentModel, selectedField, dependentFieldResult, currentSectionModelWrapper, currentFieldModelWrapper, modelAPI, fieldModelWrap, mapOfSobjectList, dpField, currentFieldValue, recordIndex));
						} else {
							depOptionList.addAll(getDependentPicklistValues(currentFieldValue, currentFieldModelWrapper, dpField));
						}
						if(fieldModelWrap.isControllingField) {
			                PortalPackageHelper.populateDependentField(dependentFieldResult, modelAPI, 0, mapOfSobjectList, sectionModelWrap, dependentSectionModelWrap, fieldModelWrap);   
			            }
					} 
					//populate dependent selectOptionlist. selectOptionlist[0] refers to record of index 0 of dependentFieldModelName.
					populateCurrentModelSelectOptionList(depOptionList, mapOfSobjectList, fieldModelWrap, dependentFieldModelName);
				}
			}
		}
	}
	
	//currentFieldValue is controlling field value
	private static List<ERx_PageEntities.SelectOpWrap> getDependentPicklistValues(String currentFieldValue, ERx_PageEntities.FieldModelWrapper currentFieldModelWrapper, String dpField) {
		List<String> combinedValList = currentFieldModelWrapper.picklistDependencyMap.get(dpField).split(';');
		List<ERx_PageEntities.SelectOpWrap> depOptionList = new List<ERx_PageEntities.SelectOpWrap>();
		for(String combinedVal : combinedValList) {
			List<String> dependentAndcontrollingValList = combinedVal.split('-\\$#-');
			String controllingVal = dependentAndcontrollingValList[0];
			if(controllingVal == currentFieldValue) {
				List<String> dependentValList = dependentAndcontrollingValList[1].split('#\\$#\\$');
				for(String dependentVal : dependentValList) {
					depOptionList.add(new ERx_PageEntities.SelectOpWrap(dependentVal, dependentVal));
				}
				break;
			}
		}
		return depOptionList;
	}
	
	private static void populateCurrentModelSelectOptionList (List<ERx_PageEntities.SelectOpWrap> depOptionList, Map<String, List<sObject>> mapOfSobjectList, ERx_PageEntities.FieldModelWrapper fieldModelWrap, String currentModel) {
		for(integer i = 0; i < mapOfSobjectList.get(currentModel).size(); i++) {
			if(fieldModelWrap.selectOptionList == null) {
				fieldModelWrap.selectOptionList = new List<List<ERx_PageEntities.SelectOpWrap>>();
			}
			fieldModelWrap.selectOptionList.add(depOptionList);
		}
	}
	
	private static String getModelName(ERx_PageEntities.SectionModelWrapper currentSectionModelWrapper, ERx_PageEntities.FieldModelWrapper currentFieldModelWrapper) {
		String currentModel = '';
		if(currentSectionModelWrapper.modelType == 'SECTIONMODEL') {
			currentModel = currentSectionModelWrapper.modelName;
		} else {
			currentModel = currentFieldModelWrapper.modelName;
		}
		return currentModel;
	}
	
	private static List<ERx_PageEntities.SelectOpWrap> getDependentReferenceValues(String currentModel, DescribeFieldResult selectedField, DescribeFieldResult dependentFieldResult, ERx_PageEntities.SectionModelWrapper currentSectionModelWrapper, ERx_PageEntities.FieldModelWrapper currentFieldModelWrapper, Map<String,String> modelAPI, ERx_PageEntities.FieldModelWrapper fieldModelWrap, Map<String, List<sObject>> mapOfSobjectList, String dpField, String currentFieldValue, Integer recordIndex) {
		String conditionValue = currentFieldModelWrapper.dependentCriteriaMap.get(dpField) + ' = \'' + currentFieldValue + '\'';
		String filteredCondition = PortalPackageHelper.getConditionString(selectedField, currentModel, modelAPI, recordIndex, mapOfSobjectList, fieldModelWrap.lookupRecordCriteria);
		if(!String.IsBlank(filteredCondition)) {
			conditionValue +=  ' and ' + filteredCondition;
		}
		List<SelectOption> depLookUpRecords = PortalPackageHelper.getLookUpData(dependentFieldResult, conditionValue, false);	
		List<ERx_PageEntities.SelectOpWrap> depOptionList = new List<ERx_PageEntities.SelectOpWrap>();
		for(SelectOption opt : depLookUpRecords) {
			depOptionList.add(new ERx_PageEntities.SelectOpWrap(opt.getValue(), opt.getLabel()));
		} 	
		return depOptionList;
	}
	
	public static String previousPageId(Id currentPageId) {
		try {
			EnvMode envModeObj = ERx_PortalPackUtil.getEnvModeForCurrentUser();
			Id envId = ERx_PortalPackUtil.getCurrentEnvId((envModeObj == EnvMode.Live? false : true));
			List<Erx_Page__c> pageList = [Select Name, Id, Page_Name__c from Erx_Page__c where IsActive__c = true and Env__c =: envId order by Order__c];
			for(integer i = 0; i < pageList.size(); i++) {
				if(pageList[i].Id == currentPageId && i != 0) {
					return pageList[i - 1].Id;
				} 
			}
		} catch (Exception e) {
			ERx_PortalPackUtil.logException(e);
		}
		return null;
	}
	
	public static String nextPageId(Id currentPageId) {
		try {
			EnvMode envModeObj = ERx_PortalPackUtil.getEnvModeForCurrentUser();
			Id envId = ERx_PortalPackUtil.getCurrentEnvId((envModeObj == EnvMode.Live? false : true));
			List<Erx_Page__c> pageList = [Select Name, Id, Page_Name__c from Erx_Page__c where IsActive__c = true and Env__c =: envId order by Order__c];
			Boolean isNextPageFound = false;
			for(Erx_Page__c page : pageList) {
				if(isNextPageFound) {
					return page.Id;
				}
				if(page.Id == currentPageId) {
					isNextPageFound = true;
				} 
			}
		} catch (Exception e) {
			ERx_PortalPackUtil.logException(e);
		}
		return null;
	}
	
	//returns name field of reference fields. for eg. Account.Name for AccountId field input and CustomField__r.Name for CustomField__c field input. 
	public static String  getReferenceNameField (String referenceField) {
		String referenceName = '';
		if(referenceField.toUpperCase().endsWith('ID')) {
    		referenceName = referenceField.substring(0, referenceField.length() - 2) + '.Name';
    	} else if(referenceField.toUpperCase().endsWith('__C')) {
    		referenceName = referenceField.substring(0, referenceField.length() - 3) + '__r.Name'; 
    	}
    	return referenceName;
	}
}