public with sharing class PortalFormBuilderAdminPanelPOCCtrl {
	
	private List<ObjectWrapper> objectWrapperList;
	
	public String objectWrapperListString {get;set;} 
	
	public PortalFormBuilderAdminPanelPOCCtrl() {
		objectWrapperList = new List<ObjectWrapper>();
		objectWrapperList.add(new ObjectWrapper('--None--', 'noObjectSelected')); 
		Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
		for(String objectName : schemaMap.keySet()) {
			objectWrapperList.add(new ObjectWrapper(schemaMap.get(objectName).getDescribe().getLabel(), objectName));
		}
		objectWrapperListString = JSON.serialize(objectWrapperList);
	}
	
	public class ObjectWrapper {
		public String name {get;set;}
		public String value {get;set;}
		
		public ObjectWrapper(String name, String value)	{
			this.name = name;
			this.value = value;
		}
	}
	
	@RemoteAction
	public static List<ObjectWrapper> getSelectedObjectFields(String objectName) {
		List<ObjectWrapper> fieldWrapperList = new List<ObjectWrapper>();
		Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
		Schema.SObjectType objSchema = schemaMap.get(String.valueOf(JSON.deserialize(objectName, String.class)));
		//System.assert(false, '@@@@@@@@' + objSchema);
		Map<String, Schema.SObjectField> fieldsMap = objSchema.getDescribe().fields.getMap();
		for(String fieldApiName : fieldsMap.keySet()) {
			fieldWrapperList.add(new ObjectWrapper(fieldsMap.get(fieldApiName).getDescribe().getLabel(), fieldApiName));
		}
		return fieldWrapperList;
	}
}