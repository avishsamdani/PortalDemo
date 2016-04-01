public with sharing class EnvTriggerClass {
	public static void InsertEnv(EnvMode mode) {
		Map<String, String> mapOfNewEnvs = new Map<String, String>();
		List<sObject> newEnvList = null;
		if(mode == EnvMode.Live) {
			newEnvList = [Select Id, Env__r.Name from Live_Env__c where id in: Trigger.NewMap.keySet()];
		} else {
			newEnvList = [Select Id, Env__r.Name from Test_Env__c where id in: Trigger.NewMap.keySet()];
		}
			
		for(sObject lv : newEnvList) {
			mapOfNewEnvs.put(String.valueOf(lv.get('Id')), String.valueOf(lv.getSobject('Env__r').get('Name')));
		} 
		
		List<sObject> existingEnvs = null;
		if(mode == EnvMode.Live) {
			existingEnvs = [Select Env__r.Name from Live_Env__c where Env__r.Name in: mapOfNewEnvs.values() and id not in: Trigger.NewMap.keySet()];	
		} else {
			existingEnvs = [Select Env__r.Name from Test_Env__c where Env__r.Name in: mapOfNewEnvs.values() and id not in: Trigger.NewMap.keySet()];	
		}
		Set<String> listOfExistingEnvs = new Set<String>();
		for(sObject lv : existingEnvs) {
			listOfExistingEnvs.add(String.valueOf(lv.getSobject('Env__r').get('Name')));
		}
		
		for(sObject lv : Trigger.new) {
			if(listOfExistingEnvs.contains(mapOfNewEnvs.get(String.valueOf(lv.get('Id'))))) {
				lv.addError('More than one version of same Env is not allowed');
			}
		}
	}	
	
	public static void RestrictDelete() {
		for(sObject lv : Trigger.old) {
			lv.addError('Env deletion not allowed. You can only add or replace Env');
		}
	}
}