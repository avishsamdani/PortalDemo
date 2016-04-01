trigger SiteLoginTemplateTrigger on SiteLoginTemplate__c (after insert, before delete, before update) {
    Set<Id> liveTemplateIds = null;
    List<SiteLoginTemplate__c> templateList = null;
    if((Trigger.isDelete || Trigger.isUpdate) && Trigger.isBefore) {
        liveTemplateIds = PortalPackageHelper.getLiveTemplateIds(Trigger.oldMap.keySet());
        templateList = Trigger.old;
    } else if (Trigger.isInsert && Trigger.isAfter) {
        liveTemplateIds = PortalPackageHelper.getLiveTemplateIds(Trigger.NewMap.keySet());
        templateList = Trigger.new;
    }
    
    for(SiteLoginTemplate__c template : templateList) {
        if(liveTemplateIds.contains(template.Id)) {
            template.addError(PortalPackageConstants.TEMPLATE_UPSERTION_DELETION_ERROR_MESSAGE);
        }
    }
}