public class HomepageController{ 
    //sobject
    public String hwlJSON{get;set;}
	public String contactJSON{get;set;}
	public String applicationJSON{get;set;}

    public HomepageController(ngForceController ngcon){
		Env__c env=[select Id from Env__c where Name='Applicant Portal' and Env_Status__c='Live'];
		
		Map<String, String> mapWhereClause = new Map<String, String>();
		List<String> customFields = new List<String>();

		//contact
		mapWhereClause.clear();
		customFields.clear();
		mapWhereClause.put('Id=', CommunityUtility.getCurrentContactId());
		
		Contact contact=(Contact)CommunityUtility.getObjectWithFields('Contact', mapWhereClause, null,null, customFields, RequiredFieldTypes.ALL_FIELDS_WITH_CUSTOM_FIELDS)[0];
		contactJSON=String.escapeSingleQuotes(JSON.serialize(contact));

		 //application
		mapWhereClause.clear();
		customFields.clear();
		mapWhereClause.put('Id=', contact.EnrollmentrxRx__Active_Enrollment_Opportunity__c);
		//customFields.add('Program_Offered__r.Name');

		EnrollmentrxRx__Enrollment_Opportunity__c application=(EnrollmentrxRx__Enrollment_Opportunity__c)CommunityUtility.getObjectWithFields('EnrollmentrxRx__Enrollment_Opportunity__c', mapWhereClause, null,null, customFields, RequiredFieldTypes.ALL_FIELDS_WITH_CUSTOM_FIELDS)[0];
		applicationJSON=String.escapeSingleQuotes(JSON.serialize(application));


		//hwl
        String query='select Id,Name,Grid_Data__c,Grid_Width__c from Homepage_Widget_Layout__c ';
        query+='where Is_Active__c=true and Env__c=\'' + env.Id + '\' and Displaying_Application_Status__c INCLUDES (\'' + application.EnrollmentrxRx__Admissions_Status__c + '\') limit 1';

		Homepage_Widget_Layout__c hwl=(Homepage_Widget_Layout__c)Database.query(query)[0];
        hwlJSON=String.escapeSingleQuotes(JSON.serialize(hwl));

    }
}