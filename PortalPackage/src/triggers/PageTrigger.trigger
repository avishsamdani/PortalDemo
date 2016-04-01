trigger PageTrigger on Erx_Page__c (after insert, before delete, before update) {
    Set<Id> livePageIds = null;
    List<Erx_Page__c> pageList = null;
    if(Trigger.isDelete && Trigger.isBefore) {
        livePageIds = PortalPackageHelper.getLivePageIds(Trigger.old);
        pageList = Trigger.old;
    } else if ((Trigger.isInsert && Trigger.isAfter) || (Trigger.isUpdate && Trigger.isBefore)) {
        livePageIds = PortalPackageHelper.getLivePageIds(Trigger.New);
        pageList = Trigger.new;
    }
    
    for(Erx_Page__c page : pageList) {
        if(livePageIds.contains(page.Id)) {
            page.addError(PortalPackageConstants.PAGE_UPSERTION_DELETION_ERROR_MESSAGE);
        }
    }
}