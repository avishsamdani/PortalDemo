trigger EnvTrigger on Env__c (before delete) {
    Set<Id> envIds = PortalPackageHelper.getliveEnvIds(Trigger.oldMap.keySet());
    for(Env__c env : Trigger.old) {
        if(envIds.contains(env.Id)) {
            env.addError(PortalPackageConstants.ENV_DELETION_ERROR_MESSAGE);
        }
    }
}