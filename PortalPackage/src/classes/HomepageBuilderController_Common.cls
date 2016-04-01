public class HomepageBuilderController_Common {
    //sobject
    public String hwlJSON{get;set;}

    public HomepageBuilderController_Common (ngForceController ngcon){
        Id hwlId=ApexPages.currentPage().getParameters().get('id');
        if(!String.isBlank(hwlId)){
            Homepage_Widget_Layout__c hwl=[select Id,Name,Grid_Data__c,Grid_Width__c from Homepage_Widget_Layout__c where Id=:hwlId];
            hwlJSON=String.escapeSingleQuotes(JSON.serialize(hwl));
        }
    }
 }