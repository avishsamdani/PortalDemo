public class TM_TemplateContentController {
    public String templateHeader {get;set;}
    public String templateFooter {get;set;}
    public String templateName {get;set;}
    public List<SiteLoginTemplate__c> tmpList {get;set;}
    public SiteLoginTemplate__c curTmp {get;set;}
    public String frontEndObjectId {get;set;}
    public SiteLoginTemplate__c activeTmp {get;set;}
    public boolean newTemplate {get;set;}
   
    public list<ResourceItem> resourceList {get;set;}






    public TM_TemplateContentController(){
        if(ApexPages.currentPage().getParameters().get('templateId')!=null){
            frontEndObjectId = ApexPages.currentPage().getParameters().get('templateId');
            editRecord();
        }


        resourceList = new list<ResourceItem>();

        //ResourceItem n = new ResourceItem('test1', 'subpath1');
        //ResourceItem n1 = new ResourceItem('test2', 'subpath2');
        //resourceList.add(n);
        //resourceList.add(n1);
        String JSONString = JSON.serialize(resourceList);
        system.debug('JSONString+++++++'+JSONString);
    }

    private void initiateData(){
        tmpList = [SELECT Static_Resource_List__c, Description__c, Active__c,SiteTemplateFooter__c,SiteTemplateHeader__c,SiteTemplateName__c, LastModifiedDate, LastModifiedBy.Name FROM SiteLoginTemplate__c ORDER BY LastModifiedDate DESC];
        if(tmpList != null && tmpList.size() > 0){
            for(SiteLoginTemplate__c t : tmpList){
                if(t.Active__c){
                    activeTmp = t;
                }
            }
        }
        curTmp = null;
        if(activeTmp != null){
            templateHeader = activeTmp.SiteTemplateHeader__c.trim();
            templateFooter = activeTmp.SiteTemplateFooter__c.trim();
        }
    }

    public List<SiteLoginTemplate__c> getTemplateList(){
        List<SiteLoginTemplate__c> returnMe = [SELECT Static_Resource_List__c,Description__c, Active__c,SiteTemplateFooter__c,SiteTemplateHeader__c,SiteTemplateName__c, LastModifiedDate, LastModifiedBy.Name FROM SiteLoginTemplate__c ORDER BY LastModifiedDate DESC];
        return returnMe;
    }

    
    public void templateOptions(){
        
    }
    
    public pageReference DefaultTemplate(){
        if(tmpList != null && tmpList.size() > 0){
            templateHeader = tmpList[0].SiteTemplateHeader__c;
            templateHeader = tmpList[0].SiteTemplateFooter__c;
            return ApexPages.currentPage();
        }
        else{
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'There is no default template, please activate/create one.');
            ApexPages.addMessage(msg);
            return null;
        }
    }
    
    public boolean validateRec(){
        if(curTmp.SiteTemplateHeader__c == null || curTmp.SiteTemplateHeader__c.length() == 0){
            return false;
        }
        if(curTmp.SiteTemplateFooter__c == null || curTmp.SiteTemplateFooter__c.length() == 0){
            return false;
        }
        return true;
    }
    
    public pageReference addNewTmp(){
        SiteLoginTemplate__c newTmp = new SiteLoginTemplate__c();
        curTmp = newTmp;
        //resourceList = new list<Static_Resource__c>();
        return null;
    }
    
    public pageReference deleteField(){
        SiteLoginTemplate__c deletingRecord = null;
        if(frontEndObjectId != null){
                try{
                    deletingRecord = [select Active__c,SiteTemplateFooter__c,SiteTemplateHeader__c,SiteTemplateName__c from SiteLoginTemplate__c where Id = : frontEndObjectId];
                    if(deletingRecord != null && deletingRecord.Active__c){
                        throw new Portal_Exception('Can not Delete Active Template.');
                    }
                    else{
                        delete deletingRecord;
                    }
                }catch(Exception e){
                    ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage());
                    ApexPages.addMessage(msg);
                    return null;
            }
        }
        

        ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Template is deleted successfully.');
        ApexPages.addMessage(msg);
        return null;
    }
    
    /************************************************************************
            edit template record
    ************************************************************************/
    public pageReference editRecord(){
        SiteLoginTemplate__c editRecord = null;
        if(frontEndObjectId != null){
            editRecord = [select Static_Resource_List__c,Active__c,SiteTemplateFooter__c,SiteTemplateHeader__c,SiteTemplateName__c,Description__c  from SiteLoginTemplate__c where Id = : frontEndObjectId];
            
            this.curTmp = editRecord;
            resourceList = new list<ResourceItem>();
            if(curTmp.Static_Resource_List__c != null){
                //curTmp.Static_Resource_List__c = '';
            
                resourceList = (List<ResourceItem>)JSON.deserialize(curTmp.Static_Resource_List__c, List<ResourceItem>.class);
            }
            
        }
        return null;
    }
    
    /************************************************************************
            clone template record
    ************************************************************************/
    public pageReference cloneRecord(){
        SiteLoginTemplate__c editRecord = null;
        if(frontEndObjectId != null){
            editRecord = [select Static_Resource_List__c,Active__c,SiteTemplateFooter__c,SiteTemplateHeader__c,SiteTemplateName__c,Description__c  from SiteLoginTemplate__c where Id = : frontEndObjectId];
            this.curTmp = new SiteLoginTemplate__c();
            this.curTmp.SiteTemplateName__c = editRecord.SiteTemplateName__c + '- COPY';
            this.curTmp.SiteTemplateFooter__c = editRecord.SiteTemplateFooter__c ;
            this.curTmp.SiteTemplateHeader__c = editRecord.SiteTemplateHeader__c;
            this.curTmp.Description__c = editRecord.Description__c;
            this.curTmp.Static_Resource_List__c = editRecord.Static_Resource_List__c;
            insert curTmp;
        }
        PageReference pf = new PageReference('/apex/TM_TemplateContent?templateId='+curTmp.Id);
        pf.setRedirect(true);
        return pf;
    }
    
    /*****************************************************************************
            review the template looking in new window
    ******************************************************************************/
    public pageReference reviewTemplate(){
        return ApexPages.currentPage();
    }
    
    /******************************************************************************
            Quick save action
    ******************************************************************************/
    public pageReference quickSave(){
        curTmp.Static_Resource_List__c = JSON.serialize(resourceList);
        if(curTmp.id!= null){
            update curTmp; 
        }else{
            insert curTmp;
        }
        
        return null;
    }
    
    /*******************************************************************************
            Cancel action
    *******************************************************************************/
    public void cancel(){

        curTmp = null;
        
    }

    /************************************************************
        Save the template after "add new" or edit
    ************************************************************/
    public pageReference save(){
        quickSave();
        curTmp = null;
        return null;
    }


    public class ResourceItem{
        public string name {get;set;}
        public string type {get;set;}
        public string subPath {get;set;}
        public string alias {get;set;}
        public string idTime {get;set;}
        public ResourceItem(){
            idTime = Datetime.now().getTime().format();
        }
        public ResourceItem(string n, string t, string s, string i, string a){
            name = n;
            type = t;
            subPath = s;
            idTime = i;
            alias = a;
        }
    }

    public list<SelectOption> getStaticResources(){
      list<SelectOption> returnMe = new list<SelectOption>();
      returnMe.add(new SelectOption('','-- None --'));
      for(StaticResource sr : [SELECT Name, ContentType, NamespacePrefix, SystemModStamp FROM StaticResource ]){
          returnMe.add(new SelectOption(sr.Name,sr.Name + ' -- ' + sr.ContentType));
      }

      return returnMe;
    }
 
    public void addNewResourceItem(){
        this.resourceList.add(new ResourceItem());
    }

    public boolean getReadyToIsertNew(){
        for(ResourceItem r : resourceList){
            if(r.name == null || r.name == ''){
                return false;
            }
        }
        return true;
    }

    public String frontEndTimeId {get;set;}
    public void deleteResourceItem(){
        list<ResourceItem> returnMe = new list<ResourceItem>();
        for(ResourceItem r : resourceList){
            if(r.idTime != frontEndTimeId){
                returnMe.add(r);
            }
        }
        resourceList = returnMe;
    }

    public string pageURL {get{
            return ApexPages.currentPage().getHeaders().get('Host')+'***'+ApexPages.currentPage().getHeaders().get('Host');
        }
        set;
    }
}