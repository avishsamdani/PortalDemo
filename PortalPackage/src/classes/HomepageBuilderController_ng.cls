public class HomepageBuilderController_ng{
	//sobjects
	//public String hwlListJSON{get;set;}
	
	//sobjectsDescribe
	public String hwlDescribeJSON{get;set;}

    public HomepageBuilderController_ng(ngForceController ngcon) {
		//hwlList
        //List<Homepage_Widget_Layout__c> hwlList=[select //Id,Name,Is_Active__c,Displaying_Application_Status__c,Program_Catalog__c,Program_Catalog__r.Name,Env__r.Name,Env__r.Env_Status__c  from Homepage_Widget_Layout__c];
        //hwlListJSON=String.escapeSingleQuotes(JSON.serialize(hwlList));

		//hwlDescribe
		hwlDescribeJSON=String.escapeSingleQuotes(ngForceController.describe('Homepage_Widget_Layout__c'));
    }

        //get all Envs
	
    public string getEnvId(){
        
        return ERx_PortalPackUtil.getCurrentEnvForConfiguration().Env__c;
    }	
	
}