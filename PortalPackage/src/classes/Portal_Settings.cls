public class Portal_Settings {
	public string Account_Name {get;set;}
	public string Login_Incorrect_Username_Password_Messag {get;set;}
	public string Login_Non_Portal_User_Message {get;set;}
	public string Password_Non_Portal_User_Exists_Message {get;set;}
	public string Password_No_Portal_User_Message {get;set;}
	public string Reg_Email_Format_Error_Message {get;set;}
	public string Reg_Non_Portal_User_Exists_Message {get;set;}
	public string Reg_Password_No_Match_Message {get;set;}
	public string Reg_Portal_User_Exists_Message {get;set;}
	public string Reg_Username_Too_Long_Message {get;set;}
	public string Student_Portal_User_Profile {get;set;}
	public string Login_Field_Missing_Message {get;set;}
	public string Reg_Field_Missing_Message {get;set;}
	public string Password_Field_Missing_Message {get;set;}
	public string Password_Reset_Confirm_Message {get;set;}
	public boolean Update_Existing_Contact {get;set;}
	public boolean Activate_Existing_Contact_Via_Email {get;set;}
	public string Activate_Existing_Contact_Message {get;set;}
	public String currentCusterSettingURL {get;set;}
	
	public String curEnvId{get;set;}

	public Portal_Settings() {
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
		
		Portal_Registration_Message__c setting = null;
		System.debug('----------------->'+settingList);
		if(settingList != null && settingList.size() > 0){
			setting = settingList[0];
		}
		
		System.debug('----------------ss->'+setting);
		if(setting != null){
			Account_Name = setting.Account_Name__c;
			Login_Incorrect_Username_Password_Messag = setting.Incorrect_Username_Password_Message__c; 
			Login_Non_Portal_User_Message =setting.Login_Non_Portal_User_Message__c;
			Password_Non_Portal_User_Exists_Message = setting.Password_Non_Portal_User_Exists_Message__c;
			Password_No_Portal_User_Message = setting.Password_No_Portal_User_Message__c;
			Reg_Email_Format_Error_Message = setting.Reg_Email_Format_Error_Message__c;
			Reg_Non_Portal_User_Exists_Message = setting.Reg_Non_Portal_User_Exists_Message__c;
			Reg_Password_No_Match_Message = setting.Reg_Password_No_Match_Message__c;
			Reg_Portal_User_Exists_Message = setting.Reg_Portal_User_Exists_Message__c;
			Reg_Username_Too_Long_Message = setting.Reg_Username_Too_Long_Message__c;
			Student_Portal_User_Profile = setting.Student_Portal_User_Profile__c;
			Login_Field_Missing_Message = setting.Login_Field_Missing_Message__c;
			Password_Field_Missing_Message = setting.Password_Field_Missing_Message__c;
			Reg_Field_Missing_Message = setting.Reg_Field_Missing_Message__c;
			Password_Reset_Confirm_Message = setting.Password_Reset_Confirm_Message__c;
			Update_Existing_Contact = setting.Update_Existing_Contact__c;
			Activate_Existing_Contact_Via_Email = setting.Activate_Existing_Contact_Via_Email__c;
			Activate_Existing_Contact_Message = setting.Activate_Existing_Contact_Message__c;
			currentCusterSettingURL = setting.CustomSettingURL__c;
			
		}else{
			Login_Incorrect_Username_Password_Messag = 'Login_Incorrect_Username_Password_Messag'; 
			Login_Non_Portal_User_Message ='Login_Non_Portal_User_Message';
			Password_Non_Portal_User_Exists_Message = 'Password_Non_Portal_User_Exists_Message';
			Password_No_Portal_User_Message = 'Password_No_Portal_User_Message';
			Reg_Email_Format_Error_Message = 'Reg_Email_Format_Error_Message';
			Reg_Non_Portal_User_Exists_Message = 'Reg_Non_Portal_User_Exists_Message';
			Reg_Password_No_Match_Message = 'Reg_Password_No_Match_Message';
			Reg_Portal_User_Exists_Message = 'Reg_Portal_User_Exists_Message';
			Reg_Username_Too_Long_Message = 'Reg_Username_Too_Long_Message';
			Student_Portal_User_Profile = 'Student_Portal_User_Profile';
			Login_Field_Missing_Message = 'Login_Field_Missing_Message';
			Password_Field_Missing_Message = 'Password_Field_Missing_Message';
			Reg_Field_Missing_Message = 'Reg_Field_Missing_Message';
			Password_Reset_Confirm_Message = 'Password_Reset_Confirm_Message';
			Update_Existing_Contact = true;
			Activate_Existing_Contact_Via_Email = true;
			Activate_Existing_Contact_Message = 'Activate_Existing_Contact_Message';
		}
	}
	
}