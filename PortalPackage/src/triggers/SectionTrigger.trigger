trigger SectionTrigger on Erx_Section__c (after insert, before delete, before update) {
    Set<Id> liveSectionIds = null;
    List<Erx_Section__c> sectionList = null;
    if(Trigger.isDelete && Trigger.isBefore) { 
        liveSectionIds = PortalPackageHelper.getLiveSectionIds(Trigger.old);
        sectionList = Trigger.old;
    } else if (Trigger.isUpdate && Trigger.isBefore) {
        liveSectionIds = PortalPackageHelper.getLiveSectionIds(Trigger.new);
        sectionList = Trigger.new; 
    } else if (Trigger.isInsert && Trigger.isAfter) {
        liveSectionIds = PortalPackageHelper.getLiveSectionIds(Trigger.new); 
        sectionList = Trigger.new;
    }
    
    for(Erx_Section__c section : sectionList) {
        if(liveSectionIds.contains(section.Id)) {
            section.addError(PortalPackageConstants.SECTION_UPSERTION_DELETION_ERROR_MESSAGE);
        }
    }
}