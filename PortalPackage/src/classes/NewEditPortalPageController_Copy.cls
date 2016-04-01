/**
 * @author : Avish Samdani (Metacube)
 * @date : 25-01-2016
 * @description : Admin Panel Controller class to configure page using drag and drop No Code.
 * @name : NewEditPortalPageController.cls
 * @type: Controller 
 */
public with sharing class NewEditPortalPageController_Copy {
	
	// Private Data Members of the NewEditPortalPageController Class
	private Map < String, Schema.SObjectType > GlobalDescribeMap = null; // Global Describe Map to Store Database schema.
    private Map<String, Schema.SObjectField> objFieldMap = null;
    private String packageName;
    private List<ObjectFieldWrapper> objectFieldList = null;
    
    // Public+ Data Members of the NewEditPortalPageController Class
    public String pageId{get;set;}
    public String objectFieldListString {get;set;}
    public String operatorListString {get;set;}
    public String selectedModelListString {get;set;}
    public String sectionWrapperMapString {get;set;}
    public String pageHeader {get;set;}
    public String fieldInstructionPositionListString {get;set;}
    public String uploadSourceListString {get;set;}
    public String criteriaConditionSourceListString {get;set;}
    public String uploadSupportedFilesListString {get;set;}
    public String uploadFileSizeList {get;set;}
    public String referenceFieldTypeStringList {get;set;}
    public String requiredSymbols {get;set;}
    public String typeOperatorListMap {get;set;}
    public String globalVarMapString {get;set;}
    public String pageName {get;set;}
    
    public String getPrefix {get;set;}
    
    // Error Message on Page.
    public String errorMessage {get;set;}
    
    // Default Constructor
	public NewEditPortalPageController_Copy() {
		// Creating New Object Field Wrapper List Instance.
		objectFieldList = new List<ObjectFieldWrapper>();
		// Getting All Objects.
		GlobalDescribeMap = Schema.getGlobalDescribe();
        List<FieldObjectWrapper> fieldList = null;
        for(String globalDesc : GlobalDescribeMap.keySet()) {
        	fieldList = new List<FieldObjectWrapper>();
    		objFieldMap = GlobalDescribeMap.get(globalDesc).getDescribe().fields.getMap(); // Getting All Fields Map of Object.
    		if(objFieldMap != null && !objFieldMap.isEmpty()) {
    			for(String field : objFieldMap.keySet()) {
    				if(objFieldMap.get(field).getDescribe().isAccessible()) { // Checking if Object is Accessible
    					// Add Field to the Object Related list
						fieldList.add(new FieldObjectWrapper(objFieldMap.get(field).getDescribe().getLabel(), objFieldMap.get(field).getDescribe().getName(), 
										(String.valueOf(objFieldMap.get(field).getDescribe().getType()) == 'TEXTAREA' && objFieldMap.get(field).getDescribe().isHtmlFormatted() ? PortalPackageConstants.RICH_TEXT_AREA : String.valueOf(objFieldMap.get(field).getDescribe().getType())), 
										false, (String.valueOf(objFieldMap.get(field).getDescribe().getType()) == 'PICKLIST' && objFieldMap.get(field).getDescribe().isDependentPicklist()), (String.valueOf(objFieldMap.get(field).getDescribe().getType()) == 'PICKLIST' && objFieldMap.get(field).getDescribe().isDependentPicklist() ? String.valueOf(objFieldMap.get(field).getDescribe().getController()) : null), false, objFieldMap.get(field).getDescribe().isCalculated()));
    				}
    			}
    		}
    		fieldList.sort();
        	objectFieldList.add(new ObjectFieldWrapper(GlobalDescribeMap.get(globalDesc).getDescribe().getLabel(), GlobalDescribeMap.get(globalDesc).getDescribe().getName(), fieldList));
        }
        // Sorting Object List
        objectFieldList.sort();
        objectFieldListString = JSON.serialize(objectFieldList);
        // Serializing the List into Strings.
        operatorListString = JSON.serialize(PortalPackageConstants.OPERATOR_LIST);
        fieldInstructionPositionListString = JSON.serialize(PortalPackageConstants.FIELD_INSTRUCTION_POSITIONS);
        uploadSourceListString = JSON.serialize(PortalPackageConstants.UPLOAD_SOURCE_LIST);
        criteriaConditionSourceListString = JSON.serialize(PortalPackageConstants.CRITERIA_CONDITION_SOURCE_LIST);
        uploadSupportedFilesListString = JSON.serialize(PortalPackageConstants.UPLOAD_SUPPORTED_FILES);
        uploadFileSizeList = JSON.serialize(PortalPackageConstants.FILE_SIZE_DATA_LIMITS);
        referenceFieldTypeStringList = JSON.serialize(PortalPackageConstants.REFERENCE_FIELD_TYPE);
        requiredSymbols = JSON.serialize(PortalPackageConstants.REQUIRED_SYMBOL_LIST);
        typeOperatorListMap = JSON.serialize(PortalPackageConstants.TYPE_OPERATOR_LIST_MAP);
        globalVarMapString = JSON.serialize(PortalPackageConstants.GLOBAL_VAR_MAP);
        
        pageId = ApexPages.currentPage().getParameters().get('pageId');
        
        selectedModelListString = JSON.serialize(new List<String>());
        sectionWrapperMapString = '{}';
        pageHeader = '{}';
        getPrefix = PortalPackageUtility.getNameSpacePerfix();
        
        if(pageId != null) {
        	try {
        		// Getting Page & Sections Details
        		Erx_Page__c page = [SELECT Page_Header__c, Page_Name__c, (SELECT Modal_Data__c, View_Layout__c from Erx_Sections__r order by Order__c) from Erx_Page__c where ID = :pageId];
        		// Setting Page Header String
        		pageHeader = page.Page_Header__c == null ? pageHeader : page.Page_Header__c;
        		pageName = page.Page_Name__c;
        		// Setting Model Data and Section Map Data.
    			setModelListStringBySectionList(page.Erx_Sections__r);
        	} catch(Exception e) {
        		// When Any Error Occurs Returning a Error Message.
        		errorMessage = PortalPackageConstants.INVALID_PAGE_ID_ERROR_MESSAGE;
        	}
        } else {
        	errorMessage = PortalPackageConstants.INVALID_PAGE_ERROR_MESSAGE; // Page Id Null then Not Allow User to Configure Page.
        }
	}
	
	// Method to Set Model Data and Section Map Data.
	private void setModelListStringBySectionList(List<Erx_Section__c> sectionList) {
		try {
			Map<String, ERx_PageEntities.WrapperModel> modelWrapperMap = new Map<String, ERx_PageEntities.WrapperModel>();
			List<ERx_PageEntities.SectionModelWrapper> sectionWrapperList = new List<ERx_PageEntities.SectionModelWrapper>();
			Map<Integer, ERx_PageEntities.SectionModelWrapper> sectionWrapperMap = new Map<Integer, ERx_PageEntities.SectionModelWrapper>();
			// Creating Map for Section, Section List & model Wrapper Map.
			for(Erx_Section__c section : sectionList) {
				List<ERx_PageEntities.WrapperModel> modelWrapperList = (List<ERx_PageEntities.WrapperModel>) JSON.deserialize(section.Modal_Data__c, List<ERx_PageEntities.WrapperModel>.class);
				for(ERx_PageEntities.WrapperModel modelWrapper : modelWrapperList) {
					ModelWrapperMap.put(modelWrapper.modelName, modelWrapper);
				}
				sectionWrapperList.add((ERx_PageEntities.SectionModelWrapper) JSON.deserialize(section.View_Layout__c, ERx_PageEntities.SectionModelWrapper.class));
				sectionWrapperMap.put(((ERx_PageEntities.SectionModelWrapper) JSON.deserialize(section.View_Layout__c, ERx_PageEntities.SectionModelWrapper.class)).sectionOrder, (ERx_PageEntities.SectionModelWrapper) JSON.deserialize(section.View_Layout__c, ERx_PageEntities.SectionModelWrapper.class));
			}
			// Creating List of Section Removing Used Data on Sections. and Create a LIst of Model Data.
			//System.assert(false, modelWrapperMap.keySet());
			for(String key : modelWrapperMap.keySet()) {
				for (Integer i = (modelWrapperMap.get(key).field.size()-1); i>= 0; i--){
					ERx_PageEntities.ModelFieldObjectWrapper modelFieldObjectWrapper = modelWrapperMap.get(key).field[i];
					for(ERx_PageEntities.SectionModelWrapper sectionWrapper : sectionWrapperList) {
						for(ERx_PageEntities.FieldModelWrapper layoutFieldObjectWrapper : sectionWrapper.field) {
							if((key == sectionWrapper.modelName || key == layoutFieldObjectWrapper.modelName) && (modelFieldObjectWrapper.fieldAPIName == layoutFieldObjectWrapper.fieldAPIName)) {
								modelWrapperMap.get(key).field.remove(i);
							}
						}
					}
				}
			}
			List<ERx_PageEntities.WrapperModel> modelWrapperList = new List<ERx_PageEntities.WrapperModel>();
			for(String key : modelWrapperMap.keySet()) {
				modelWrapperList.add(modelWrapperMap.get(key));
			}
			// Creating JSOn Data for Model Data and Section Data.
			selectedModelListString = JSON.serialize(modelWrapperList);
			sectionWrapperMapString = JSON.serialize(sectionWrapperMap);
		} catch(Exception e) {
			System.assert(false, e);
			errorMessage = PortalPackageConstants.SOME_THING_WENT_WRONG_ERROR_MESSAGE;
		}
	}
	
	// Function to Save Page Data
	@RemoteAction
	public static String saveData(String modelData, String pageHeaderString, String sectionPageId) {
		String returnString = 'Page has been saved successfully.';
		try {
			// Creating a List of Page Wrapper
			List<Live_Env__c> liveEnviromentList = [select ID from Live_Env__c where Env__c in (select Env__c from Erx_Page__c where id = :sectionPageId)];
			if(liveEnviromentList == null || liveEnviromentList.size() == 0) {
				String pageHeaderJsonString = null;
				if(((ERx_PageEntities.PageHeaderWrapper) JSON.deserialize(pageHeaderString, ERx_PageEntities.PageHeaderWrapper.class)).title != null) {
					pageHeaderJsonString = pageHeaderString;
				}
				//System.assert(false, '-----' + JSON.deserialize(pageHeaderString, PageHeaderWrapper.class));
				List<PageWrapper> pageWrapperList = (List<PageWrapper>) JSON.deserialize(modelData, List<PageWrapper>.class);
				List<Erx_Section__c> sectionList = new List<Erx_Section__c>();
				// Creating sections using Page Wrapper List.
				for(PageWrapper pageWrapper : pageWrapperList) {
					Erx_Section__c section = new Erx_Section__c();
					section.Modal_Data__c = JSON.serialize(pageWrapper.modelDataList);
					section.Order__c = Decimal.valueOf(pageWrapper.jsonData.sectionOrder);
					section.View_Layout__c = JSON.serialize(pageWrapper.jsonData);
					section.Erx_Page__c = sectionPageId;
					sectionList.add(section);
				}
				// Delete Previous Section Data Related to that Page.
				Erx_Page__c page = [SELECT Page_Header__c, (SELECT Modal_Data__c, View_Layout__c from Erx_Sections__r order by Order__c) from Erx_Page__c where ID = :sectionPageId];
				delete page.Erx_Sections__r;
			
				// Updating Page Header.
				page.Page_Header__c = pageHeaderJsonString;
				update page;
			
				// Inserting New Sections Data.
				insert sectionList;
				//System.assert(false, pageWrapperList);
			} else {
				throw new PortalPackageException('You can not modify. Related App is live.');
			}
		} catch(Exception e) {
			returnString = e.getMessage();
		}
		
		return returnString;
	}
	
	/**
	* Method to get all the fields of reference field.
	*
	*/
	@RemoteAction
	public static List<ERx_PageEntities.ConditionFieldObjectWrapper> getLookupCriteriaFieldName(String dependentObjectAPIName, String controllingObjectAPIName, String dependentFieldAPIName, String controllingFieldAPIName) {
		List<ERx_PageEntities.ConditionFieldObjectWrapper> fieldObjectWrapperList = new List<ERx_PageEntities.ConditionFieldObjectWrapper>();
		ERx_PageEntities.ConditionFieldObjectWrapper fieldObjectWrapper;
		Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
		Schema.SObjectType objectSchema = schemaMap.get(dependentObjectAPIName);
		List<Schema.SObjectType> referencedObjectSchemaList;
		Schema.SObjectType referencedObjectSchema;
		String dependentObjectName;
		String controllingObjectname;
		if(objectSchema != null) {
			// Setting dependent object name.
			referencedObjectSchemaList = objectSchema.getDescribe().fields.getMap().get(dependentFieldAPIName).getDescribe().getReferenceTo();
			if(referencedObjectSchemaList != null && referencedObjectSchemaList.size() > 0) {
				referencedObjectSchema = referencedObjectSchemaList.get(0);
				dependentObjectName = referencedObjectSchema.getDescribe().getName();
			}
		}
		// If Controlling Object is not Equal to Dependent Object.
		if(dependentObjectAPIName != controllingObjectAPIName) {
			objectSchema = schemaMap.get(controllingObjectAPIName);
		}
		if(objectSchema != null) {
			// Setting controlling object name.
			referencedObjectSchemaList = objectSchema.getDescribe().fields.getMap().get(controllingFieldAPIName).getDescribe().getReferenceTo();
			if(referencedObjectSchemaList != null && referencedObjectSchemaList.size() > 0) {
				referencedObjectSchema = referencedObjectSchemaList.get(0);
				controllingObjectname = referencedObjectSchema.getDescribe().getName();
			}
		}
		if(controllingObjectname != null && dependentObjectName != null) {
			objectSchema = schemaMap.get(dependentObjectName);
			Map<String, Schema.SObjectField> fieldMap = objectSchema.getDescribe().fields.getMap();
			for(String field : fieldMap.keySet()) {
				if(String.valueOf(fieldMap.get(field).getDescribe().getType()).toUpperCase() == 'REFERENCE') {
					referencedObjectSchemaList = fieldMap.get(field).getDescribe().getReferenceTo();
					if(referencedObjectSchemaList != null && referencedObjectSchemaList.size() > 0) {
						referencedObjectSchema = referencedObjectSchemaList.get(0);
						if(referencedObjectSchema.getDescribe().getName().toUpperCase() == controllingObjectname.toUpperCase()) {
							fieldObjectWrapper = new ERx_PageEntities.ConditionFieldObjectWrapper();
							fieldObjectWrapper.fieldName = fieldMap.get(field).getDescribe().getLabel();
							fieldObjectWrapper.fieldAPIName = fieldMap.get(field).getDescribe().getName();
							fieldObjectWrapper.fieldDisplayType = String.valueOf(fieldMap.get(field).getDescribe().getType());
							fieldObjectWrapperList.add(fieldObjectWrapper);
						}
					}
				}
			}
		}
		return fieldObjectWrapperList;		
	}
	
	/**
	* Method to get all the fields for reference type field.
	*
	*/
	@RemoteAction
	public static Map<String, List<ERx_PageEntities.ConditionFieldObjectWrapper>> getCriteriaFieldsForSelected(String controllingObjectAPIName, String controllingFieldAPIName) {
		Map<String, List<ERx_PageEntities.ConditionFieldObjectWrapper>> fieldObjectWrapperMap = new Map<String, List<ERx_PageEntities.ConditionFieldObjectWrapper>>();
		List<ERx_PageEntities.ConditionFieldObjectWrapper> fieldObjectWrapperList = new List<ERx_PageEntities.ConditionFieldObjectWrapper>();
		ERx_PageEntities.ConditionFieldObjectWrapper fieldObjectWrapper;
		fieldObjectWrapper = new ERx_PageEntities.ConditionFieldObjectWrapper();
		fieldObjectWrapper.fieldName = '--None--';
		fieldObjectWrapper.fieldAPIName = '';
		fieldObjectWrapperList.add(fieldObjectWrapper);
		// Getting salesforce schema map.
		Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
		//fetching object details
		Schema.SObjectType objectSchema = schemaMap.get(controllingObjectAPIName);
		List<Schema.SObjectType> referencedObjectSchemaList;
		Schema.SObjectType referencedObjectSchema;
		String controllingObjectname;
		if(objectSchema != null) {
			// Fetching reference object name.
			referencedObjectSchemaList = objectSchema.getDescribe().fields.getMap().get(controllingFieldAPIName).getDescribe().getReferenceTo();
			if(referencedObjectSchemaList != null && referencedObjectSchemaList.size() > 0) {
				referencedObjectSchema = referencedObjectSchemaList.get(0);
				controllingObjectname = referencedObjectSchema.getDescribe().getName();
			}
		}
		
		if(controllingObjectname != null) {
			// Fetching all reference object details
			objectSchema = schemaMap.get(controllingObjectname);
			// Fetching all the fields
			Map<String, Schema.SObjectField> fieldMap = objectSchema.getDescribe().fields.getMap();
			for(String field : fieldMap.keySet()) {
				if(String.valueOf(fieldMap.get(field).getDescribe().getType()).toUpperCase() != 'TEXTAREA' && String.valueOf(fieldMap.get(field).getDescribe().getType()).toUpperCase() != 'ID') {
					fieldObjectWrapper = new ERx_PageEntities.ConditionFieldObjectWrapper();
					fieldObjectWrapper.fieldName = fieldMap.get(field).getDescribe().getLabel();
					fieldObjectWrapper.fieldAPIName = fieldMap.get(field).getDescribe().getName();
					fieldObjectWrapper.fieldDisplayType = String.valueOf(fieldMap.get(field).getDescribe().getType());
					fieldObjectWrapperList.add(fieldObjectWrapper);
				}
			}
			fieldObjectWrapperMap.put(controllingObjectname, fieldObjectWrapperList);
		}
		return fieldObjectWrapperMap;		
	}
	
	/**
	* Method to used to get picklist values dependent map.
	*
	*/
	@RemoteAction
	public static Map<String, List<DependencyFieldWrapper>> getDependencyMapWrapper(String dependentObjectName, String controllingObjectName, String dependentFieldName, String controllingFieldName) {
		Map<String, List<DependencyFieldWrapper>> dependencyMap = new Map<String, List<DependencyFieldWrapper>>();
		Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
		Schema.SObjectType objectSchema = schemaMap.get(controllingObjectName);
		List<Schema.PicklistEntry> controllingPicklistValues;
		List<Schema.PicklistEntry> dependentPicklistValues;
		if(objectSchema != null) {
			controllingPicklistValues = objectSchema.getDescribe().fields.getMap().get(controllingFieldName).getDescribe().getPicklistValues();
		}
		if(controllingObjectName != dependentObjectName) {
			objectSchema = schemaMap.get(dependentObjectName);
		}
		if(objectSchema != null) {
			dependentPicklistValues = objectSchema.getDescribe().fields.getMap().get(dependentFieldName).getDescribe().getPicklistValues();
		}
		List<DependencyFieldWrapper> dependencyList = new List<DependencyFieldWrapper>();
		if(dependentPicklistValues != null) {
			for(Schema.PicklistEntry dependentPicklistValue: dependentPicklistValues) {
				dependencyList.add(new DependencyFieldWrapper(dependentPicklistValue.getValue(), false));
			}
		}
		if(controllingPicklistValues != null) {
			for(Schema.PicklistEntry controllingPicklistValue : controllingPicklistValues) {
				List<DependencyFieldWrapper> dependencyList1 = new List<DependencyFieldWrapper>();
				dependencyList1.addAll(dependencyList);
				// Putting the all the controlling picklist value and list of dependent field list.
				dependencyMap.put(controllingPicklistValue.getValue(), dependencyList1);
			}
		}
		return dependencyMap;
	}
	
	/**
	* Method returns the object name for reference type field.
	*
	*/
	@RemoteAction
	public static String getSelectedObjectTypeByField(String objectName, String fieldName) {
		Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
		List<Schema.SObjectType> referencedObjectSchemaList = schemaMap.get(objectName).getDescribe().fields.getMap().get(fieldName).getDescribe().getReferenceTo();
		if(referencedObjectSchemaList != null && referencedObjectSchemaList.size() > 0) {
			return referencedObjectSchemaList.get(0).getDescribe().getName();
		}		
		return null;
	}
	
	/**
	* Method returns the list of object value.
	*
	*/
	@RemoteAction
	public static List<sObject> getLookupRecords(String objectName, String searchString, String sobjectType) {
		String query = '';
		if(objectName == 'RecordType'){
			query = 'Select ID, name from ' + objectName + getWhereConditionClause(searchString)+ ' AND SObjectType=\'' + sobjectType +'\'' + ' limit 8';
		}else{
			query = 'Select ID, name from ' + objectName + getWhereConditionClause(searchString) + ' limit 8';
		}
	//	system.assert(false, query);
		List<sObject> recordList = Database.query(query);
	
		return recordList;
	}
	
	// Method that is used to create where condition.
	private static String getWhereConditionClause(String searchString) {
		String tempStr = '';
		for(String conditionValue : searchString.trim().split(' ')) {
	        if(conditionValue != '') {
	            tempStr += ' Name like ' + '\'%' + PortalPackageUtility.escapeQuotes(conditionValue.trim()) + '%\'' + ' OR ';
	        }
	    }
	    
	    if(tempStr != '') {
            tempStr = tempStr.trim().subString(0,tempStr.length()-4);
        }
        
        return ' where (' + tempStr + ')';		
	}
	
	/**
	 * @author : Avish Samdani (Metacube)
	 * @date : 25-02-2016
	 * @description : Wrapper Class for Object and Field.
	 * @name : ObjectFieldWrapper.cls
	 * @type: Wrapper Class 
	 */
	public class ObjectFieldWrapper implements Comparable{
		public String objectName {get;set;} // Object Label
		public String objectAPIName {get;set;} // Object API Name
		public List<FieldObjectWrapper> fieldList {get;set;} // Field List.
		
		public ObjectFieldWrapper(String objectName, String objectAPIName, List<FieldObjectWrapper> fieldList) {
			this.objectName = objectName;
			this.objectAPIName = objectAPIName;
			this.fieldList = fieldList;
		}
		
		public Integer compareTo(Object compareTo) {
	        ObjectFieldWrapper compareItem = (ObjectFieldWrapper)compareTo;
	        if (objectName == compareItem.objectName) return 0;
	        if (objectName > compareItem.objectName) return 1;
	        return -1;        
   		}
	}
	
	/**
	 * @author : Avish Samdani (Metacube)
	 * @date : 25-02-2016
	 * @description : Wrapper Class for field..
	 * @name : FieldObjectWrapper.cls
	 * @type: Wrapper Class 
	 */
	public class FieldObjectWrapper implements Comparable{
		private String fieldName; // Field Name
		private String fieldAPIName; // Field API Name
		private String fieldDisplayType; // Field Type
		private Boolean isChecked; // Is Checked or Not
		private Boolean isBackendDependentField; // Is Picklist is Backend Dependent or Not ? 
		private String backendControllingFieldName; // Is isBackendDependentField true then controlling field name;
		private boolean isDisabled;
		private boolean isFormulaField;
		
		public FieldObjectWrapper(String fieldName, String fieldAPIName, String fieldDisplayType, Boolean isChecked, Boolean isBackendDependentField, String backendControllingFieldName, boolean isDisabled, boolean isFormulaField) {
			this.fieldName = fieldName;
			this.fieldAPIName = fieldAPIName;
			this.fieldDisplayType = fieldDisplayType;
			this.isChecked = isChecked;
			this.isBackendDependentField = isBackendDependentField;
			this.backendControllingFieldName = backendControllingFieldName;
			this.isDisabled = isDisabled;
			this.isFormulaField = isFormulaField;
		}
		
		public Integer compareTo(Object compareTo) {
	        FieldObjectWrapper compareItem = (FieldObjectWrapper)compareTo;
	        if (fieldName == compareItem.fieldName) return 0;
	        if (fieldName > compareItem.fieldName) return 1;
	        return -1;        
   		}
	}
	
	/**
	 * @author : Avish Samdani (Metacube)
	 * @date : 25-02-2016
	 * @description : Page Wrapper Class to Hold the Page Data.
	 * @name : PageWrapper.cls
	 * @type: Wrapper Class 
	 */
	private class PageWrapper {
		private List<ERx_PageEntities.WrapperModel> modelDataList; // Model Data List.
		private ERx_PageEntities.SectionModelWrapper jsonData; // Section Data.
	}
	
	/**
	 * @author : Avish Samdani (Metacube)
	 * @date : 25-02-2016
	 * @description : Dependency Field Wrapper
	 * @name : DependencyFieldWrapper.cls
	 * @type: Wrapper Class 
	 */
	private class DependencyFieldWrapper {
		private String value;
		private boolean isChecked;
		
		public DependencyFieldWrapper(String value, boolean isChecked) {
			this.value = value;
			this.isChecked = isChecked;
		}
	}
}