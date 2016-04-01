/**
 * @author : Avish Samdani (Metacube)
 * @date : 25-02-2016
 * @description : Lookup Picklist Value Controller
 * @name : PortalPackagePicklistLookupController.cls
 * @type: Controller 
 */
public with sharing class PortalPackagePicklistLookupController {
	
	private String objectName;
	private String fieldName;
	private String value;
	private List<SelectOpWrap> selectOpWrapList;
	
	public String selectOpWrapListString {get;set;}
	public Integer index {get;set;}
	public String type {get;set;}
	public boolean isMultiSelect {get;set;}
	
	// Default Constructor
	public PortalPackagePicklistLookupController() {
		selectOpWrapList = new List<SelectOpWrap>();
		// Getting url parameters values.
		objectName = ApexPages.currentPage().getParameters().get('objectName');
		fieldName = ApexPages.currentPage().getParameters().get('fieldName');
		value = ApexPages.currentPage().getParameters().get('fieldValue');
		index = Integer.valueOf(ApexPages.currentPage().getParameters().get('index'));
		type = ApexPages.currentPage().getParameters().get('type');
		isMultiSelect = Boolean.valueOf(ApexPages.currentPage().getParameters().get('isMultiSelect'));
		List<String> valueList = new List<String>();
		if(value != null && value != '') {
			valueList = value.split(',');
		}
		Map < String, Schema.SObjectType > GlobalDescribeMap = Schema.getGlobalDescribe();
		Schema.SObjectField objField = GlobalDescribeMap.get(objectName).getDescribe().fields.getMap().get(fieldName);
		if(objField != null) {
			Schema.DescribeFieldResult fieldResult = objField.getDescribe();
			// Getting All Picklist Values
			List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
			for( Schema.PicklistEntry f : ple) {
	      		selectOpWrapList.add(new SelectOpWrap(f.getLabel(), f.getValue(), PortalPackageUtility.isElementFoundInList(valueList, f.getValue())));
		   	}
		}
		selectOpWrapListString = JSON.serialize(selectOpWrapList);
	}
	
	/**
	 * @author : Avish Samdani (Metacube)
	 * @date : 25-02-2016
	 * @description : Select Option Wrapper.
	 * @name : PortalPackagePicklistLookupController.cls
	 * @type: Wrapper Class 
	 */
	private class SelectOpWrap {
		private String label;
		private String value;
		private boolean isChecked;
		
		public SelectOpWrap(String label, String value, boolean isChecked) {
			this.label = label;
			this.value = value;
			this.isChecked = isChecked;
		}
		
	}
}