public class Portal_LoginController {

    public Portal_UserWrapper uWrap {get;set;}
    public Portal_Settings setting {get;set;}

    public Portal_LoginController() {
        uWrap = new Portal_UserWrapper();
        setting = new Portal_Settings();
    }

    public PageReference login(){
        if(!uWrap.isValidInputLogin()){
            //field missing.
            return Portal_LoginUtil.addErrorMessage(setting.Login_Field_Missing_Message);
            
        }

        if(uWrap.existingUser() == null){
            //if the user does not exist
            return Portal_LoginUtil.addErrorMessage(setting.Login_Incorrect_Username_Password_Messag);
        }else{
        	if(setting.Student_Portal_User_Profile == null || setting.Student_Portal_User_Profile == ''){
            	return Portal_LoginUtil.addErrorMessage('No Student Portal User Id, Please Check Custom Setting.');
            }
            //if user exists but not portal user
            if(String.valueOf(uWrap.existingUser().ProfileId).substring(0,15) != String.valueOf(setting.Student_Portal_User_Profile).substring(0,15)){
                return Portal_LoginUtil.addErrorMessage(setting.Login_Non_Portal_User_Message);
            }
        }

        //reach here, no error, ready to login.
        //String startUrl = System.currentPageReference().getParameters().get('startURL');
        PageReference pr = Site.login(uWrap.email, uWrap.password,'/home/home.jsp');

        return pr;
    }
}