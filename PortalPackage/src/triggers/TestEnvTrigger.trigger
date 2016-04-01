trigger TestEnvTrigger on Test_Env__c (after insert, after update, before delete) {
	 if((Trigger.isInsert || Trigger.isUpdate) && Trigger.isAfter) {
		EnvTriggerClass.InsertEnv(EnvMode.Test);
	 } else if(Trigger.isDelete){
	 	EnvTriggerClass.RestrictDelete();
	 }
}