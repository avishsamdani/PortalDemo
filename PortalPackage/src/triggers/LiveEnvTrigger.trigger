trigger LiveEnvTrigger on Live_Env__c (after insert, after update, before delete) {
	 if((Trigger.isInsert || Trigger.isUpdate) && Trigger.isAfter) {
		EnvTriggerClass.InsertEnv(EnvMode.Live);
	 } else if(Trigger.isDelete){
	 	EnvTriggerClass.RestrictDelete();
	 }
}