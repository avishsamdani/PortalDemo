public class CommunityUtility {
	public static String SELECT_CLAUSE = ' SELECT ';
    public static String WHERE_CLAUSE = ' WHERE ';
    public static String FROM_CLAUSE = ' FROM ';
    //public static String EQUAL_CLAUSE = ' = ';

	public static Id getCurrentContactId() {
        List<User> users = [SELECT user.contactId, Name from User user where user.id = :Userinfo.getUserId() and user.contactId != null];
        if(users.size() > 0){
            return users[0].contactId;
        } else {
			return null;
        }
    }

	public static Contact getCurrentContact(){
		Map<String, String> mapWhereClause = new Map<String, String>();
		mapWhereClause.put('Id=', CommunityUtility.getCurrentContactId());
		List<Contact> contacts = (List<Contact>)getObjectWithFields('Contact', mapWhereClause,null, null, null, RequiredFieldTypes.ALL_FIELDS_WITH_CUSTOM_FIELDS);
    	if(contacts.size() > 0) {
    		return contacts[0];
    	} else {
    		return null;
		}
	}

	public static Id getActiveApplicationId(){
       Id contactId = CommunityUtility.getCurrentContactId();
       if(contactId != null) {
           Contact contact = [select Id, EnrollmentrxRx__Active_Enrollment_Opportunity__c from Contact where Id =: contactId];
           return contact.EnrollmentrxRx__Active_Enrollment_Opportunity__c;                             
       }
       return null;
   }

    public static EnrollmentrxRx__Enrollment_Opportunity__c getActiveApplication() {
        EnrollmentrxRx__Enrollment_Opportunity__c application = null;
		Id activeAppId = CommunityUtility.getActiveApplicationId();
        Map<String, String> mapWhereClause = new Map<String, String>();
        mapWhereClause.put('Id=', activeAppId);
        if(activeAppId != null) {
            List<EnrollmentrxRx__Enrollment_Opportunity__c> applications = (List<EnrollmentrxRx__Enrollment_Opportunity__c>)getObjectWithFields('EnrollmentrxRx__Enrollment_Opportunity__c', mapWhereClause, null,null, null, RequiredFieldTypes.ALL_FIELDS_WITH_CUSTOM_FIELDS);
            if(applications.size() > 0) {
                application = applications[0];              
            }
        }               
        return application;
    }  

	 /****************************************************************************************
           This method returns list of all fieldSetMembers for passed object.
          @param objectName    Object Name
          @param fieldSetName    fieldset Name
          @return list of fieldset members
     *****************************************************************************************/ 
    public static List<sObject> getObjectWithFields(String objectName, Map<String,string> mapWhereClause,String OtherClause, List<schema.fieldsetmember> fieldSetValues, List<String> customFields, RequiredFieldTypes fType) {  
        String query = SELECT_CLAUSE ;
        try{            
            Map<String, Schema.SObjectType> globalDescribeMap = Schema.getGlobalDescribe(); 
            Schema.SObjectType sObjectTypeObj = globalDescribeMap.get(objectName);
            
            if(fType == RequiredFieldTypes.FIELDSET_FIELDS_CUSTOM_FIELDS || fType == RequiredFieldTypes.ALL_FIELDS || fType == RequiredFieldTypes.ALL_FIELDS_WITH_CUSTOM_FIELDS || fType == RequiredFieldTypes.ONLY_CUSTOM_FIELDS){
                if(fType == RequiredFieldTypes.ALL_FIELDS || fType == RequiredFieldTypes.ALL_FIELDS_WITH_CUSTOM_FIELDS) {
                    Schema.DescribeSObjectResult describeSObjectResultObj = sObjectTypeObj .getDescribe(); 
                    Map<String,Schema.SObjectField> fields = describeSObjectResultObj.fields.getMap() ;          
                    List<Schema.SObjectField> fieldMapValues = fields.values(); 
                    for(Schema.SObjectField field : fieldMapValues) {    
                        query += field.getDescribe().getName();                
                        query += ',';
                    }   
                }
                if(fType == RequiredFieldTypes.ALL_FIELDS_WITH_CUSTOM_FIELDS || fType == RequiredFieldTypes.ONLY_CUSTOM_FIELDS || fType == RequiredFieldTypes.FIELDSET_FIELDS_CUSTOM_FIELDS) {  
                    if(customFields != null) {
                        for(String customeField : customFields) {
                            query += customeField+','; 
                        }   
                    }   
                }
                if(fType == RequiredFieldTypes.FIELDSET_FIELDS_CUSTOM_FIELDS) {
                    for(schema.fieldsetmember f : fieldSetValues) {
                    	if(!query.contains(f.getFieldPath()+',')) {
	                    	query += f.getFieldPath() + ',';
                    	}
	                }
                }                
            } else if(fType == RequiredFieldTypes.ONLY_FIELDSET_FIELDS){
                for(schema.fieldsetmember f : fieldSetValues) {
                    if(!query.contains(f.getFieldPath()+',')) {
                    	query += f.getFieldPath() + ',';
                	}
                }
            }
            query = query.subString(0, query.length() - 1);
            query += FROM_CLAUSE + objectName;
            if(mapWhereClause.size() > 0){
                query += WHERE_CLAUSE;
                for(String fieldWithOperator : mapWhereClause.keyset()){
                    query += fieldWithOperator   + '\'' + mapWhereClause.get(fieldWithOperator) + '\'' +' AND '; 
                }
                query = query.subString(0, query.length() - 4);
            }

			if(!String.isBlank(OtherClause))
			query=query+' '+OtherClause;

            return Database.query(query);   
        } catch(Exception e) {
        	system.debug(e.getMessage() + '### query: ' + query);
            return null;
        }
    }

	/****************************************************************************************
           This method returns list of all fieldSetMembers for passed object.
          @param objectName    Object Name
          @param fieldSetName    fieldset Name
          @return list of fieldset members
     *****************************************************************************************/ 
    public static List<schema.fieldsetmember> getFields(String objectName, String fieldSetName) {  
        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(objectName);
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe(); 
        Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName);        
        return fieldSetObj.getFields();
    }
}