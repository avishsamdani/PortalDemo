public with sharing class ERx_PageEntities {
	public class SelectOpWrap{
        public String id {get;set;}
        public String name {get;set;}
        public SelectOpWrap(String id ,String name){ 
            this.id = id;
            this.name = name;
        }
    }
    
    public class SectionModelWrapper { 
        public String title {get;set;}
        public String modelName {get;set;}
        public String modelType {get;set;}   //FIELDMODEL or SECTIONMODEL
        public List<FieldModelWrapper> field {get;set;}
        public String sectionLayout {get;set;}
        public boolean isAddAnother {get;set;}
        public String addAnotherButtonLabel {get;set;}
        public String removeButtonLabel {get;set;}
        public Integer addAnotherLimit {get;set;}
        public Integer sectionOrder {get;set;}
        public String sectionCollapsible {get;set;}
        public String description; // Description of Section. 
     	public String fontSize; 
      	public String fontColor; 
       	public String sectionBorder; 
        public String fontWeight; 
     	public String fontFamily; 
      	public String backgroundColor; 
       	public String fontStyle; 
    }
    
    public class FieldModelWrapper {
        public String required {get;set;}
        public boolean isBlank {get;set;}
        public String fieldDisplayType {get;set;}
        public String type {get;set;}
        public String label {get;set;}
        public Boolean rendered {get;set;}
        public String rendredExpression {get;set;} //used on execution page
        public String requiredExpressionFinal {get;set;} //used on execution page
        public List<RenderedRequiredConditionWrapper> renderCriteriaList {get;set;}
        public List<RenderedRequiredConditionWrapper> requiredCriteriaList {get;set;}
        public String renderedExpression {get;set;}
        public String requiredExpression {get;set;}
        public String requiredSymbol {get;set;}
        public String requiredErrorMessage {get;set;}
        public String fieldName {get;set;}
        public String fieldAPIName {get;set;}
        public String instructionText {get;set;}
        public String instructionTextPosition {get;set;} // This may be label-top, label-bottom, label-right, label-left, field-left, field-right, field-top, field-bottom
        public String placeholderText; // Field Placeholder Text
        public String modelName {get;set;}
        public String hoverText {get;set;}
        public Boolean isBackendDependentField {get;set;}
        public String backendControllingFieldName {get;set;}
        public String regexValidationPattern {get;set;}
        public String regexValidationErrorMessage {get;set;}
        
        public String lookupNameObject{get;set;}
        public List<List<SelectOpWrap>> selectOptionList{get;set;}
        public List<SelectOpWrap> displayValueAPIName {get;set;}
        public List<SelectOpWrap> lookupValueList {get;set;} 
        public List<List<String>> availableValues{get;set;} //for multi pick list
        public List<List<String>> selectedValues{get;set;} 
        
        //used only when file type is upload. 
        public String parentIdSource {get;set;} //possible values are static, model, param
        public String parentId {get;set;} 
        public Boolean multiple {get;set;} //whether file type is multiple or not
        public String allowedContentType {get;set;} // List of formats eg. jpg,png,txt,java.
        public Integer maximumsize {get;set;} // in bytes.
        
        public Boolean isControllingField {get;set;}
        public Map<String, String> dependentCriteriaMap {get;set;} // Map Contains Dependent Field Name with Model Name (split on (----) On 0th Position Get Model Name and 1th position Field Name) and Criteria Field Name. 
        public Boolean isdependentField {get;set;}
        public List<ConditionWrapper> lookupRecordCriteria {get;set;}
        public Boolean isFirstValueBlank {get;set;}
        public String customPicklistValues {get;set;} // List of values to display as picklist values. These values must be semicolon separated. for eg. List of cities as - Jaipur; Ajmer; Mumbai 
        public Map<String, String> picklistDependencyMap {get;set;} // Map Contains Dependent Field Name with Model Name (split on (----) On 0th Position Get Model Name and 1th position Field Name) and Their Dependency Map String (;) Seperated and (ControllingFieldValue-$#-DependentFieldValue With #$#$)
        
        /*
        public FieldModelWrapper(boolean required, boolean isBlank, String type, String label, String rendered,String APIName,Integer columnNo, String parentType, String staticParentId) {
            this.required = required;  
            this.isBlank = isBlank;
            this.type = type;
            this.label = label;
            this.rendered = rendered;
            this.APIName = APIName;
            this.columnNo = columnNo;
            this.parentType = parentType;
            this.staticParentId = staticParentId;
        }*/
    }
    
    public class WrapperModel {
        public String modelName {get;set;}
        public String objectName {get;set;}
        public String objectAPIName {get;set;}
        public List<ModelFieldObjectWrapper> field {get;set;}
        public List<ModelCriteriaConditionWrapper> condition {get;set;}
        public String conditionExpression {get;set;}
        
        /*
        public WrapperModel(String modelName, String objectAPIName, List<ModelFieldObjectWrapper> field, String condition) {
            this.modelName = modelName;  
            this.objectAPIName = objectAPIName;
            this.field = field;
            this.condition = condition; 
        }*/
    }
    
    // Wrapper Class for Model Fields
	public class ModelFieldObjectWrapper {
		public String fieldName; // Field Name
		public String fieldAPIName; // Field API Name
	}
	
	// Wrapper Class for Model Fields
	public class ConditionFieldObjectWrapper {
		public String fieldName; // Field Name
		public String fieldAPIName; // Field API Name
		public String fieldDisplayType; // Field Type
	}
    
    public class AttachmentWrapper {
    	public String fileId {get;set;}
    	public String parentId {get;set;}
    	public String attachmentName {get;set;}
    	public String description {get;set;}
    	public String createdDate {get;set;}
    	
    	public AttachmentWrapper(String fileId, String parentId, String attachmentName, String description, String createdDate) {
    		this.fileId = fileId;
    		this.parentId = parentId;
    		this.attachmentName = attachmentName; 
    		this.description = description;
    		this.createdDate = createdDate;
    	}
    	
    	public AttachmentWrapper() {
    		this.fileId = '';
    		this.parentId = '';
    		this.attachmentName = '';
    		this.description = '';
    		this.createdDate = '';
    	}
    }
    
    public class PageWrapper { 
    	public String pageName {get;set;}
    	public List<SectionModelWrapper> sectionList {get;set;}
    }
    
    // Wrapper Class for Page Header.
	public class PageHeaderWrapper {
		public String title {get;set;} // Page Header Title
		public String description {get;set;} // Page Header Description.
	}
	
	public class ConditionWrapper {
		public String fieldAPIName {get;set;}
		public String fieldDisplayType {get;set;}
		public String fieldOperator {get;set;}
		public String valueType {get;set;}
		public String value {get;set;}
		public String modelName {get;set;}
		public String referencedObjectName {get;set;}
		public String displayValue {get;set;}
	}
	
	public class RenderedRequiredConditionWrapper {
		public String modelName {get;set;}
		public String fieldAPIName {get;set;}
		public String fieldDisplayType {get;set;}
		public String displayValue {get;set;}
		public String value {get;set;}
		public String fieldOperator {get;set;}
		public String referencedObjectName {get;set;}		
	}
	
	public class ModelCriteriaConditionWrapper {
		public String fieldAPIName {get;set;}
		public String fieldDisplayType {get;set;}
		public String fieldOperator {get;set;}
		public String valueType {get;set;}
		public String value {get;set;}
		public String modelName {get;set;}
		public String referencedObjectName {get;set;}
		public String displayValue {get;set;}
		public Boolean isFormulaField {get;set;}
	}
}