public class TM_TemplateController {
    //the Id of current Site, store on Env__c.Env_Id__c
    public String entityId{get;set;}
    //temlate record Id
    public String templateId {get;set;}
    //env Id
    public String envId {get;set;}
    //if this is template review or site reivew or live env
    public String previewMode {get;set;}
    public String templateHeader {get;set;}
    public String templateFooter {get;set;}
    public String templateResource {get;set;}
    public SiteLoginTemplate__c currentTemplate {get;set;}
    
    //public string testENVID {get{return ERx_PortalPackUtil.getCurrentEnv().Id;}set;}
    public string testENVID {get{return Site.getSiteId();}set;}
    public string testUserInfo {get{return UserInfo.getName();}set;}
    public string testNetworkId {get{return Network.getNetworkId();}set;}
    
    public TM_TemplateController(){
        
        templateHeader = ''; 
        templateFooter = ''; 
        templateResource = ''; 
        
        
        previewMode = ApexPages.currentPage().getParameters().get('previewMode');

        if(previewMode == 'tmpReview'){
            //template content preview
            templateId = ApexPages.currentPage().getParameters().get('tmpId');

        }else{
            string queryStr = 'SELECT TP_Manage_Active_Template__c FROM Env__c';
            if(previewMode == 'siteReview'){
                //site login preview
                envId = ApexPages.currentPage().getParameters().get('envId');
                queryStr += ' WHERE Id =: envId';
            }else{
                //live portal/site env
                entityId = Site.getSiteId();   
                queryStr += ' WHERE Env_Status__c = \'Live\' AND Env_Site_Id__c =: entityId limit 1';
            }
            list<Env__c> envList = Database.query(queryStr);
            if(envList.size()>0){
                templateId = envList[0].TP_Manage_Active_Template__c;
            }
        } 

        
        
         
        



        
        if(templateId != null){  
            currentTemplate = [Select Static_Resource_List__c, SiteTemplateHeader__c, SiteTemplateFooter__c From SiteLoginTemplate__c where Id =: templateId];
            
            //populate site header and footer
            templateHeader = currentTemplate.SiteTemplateHeader__c; 
            templateFooter = currentTemplate.SiteTemplateFooter__c;

            //process resource list
            if(currentTemplate.Static_Resource_List__c!=null && currentTemplate.Static_Resource_List__c != ''){
                list<TM_TemplateContentController.ResourceItem> resourceList = new list<TM_TemplateContentController.ResourceItem>();
                resourceList = (List<TM_TemplateContentController.ResourceItem>)JSON.deserialize(currentTemplate.Static_Resource_List__c, List<TM_TemplateContentController.ResourceItem>.class);
                
                //to compose URL need to know what is current site path
                string siteURL = Site.getPathPrefix();

                 for(TM_TemplateContentController.ResourceItem item : resourceList){
                    string reString = '';
                    if(item.type == 'CSS'){
                        reString = '<link  rel="stylesheet" type="text/css" href="' + siteURL + '/resource/'+item.name+item.subPath+'" ></link>';
                        //System.debug('st1rrrrrrrrrrr::'+reString);
                        templateResource += reString;
                    }else if(item.type == 'JavaScript'){
                        reString = '<script type="text/javascript" scr="' + siteURL + '/resource/'+item.name+item.subPath+'" ></script>';
                        //System.debug('st2rrrrrrrrrrr::'+reString);
                        templateResource += reString;
                    }else if(item.type == 'Image'){
                        //System.debug('st3rrrrrrrrrrr::'+reString);
                        reString = siteURL + '/resource/'+item.name+item.subPath;
                        templateHeader = templateHeader.replace(item.alias, reString);
                        templateFooter = templateFooter.replace(item.alias, reString);
                    }
                 }
            }
        }


    }
























    
    /************************************************************
        Static Method for portal package
        API : TM_TemplateController.getHeaderFooterMap().get('head');
              TM_TemplateController.getHeaderFooterMap().get('foot');
    ************************************************************/
    public static Map<String,String> getHeaderFooterMap(){
        Map<String, String> headfoot = new Map<String, String>();
        String header,footer;
        String activeEntityId = Site.getSiteId();
        List<Live_Env__c> liveEnvs = [Select l.Env__r.TP_Manage_Active_Template__r.SiteTemplateHeader__c, l.Env__r.TP_Manage_Active_Template__r.SiteTemplateFooter__c, l.Env__r.Name, l.Env__r.Env_Id__c,l.Env__r.Env_Site_Id__c, l.Env__c From Live_Env__c l where l.Env__r.Env_Site_Id__c =: activeEntityId];
        if(liveEnvs == null || liveEnvs.size() <= 0 || liveEnvs[0].Env__c == null){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No Live Environment is founded.'));
            return null;
        }
        else if(liveEnvs.size() > 1){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'More than one Live Environment is founded.'));
            return null;
        }
        else{
            header = liveEnvs[0].Env__r.TP_Manage_Active_Template__r.SiteTemplateHeader__c;
            footer = liveEnvs[0].Env__r.TP_Manage_Active_Template__r.SiteTemplateFooter__c;
            if( header != null && footer != null){
                headfoot.put('header',header);
                headfoot.put('footer',footer);
            }
            
            return headfoot;
        }
        //Type t = Type.forName('TP_Manage_TemplateController');
        //TP_Manage_TemplateController newObj = (TP_Manage_TemplateController)t.newInstance();
        //header = newObj.templateHeader;
        //System.debug('hhhhhhhhhhhhhhhhxxx->'+header);
        //footer = newObj.templateFooter;
        //if(header != null && footer != null){
        //  headfoot.put('header',header);
        //  headfoot.put('footer',footer);
        //}
        
        return headfoot;
    }
    
    public static Map<String,String> getHeaderFooterMap(String liveId){
        Map<String, String> headfoot = new Map<String, String>();
        String header,footer;
        String activeEntityId = liveId;
        List<Live_Env__c> liveEnvs = [Select l.Env__r.TP_Manage_Active_Template__r.SiteTemplateHeader__c, l.Env__r.TP_Manage_Active_Template__r.SiteTemplateFooter__c, l.Env__r.Name, l.Env__r.Env_Id__c,l.Env__r.Env_Site_Id__c, l.Env__c From Live_Env__c l where l.Env__r.Env_Site_Id__c =: activeEntityId];
        if(liveEnvs == null || liveEnvs.size() <= 0 || liveEnvs[0].Env__c == null){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No Live Environment is founded.'));
            return null;
        }
        else if(liveEnvs.size() > 1){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'More than one Live Environment is founded.'));
            return null;
        }
        else{
            header = liveEnvs[0].Env__r.TP_Manage_Active_Template__r.SiteTemplateHeader__c;
            footer = liveEnvs[0].Env__r.TP_Manage_Active_Template__r.SiteTemplateFooter__c;
            if( header != null && footer != null){
                headfoot.put('header',header);
                headfoot.put('footer',footer);
            }
            
            return headfoot;
        }
        
        return headfoot;
    }
    
}