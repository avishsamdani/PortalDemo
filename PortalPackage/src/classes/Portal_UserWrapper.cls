public class Portal_UserWrapper {
    public String firstName {get;set;}
    public String lastName {get; set;}
    public String email {get;set;}
    public String password {get; set;}
    public String confirmPassword {get; set; }
    public String userName {get; set; }
    
    public User u {
        get{
            u = new User();
            u.Username = this.email;
            u.Email = this.email;
            u.FirstName = this.firstName;
            u.LastName = this.lastName;
            u.CommunityNickname = ''+this.email;
            return u;
        }
        set;
    }
    public Contact existContact {get;set;}

    //custom fields list for contact, application
    public list<Portal_CustomField> customFields { get; set; }

    public Portal_UserWrapper() {
    	String curEnvId = ERx_PortalPackUtil.getCurrentEnvIdGlobal();
    	if(curEnvId != null){
	        list<Portal_Login_Custom_Field__c> fieldListSetting = [SELECT Name, Children_Index_Field_API__c, Children_Field_Label__c,Children_Objects_API__c,Display_Order__c,Field_API_Name__c,Is_Field_Required__c,Linked_to_Portal__c,Look_Up_Field__c,Object_Name__c,Grand_Children_Field_API_Name__c,Grand_Children_Field_Label__c,Grand_Children_Index_Field_API__c,Grand_Children_Objects_API__c,Active__c,Children_Field_API_Name__c,queryCriteria__c,childQueryCriteria__c,gdChildQueryCriteria__c,Env__c  FROM Portal_Login_Custom_Field__c WHERE Active__c=true AND Env__c=: curEnvId order by Display_Order__c];
	        System.debug('=========------->'+fieldListSetting.size());
	        if(fieldListSetting != null && fieldListSetting.size() > 0){
	            customFields = new list<Portal_CustomField>();
	            for(Portal_Login_Custom_Field__c p :fieldListSetting){
	            	System.debug('hhhhhhhhhhhhhhhhhhhh{complete');
	                customFields.add(new Portal_CustomField(p));
	            }
	        }
	        System.debug('{{{{{{{{{{{{{{{{{{{{{{{{{{{complete');
    	}
    	else{
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No environment is selected.'));
    	}
    }
    
    /*
    public Env__c getCurrentEnv(){
    	List<Env__c> allEnvs = [SELECT Id,Env_Id__c,Env_Site_Id__c,Env_Status__c,Live_Env__c,Registration_Fields__c,Self_Register_Profile__c,Test_Env__c,Self_Register_URL__c,TemplateName__c,TP_Manage_Property__c FROM Env__c];
    	Env__c liveEnv = null;
    	Env__c testEnv = null;
    	if(allEnvs == null || allEnvs.size() <= 0){
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No available Envs.'));
    		return null;
    	}
    	else{
    		for(Env__c ele : allEnvs){
    			if(ele.Env_Status__c == 'Live'){
    				liveEnv = ele;
    			}
    			if(ele.Env_Status__c == 'Test'){
    				testEnv = ele;
    			}
    		}
    		if(testEnv == null || liveEnv == null){
    			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No test / live Env.'));
    			return null;
    		}
    		if(ApexPages.currentPage().getParameters().get('previewMode') != null){
    			return testEnv;
    		}
    		else{
    			return liveEnv;
    		}
    	}
    	
    }
	*/
	
    //if password match
    public boolean isValidPassword() {       
        return this.password == this.confirmPassword;
    }

    //if all fields are filled
    public boolean isValidInputReg() {      
        return (this.firstName != null && this.lastName != null && this.email != null && this.password != null && this.confirmPassword != null && this.firstName != '' && this.lastName != '' && this.email != '' && this.password != '' && this.confirmPassword != '');
    }

    //if all fields are filled for login
    public boolean isValidInputLogin() {    
        return (this.email != null && this.password != null && this.email != '' && this.password != '');
    }

    //if all fields are filled for login
    public boolean isValidInputPassword() {    
        return (this.email != null && this.email != '');
    }
    
    //validate email format
	public Boolean validateEmailFormat() {
		Boolean res = true;
		String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$'; // source: <a href="http://www.regular-expressions.info/email.html" target="_blank" rel="nofollow">http://www.regular-expressions.info/email.html</a>
		Pattern MyPattern = Pattern.compile(emailRegex);
		Matcher MyMatcher = MyPattern.matcher(email);
	
		if (!MyMatcher.matches()) 
		    res = false;
		return res;	
	}

    //check existng user
    public User existingUser(){
        list<User> ul = [Select Id, ProfileId,Email from User where Email = : this.email];
        User existUser;
        if(ul.size() > 0){
            existUser = ul.get(0);
        }
        return existUser;
    }

    //check existing Contact
    public Contact existingContact(){
        list<Contact> cl = [Select Id,AccountId,Email from Contact where Email = : this.email];
        //Contact existContact;
        if(cl.size() > 0){
            existContact = cl.get(0);
            
            return existContact;
        }else{
            list<Lead> ll = [Select Id,Email from Lead where Email = : this.email order by CreatedDate DESC Limit 1];
            Lead existLead;
            if(ll.size()>0){
                existLead = ll.get(0);
                existLead.Convert_Lead__c = true;
                update existLead;
                existContact = existingContact();
            }
        }
        return existContact;
    }

    //update existing contact
    public void updateExistingContact(){
        if(existContact != null){
            existContact.FirstName = this.firstName;
            existContact.LastName = this.lastName;
            existContact.Email = this.email;
            update existContact;
        }
    }
    
    public void activateExistingContact(){
        if(existContact != null){
            existContact.Create_Portal_User__c = true;
            update existContact;
        }
    }
    
    /******************************************************************************************
                save registration - processing extra contact/application fields
                function input : extra front-end fields(except five login fields) and contact
                function output: update those extra fields to corresponding sobject records
    ******************************************************************************************/
    public void processingExtraFields(Contact ct){
        // assign values to record
        if(ct != null && customFields != null){
        for(Portal_CustomField x : customFields){
            if(x != null && x.objectName != null && (x.objectName.tolowerCase().equals('contact'))){
                if (x.fldType == 'String' || x.fldType == 'Picklist'|| x.fldType == 'Phone') 
                ct.put(x.fieldname, x.inputText);
                if (x.fldType == 'Multipicklist') ct.put(x.fieldname, x.inputTextList);
                if (x.fldType == 'Number') ct.put(x.fieldname, x.inputNumber);
                if (x.fldType == 'Decimal') ct.put(x.fieldname, x.inputDecimal);
                if (x.fldType == 'Checkbox') ct.put(x.fieldname, x.inputCheckbox);
                if (x.fldType == 'Date') ct.put(x.fieldname, Date.parse(x.inputDate.trim()));

                System.debug('------------------------------>'+x.fieldName + '<--------------'+x.inputText);
                if (x.inputText != null && x.fldType == 'reference' ) ct.put(x.fieldname, x.inputText); 
                // find app.school_c.child__c field, then assign with x.childrenInputText
                if (x.hasChildren && x.childrenInputText != null && x.fldType == 'reference') ct.put(x.childrenFieldAPI, x.childrenInputText);
                // find app.school__c.grandChild__c field, then assign with x.grandCHild
                if (x.hasGrandChildren && x.grandChildrenInputText != null && x.fldType == 'reference') ct.put(x.grandChildrenFieldAPI,x.grandChildrenInputText);
            }
        }
        upsert ct;
        
        processingExtraFieldsForApp(ct);
        }
    }
    
    /*************************************************************************
        @parameters: contact
        @function: update related app fields which get from front-end page
    **************************************************************************/
    public void processingExtraFieldsForApp(Contact ct){
        List<EnrollmentrxRx__Enrollment_Opportunity__c> appList; // for applist related with contact
        String sqlStr = ''; // for app query
        List<Portal_CustomField> appFields = new List<Portal_CustomField>(); // app fields
        
        //get relate app if it is existed
        
        for(Portal_CustomField p : customFields){
            if(p.objectName.trim().tolowerCase().equals('enrollmentrxrx__enrollment_opportunity__c')){
            sqlStr += p.fieldName;
            sqlStr += ',';
            appFields.add(p);
            }
        }
        
        if(appFields != null && appFields.size() > 0 && ct.Id != null){
            sqlStr = sqlStr.subString(0, sqlStr.length() - 1);
            if(ct.EnrollmentrxRx__Active_Enrollment_Opportunity__c != null){
                sqlStr ='SELECT '+sqlStr+ ' FROM EnrollmentrxRx__Enrollment_Opportunity__c' +' WHERE Id = '+ '\''+ ct.EnrollmentrxRx__Active_Enrollment_Opportunity__c+'\'';
            }
            else{
                sqlStr ='SELECT '+sqlStr+ ' FROM EnrollmentrxRx__Enrollment_Opportunity__c' +' WHERE EnrollmentrxRx__Applicant__c = '+ '\''+ ct.Id+'\'';
            }
            appList = Database.query(sqlStr);
        }
        //get exposed app and assign value to record
        if(appList != null && appList.size() > 0 ){
                 for(Portal_CustomField x : appFields){
                    //standard fields
                    if (x.fldType == 'String' || x.fldType == 'Picklist'|| x.fldType == 'Phone') 
                    appList[0].put(x.fieldname, x.inputText);
                    if (x.fldType == 'Multipicklist') appList[0].put(x.fieldname, x.inputTextList);
                    if (x.fldType == 'Number') ct.put(x.fieldname, x.inputNumber);
                    if (x.fldType == 'Decimal') appList[0].put(x.fieldname, x.inputDecimal);
                    if (x.fldType == 'Checkbox') appList[0].put(x.fieldname, x.inputCheckbox);
                    if (x.fldType == 'Date') ct.put(x.fieldname, Date.parse(x.inputDate.trim()));
                    
                    //referece number is not static variable, using loop
                    if (x.inputText != null && x.fldType == 'reference' ) appList[0].put(x.fieldname, x.inputText); 
                    // find app.school_c.child__c field, then assign with x.childrenInputText
                    if (x.hasChildren && x.childrenInputText != null && x.fldType == 'reference') appList[0].put(x.childrenFieldAPI, x.childrenInputText);
                    // find app.school__c.grandChild__c field, then assign with x.grandCHild
                    if (x.hasGrandChildren && x.grandChildrenInputText != null && x.fldType == 'reference') appList[0].put(x.grandChildrenFieldAPI,x.grandChildrenInputText);
                }
                
                update appList;
            } 
        
    }
    
}