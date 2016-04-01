public  class Portal_RegisterController {

	public Portal_UserWrapper uWrap {get;set;}
	public Portal_Settings setting {get;set;}
	public Contact ct {get;set;}
	public User cu {get;set;}
	public Portal_RegisterController() {
		//checking fields first
		uWrap = new Portal_UserWrapper();
		setting = new Portal_Settings();
	}
	
	public boolean basicFieldsValidation(){
		if(uWrap!= null){
			if(uWrap.firstName == null || uWrap.firstName==''
			|| uWrap.lastName == null || uWrap.lastName == ''
			|| uWrap.email == null || uWrap.email == ''
			|| uWrap.password == null || uWrap.password == ''){
				return false;	
			}
		}
		return true;
	}
	
	public boolean extraFieldsValidation(){
		if(uWrap.customFields != null){
			for(Portal_CustomField f : uWrap.customFields){
				if(f.isRequired && (f.fldType=='Picklist' ||
				f.fldType=='TextArea' || 
				f.fldType=='Phone' || 
				f.fldType=='String' || 
				f.fldType == 'Reference') && (f.inputText == null || f.inputText == '')){
					return false;
				}
				
				if(f.isRequired && (f.fldType=='Date') && (f.inputDate==null || f.inputDate=='')){
					return false;
				}
				
				if(f.isRequired && f.hasChildren && (f.childrenInputText == null || f.childrenInputText == '')){
					return false;
				}
				
				if(f.isRequired && f.hasGrandChildren && ((f.grandChildrenInputText == null || f.grandChildrenInputText == ''))){
					return false;
				}
			}
		}
		return true;
	}
	
	

	//new user registration
	public PageReference register(){
		//userId
		String userId = null;

		//field missing.
		if(!uWrap.isValidInputReg()){
			System.debug('=============000>>>'+setting.Reg_Field_Missing_Message);
            return Portal_LoginUtil.addErrorMessage(setting.Reg_Field_Missing_Message);
		}

		//password do not match
		if (!uWrap.isValidPassword()) {
        	return Portal_LoginUtil.addErrorMessage(setting.Reg_Password_No_Match_Message);
        } 
        
        //email format validation
		if(!uWrap.validateEmailFormat()){
			return Portal_LoginUtil.addErrorMessage(setting.Reg_Email_Format_Error_Message);
		}

        //email too long
		if(uWrap.email.length() > 40){
			return Portal_LoginUtil.addErrorMessage(setting.Reg_Username_Too_Long_Message);
		}
		
		if(!basicFieldsValidation()){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please fill required fields.'));
			return null;
		}
		
		if(!extraFieldsValidation()){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please fill all required fields.'));
			return null;
		}

		if(uWrap.existingUser() != null){
			//if user exists but not portal user
			this.cu = uWrap.existingUser();
			if(cu != null && uWrap.existingUser().ProfileId != setting.Student_Portal_User_Profile){
            	return Portal_LoginUtil.addErrorMessage(setting.Reg_Non_Portal_User_Exists_Message);
			}else{
				//portal user already exisitng
				return Portal_LoginUtil.addErrorMessage(setting.Reg_Portal_User_Exists_Message);
			}
        }else if(uWrap.existingContact() != null){
        	//if contact exist
	        ct = uWrap.existingContact();
	        system.debug('c.email-------'+ct.Email);
	    	uWrap.u.ContactId = ct.Id;
	    	if(setting.Update_Existing_Contact){
	    		uWrap.updateExistingContact();
	    	}
	    	if(setting.Activate_Existing_Contact_Via_Email){
	    		uWrap.activateExistingContact();
	    		return Portal_LoginUtil.addErrorMessage(setting.Activate_Existing_Contact_Message);
	    	}else{
		    	try{
		    		userId = Site.createPortalUser(uWrap.u, ct.AccountId, uwrap.password);
		    		if(userId != null){
		    			uWrap.processingExtraFields(ct);
		    		}
		    	}catch(Exception e){
		    		return Portal_LoginUtil.addErrorMessage(e.getMessage()+'1');
		    	}
	    	}
        }else{
        	//if nothing existing, create brand new user
        	system.debug('accountId -----------'+ retrieveAccountId());
        	ct = new Contact();
        	//front end user info
        	ct.FirstName = uWrap.u.FirstName;
        	ct.LastName = uWrap.u.LastName;
        	ct.Email = uWrap.u.Email;
        	ct.AccountId = this.retrieveAccountId();
        	//upsert ct;
        	uWrap.processingExtraFields(ct);
        	uWrap.u.ContactId = ct.Id;
        	
        	try{
        		userId = Site.createPortalUser(uWrap.u, ct.AccountId, uwrap.password);
        	}catch(Exception e){
	    		return Portal_LoginUtil.addErrorMessage(e.getMessage()+'2');
	    	}
        }
        
        if(userId != null){
        	PageReference pageRef = null;
        	try{
        		pageRef = Site.login(uwrap.email, uwrap.password, '');
        	}
        	catch(Exception e){
        		return Portal_LoginUtil.addErrorMessage(e.getMessage());
        	}
            pageRef.setRedirect(true);
            return pageRef;
        }
        
        //should never reach here
        return Portal_LoginUtil.addErrorMessage('USERID is NULL.');
	}
	
	

	//get account Id
	//if account name define in setting, that means all portal user should register to one account
	//if account name is balnk in setting, that means each portal user should have their own acc name.
	public Id retrieveAccountId(){
		Id returnMe;
		if(setting.Account_Name == null){
			Account acc = new Account();
			string accName = uWrap.firstName + ' ' + uWrap.lastName;
			if(accName.length() > 240){
				accName = accName.subString(0,239);
			}
			accName = accName+' Portal';
			acc.Name = accName;
			insert acc;
			returnMe = acc.Id;
		}
		
		else{
			list<Account> accList = [select Id from Account where Name =: setting.Account_Name];
			if(accList.size() > 0){
				returnMe = accList.get(0).Id;
			}else{
				Account acc1 = new Account();
				acc1.Name = setting.Account_Name;
				insert acc1;
				returnMe = acc1.Id;
			}
		}
		return returnMe;
	}
}