public  class TM_TemplateAssignmentController {
    public String frontRecordId {get;set;}
    public List<SiteLoginTemplate__c> tmpList {get;set;}

    
    public TM_TemplateAssignmentController(){

        tmpList = [SELECT Id,Name,Active__c,SiteTemplateName__c,Description__c FROM SiteLoginTemplate__c];

    }

    public Current_Env__c getCurrentEnv(){
        return ERx_PortalPackUtil.getCurrentEnvForConfiguration();
    }


    public Id entId {get;set;}
    public Env__c getCurrentEntity(){
        Env__c returnMe = null;
        Current_Env__c curEnv = getCurrentEnv();
        if(curEnv !=null){
             returnMe = [SELECT Name,Id,TP_Manage_Active_Template__c,Tp_Manage_Property__c FROM Env__c WHERE Id=: curEnv.Env__c];
             entId = returnMe.Id;
        }
        return returnMe;
    }

    public PageReference tempAssignment(){

        Env__c updateMe = new Env__c(Id = entId, TP_Manage_Active_Template__c = frontRecordId);
        update updateMe;
        return null;
    }
}