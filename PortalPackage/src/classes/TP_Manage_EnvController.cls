public class TP_Manage_EnvController {
	//return environment record
	public static Env__c getCurrentEnv(String entityId){
		return [SELECT Id,Env_Id__c,TP_Manage_Active_Template__r.SiteTemplateHeader__c,
		TP_Manage_Active_Template__r.SiteTemplateFooter__c,TP_Manage_Active_Template__c,
		TP_Manage_Active_Template__r.SiteTemplateName__c,TP_Manage_Active_Template__r.Name,
		Name,TP_Manage_LinkAddress__c,Tp_Manage_Property__c FROM Env__c WHERE Env_Id__c=:entityId];
	}
	
	//return environment Id
	public static Id getCurrentEnvId(String entityId){
		return [SELECT Id,Env_Id__c,TP_Manage_Active_Template__r.SiteTemplateHeader__c,
		TP_Manage_Active_Template__r.SiteTemplateFooter__c,TP_Manage_Active_Template__c,
		TP_Manage_Active_Template__r.SiteTemplateName__c,TP_Manage_Active_Template__r.Name,
		Name,TP_Manage_LinkAddress__c,Tp_Manage_Property__c FROM Env__c WHERE Env_Id__c=:entityId].Env_Id__c;
	}
}