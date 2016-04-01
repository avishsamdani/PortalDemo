public  class Portal_ErrorMsgConfigureController {
	public String curEnvId{get;set;}
	public Portal_Registration_Message__c setting{get;set;}
	
	public Portal_ErrorMsgConfigureController(){
		curEnvId = ERx_PortalPackUtil.getCurrentEnvIdGlobal();
		
		List<Portal_Registration_Message__c> settingList = [SELECT Id,Name,	Account_Name__c,
		Activate_Existing_Contact_Message__c,Activate_Existing_Contact_Via_Email__c,CustomSettingURL__c,
		Env__c,Incorrect_Username_Password_Message__c,	Login_Field_Missing_Message__c,
		Login_Non_Portal_User_Message__c,	Password_Field_Missing_Message__c,Password_Non_Portal_User_Exists_Message__c,
		Password_No_Portal_User_Message__c,Password_Reset_Confirm_Message__c,Reg_Email_Format_Error_Message__c,
		Reg_Field_Missing_Message__c,RegistrationURL__c,Reg_Non_Portal_User_Exists_Message__c,
		Reg_Password_No_Match_Message__c,Reg_Portal_User_Exists_Message__c,Reg_Username_Too_Long_Message__c,
		SiteLoginTemplateName__c,Student_Portal_User_Profile__c,Update_Existing_Contact__c
		FROM Portal_Registration_Message__c WHERE Env__c =: curEnvId ];
		
		setting = null;
		if(settingList != null && settingList.size() > 0){
			setting = settingList[0];
		}
		else{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No Error Msg Record existed, please create one.'));
		}
	}
	
	public pageReference save(){
		if(setting != null){
			update setting;
		}
		PageReference pf = ApexPages.currentPage();
		pf.setRedirect(true);
		return pf;
	}
}