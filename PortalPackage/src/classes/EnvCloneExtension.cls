public with sharing class EnvCloneExtension {
	private List<Erx_Page__c> pageList {get;set;}
	public Env__c newEnv {get;set;}
	public Boolean isClonePossible {get;set;} //Whether env can be clonned or not
	public String returnUrl {get;set;}
	public String baseUrl {get;set;}
	private Env__c currentEnv {get;set;}
	private SiteLoginTemplate__c template {get;set;} 
	
	//Controller
	public EnvCloneExtension(ApexPages.StandardController setCon) {
		isClonePossible = true;
		currentEnv = (Env__c) setCon.getRecord(); 
		newEnv = new Env__c();
		if(currentEnv.Id != null) {
			List<Env__c> envList = [Select Id, Version__c, TP_Manage_Property__c, Env_Id__c, TP_Manage_Active_Template__c, TP_Manage_Active_Template__r.Active__c, TP_Manage_Active_Template__r.SiteTemplateFooter__c, TP_Manage_Active_Template__r.SiteTemplateHeader__c, TP_Manage_Active_Template__r.SiteTemplateName__c, Name from Env__c where id =: currentEnv.Id];
			if(envList.size() > 0) {
				template = new SiteLoginTemplate__c(Active__c = envList[0].TP_Manage_Active_Template__r.Active__c, SiteTemplateFooter__c = envList[0].TP_Manage_Active_Template__r.SiteTemplateFooter__c, SiteTemplateHeader__c = envList[0].TP_Manage_Active_Template__r.SiteTemplateHeader__c, SiteTemplateName__c = envList[0].TP_Manage_Active_Template__r.SiteTemplateName__c);
				newEnv = envList[0].clone(false, true, false, false);
				if(envList[0].Version__c == null) {
					newEnv.Version__c = 2;
				} else {
					newEnv.Version__c = envList[0].Version__c + 1;
				}
				List<Env__c> envListOfHighestVersion = [Select Id, Version__c, Name from Env__c where Version__c != null and Name =: envList[0].Name order by Version__c desc limit 1];
				if(envListOfHighestVersion.size() > 0) {
					if(newEnv.Version__c <= envListOfHighestVersion[0].Version__c) {
						//If newly create env version is same as the highest version available clonning is not possible. 
						isClonePossible = false;
						baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
						Apexpages.addMessage(new Apexpages.Message(Apexpages.severity.ERROR, 'Clonning is not possible from this version. Try ' + '<a style=\'font-weight: bold;\' href=\'' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + envListOfHighestVersion[0].Id + '\'/>' + envListOfHighestVersion[0].Name + ' Version ' + envListOfHighestVersion[0].Version__c + '</a>'));																																																																																																	
					}
				}
			}
			pageList = [Select Name, Id, Page_Name__c, IsActive__c, Order__c, Env__c, (Select Id, Erx_Page__c, Modal_Data__c, View_Layout__c, Order__c From Erx_Sections__r order by Order__c) From Erx_Page__c where IsActive__c = true and Env__c =: currentEnv.Id order by Order__c];
		}
		returnUrl = apexpages.currentPage().getParameters().get('retURL');
	}
	
	public PageReference save() {
		Savepoint sp = Database.setSavePoint();
        PageReference pag = null;
        try {         
        	//create new template   
        	upsert template;
        	
        	//create new Env and assign new template to this
        	newEnv.TP_Manage_Active_Template__c = template.Id;
            upsert newEnv;
            
            //Create new pages and assign to new env
            Map<ID,  Erx_Page__c> oldNewpageMap = new Map<ID,  Erx_Page__c>();
            List<Erx_Page__c> newPageList = new List<Erx_Page__c>();
            for(Erx_Page__c page : pageList) {
            	//newPageList.add(page.clone(false, true, false, false));
            	Erx_Page__c newPage = page.clone(false, true, false, false);
            	newPage.Env__c = newEnv.Id;
            	oldNewpageMap.put(page.Id, newPage);
            }
            upsert oldNewpageMap.values();
            
            //Create new sections and assign to respective new pages.
            List<Erx_Section__c> sections = new List<Erx_Section__c>();
            for(Erx_Page__c page : pageList) {
            	for(Erx_Section__c section : page.Erx_Sections__r) {
            		Erx_Section__c sec = section.clone(false, true, false, false);
            		sec.Erx_Page__c = oldNewpageMap.get(page.Id).Id;
            		sections.add(sec);		
            	}
            }
            upsert sections;
            
            //set url to return to newly created environment
            returnUrl = returnUrl.replace(currentEnv.Id, newEnv.Id);
            returnUrl = returnUrl.replace(String.valueOf(currentEnv.Id).substring(0, 15), newEnv.Id);
            pag = new PageReference(returnUrl);
        } catch(Exception e) {
        	Database.rollBack(sp);
            Apexpages.addMessage(new Apexpages.Message(Apexpages.severity.ERROR, e.getMessage()));
        }
        return pag;
    }
    
	//On cancellation return to original environment from which we are trying to create new environment.
	public PageReference cancel() {
        return new PageReference(returnUrl);
    }
}