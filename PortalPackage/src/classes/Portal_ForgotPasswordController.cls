public class Portal_ForgotPasswordController {
	public Portal_UserWrapper uWrap {get;set;}
	public Portal_Settings setting {get;set;}
	public User cu {get;set;}

	public Portal_ForgotPasswordController() {
		uWrap = new Portal_UserWrapper();
		setting = new Portal_Settings();
	}

	public PageReference submit(){
		//field missing input on page
		if(!uWrap.isValidInputPassword()){
			return Portal_LoginUtil.addErrorMessage(setting.Password_Field_Missing_Message);
		}

		//user not found
		if(uWrap.existingUser() != null){
			//if user exists but not portal user
			this.cu = uWrap.existingUser();
			if(cu != null && uWrap.existingUser().ProfileId != setting.Student_Portal_User_Profile){
            	return Portal_LoginUtil.addErrorMessage(setting.Reg_Non_Portal_User_Exists_Message);
			}
			/*
			else{
				//portal user already exisitng
				return Portal_LoginUtil.addErrorMessage(setting.Reg_Portal_User_Exists_Message);
			}
			*/
			else{
			//user found, but non-portal user
			//if(uWrap.existingUser().ProfileId != setting.Student_Portal_User_Profile){
            //	return Portal_LoginUtil.addErrorMessage(setting.Password_Non_Portal_User_Exists_Message);
			//}
			
			//else{
				//found real potal user and start reseting password
				System.debug('?????????????????->'+Site.forgotPassword(uWrap.email));
				if(Site.forgotPassword(uWrap.email)){
					PageReference pr = Page.Portal_ForgotPasswordConfirm;
	  				pr.setRedirect(true);
	  				return pr;
				}
			//}
			}
        }
        
        return Portal_LoginUtil.addErrorMessage(setting.Password_No_Portal_User_Message);
	}
}