public class Portal_EnvPanelController {
    public String envIdx {get;set;}
    public String envTypex {get;set;}

	//public List<Env__c> entityList {get;set;}
	public Current_Env__c getCurrentEnv(){
        return ERx_PortalPackUtil.getCurrentEnvForConfiguration();
    
    }


	public Portal_EnvPanelController() {
		//currentEnv = ERx_PortalPackUtil.getCurrentEnvForConfiguration();
	}

	//retrieve all entity
    public List<Env__c> getEntityListAll(){
        List<Env__c> returnMe = 
        [SELECT Id,Env_Status__c,Test_Env__c, Live_Env__c, TP_Manage_Active_Template__c,TemplateName__c,Env_Id__c,Env_Site_Id__c,Name,TP_Manage_LinkAddress__c,
        TP_Manage_Active_Template__r.Name,TP_Manage_Active_Template__r.SiteTemplateName__c,TP_Manage_Property__c,Version__c,Homepage_Widgets__c,Registration_Fields__c,Self_Register_Profile__c  
        FROM Env__c 
        WHERE (Live_Env__c != 0 or Test_Env__c != 0)
        ORDER BY Name, TP_Manage_Property__c];
        return returnMe;
    }

    //set up the current entity
    public pageReference setupCurrEntity(){
        Current_Env__c cEnv = getCurrentEnv();
    	if(cEnv == null){
			cEnv = new Current_Env__c();
            cEnv.Name = UserInfo.getUserId();
    	}
    	List<Current_Env__c> envList = Current_Env__c.getAll().values();
    	for(Current_Env__c ele : envList){
    		ele.ActiveEnvId__c = envIdx;
    	}
        cEnv.Type__c = envTypex;
        cEnv.Env__c = envIdx;
    	upsert cEnv;
    	update envList;
        //getCurrentEnv();
        PageReference returnMex = new PageReference('/apex/Portal_Home');
        if(ApexPages.currentPage().getUrl().contains('TM_TemplateAssignment')){
            returnMex = new PageReference('/apex/TM_TemplateAssignment');
            //returnMex.setRedirect(true);
        }else if(ApexPages.currentPage().getUrl().contains('TM_TemplateContent')){
            returnMex = new PageReference('/apex/TM_TemplateContent');
            //returnMex.setRedirect(true);
        }else if(ApexPages.currentPage().getUrl().contains('Portal_RegistrationSetting')){
            returnMex = new PageReference('/apex/Portal_RegistrationSetting');
            //returnMex.setRedirect(true);
        }else if(ApexPages.currentPage().getUrl().contains('Portal_Page_Configure')){
            returnMex = new PageReference('/apex/Portal_Page_Configure');
            //returnMex.setRedirect(true);
        }else if(ApexPages.currentPage().getUrl().contains('HomepageBuilder_ng')){
            returnMex = new PageReference('/apex/HomepageBuilder_ng');
            //returnMex.setRedirect(true);
        }else{
            returnMex = new PageReference('/apex/Portal_Home');
            //returnMex.setRedirect(true);
        }
        returnMex.setRedirect(true);
        return returnMex;
        //return ApexPages.currentPage();
    }
}