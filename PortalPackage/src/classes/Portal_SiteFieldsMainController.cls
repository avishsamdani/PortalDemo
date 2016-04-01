public class Portal_SiteFieldsMainController {
	
	public Id frontEndObjectId {get;set{frontEndObjectId = value;}}
	public string frontFieldId {get;set{frontFieldId = value;}}
	public string frontEnvId  {get; set{frontEnvId = value;}}
    public string editTag {get; set{editTag = value;}}


	public List<Portal_Login_Custom_Field__c> fieldsList{get;set;}
    //public String self_RegURL {get;set;}
    public String customSettingURL {get;set;}
	public String registrationURL {get;set;}
	public Site_Login_Setting__c settings {get;set;}
	
	public Portal_SiteFieldsMainController(){
		//get all Portal Login Custom Field

		//settings = Site_Login_Setting__c.getValues(Site.getName());
		//if(settings != null){
		//	customSettingURL = settings.CustomSettingURL__c;
		//	RegistrationURL = settings.RegistrationURL__c;
		//}
        Env__c curEnv = [Select Self_Register_URL__c from Env__c where Id =: getCurrentEnv().Env__c];

        registrationURL = curEnv.Self_Register_URL__c;

	}
	



	public Current_Env__c getCurrentEnv(){

        return ERx_PortalPackUtil.getCurrentEnvForConfiguration();
    }

	public list<Portal_Login_Custom_Field__c> getFieldList(){
		list<Portal_Login_Custom_Field__c> returnMe = new list<Portal_Login_Custom_Field__c>();

		if(getCurrentEnv() != null){


		    returnMe = [SELECT Id,Name,Active__c,Children_Field_API_Name__c,
			Children_Field_Label__c, Children_Index_Field_API__c, Children_Objects_API__c,
			Display_Order__c, Field_API_Name__c, Grand_Children_Field_API_Name__c,
			Grand_Children_Field_Label__c, Grand_Children_Index_Field_API__c,
			Grand_Children_Objects_API__c,	Is_Field_Required__c, Linked_to_Portal__c,
			Look_Up_Field__c, 	Object_Name__c, Env__c
			FROM Portal_Login_Custom_Field__c 
			WHERE Env__c = : getCurrentEnv().Env__c
			ORDER BY Name];
		}
	    return returnMe;
    }





	public void deleteField(){
    	Portal_Login_Custom_Field__c deletingRecord = new Portal_Login_Custom_Field__c();
    	if(frontEndObjectId != null){
				try{
					delete deletingRecord = [select id from Portal_Login_Custom_Field__c where Id = : frontEndObjectId];
				}catch(Exception e){
		    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() ));
		    		//return null;
		    }
		}
	}
	
	public void editField(){
		
	}
	
	public PageReference validate(){
		if(RegistrationURL != null){
			PageReference pf = new PageReference(RegistrationURL);
			pf.setRedirect(true);
			return pf;
		}
		else{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please Check Custom Setting,Registration Page URL Can not be Empty'));
			return null;
		}
	}








































	/****************************************
		individual field editing
	*****************************************/

        public Map<String, Schema.SObjectField> contactFields {get;set;}
        public Map<String, Schema.SObjectField> appFields {get;set;}
        public Map<String, Schema.SObjectField> currFieldSet{get;set;}
        public Portal_Login_Custom_Field__c f{get;set;}
        //front - end sobject name
        public String fieldType {get;set;}
        public boolean isEdit {get;set;}
        

        public PageReference initPage(){
            f = new Portal_Login_Custom_Field__c();
            if(frontFieldId != null && frontFieldId != ''){
                if( frontFieldId != 'newStartMode'){
                    isEdit = true;
                    //Portal_Login_Custom_Field__c ef = null;

                    this.f = 
                    [select Id,Name,Active__c,Children_Field_API_Name__c, Children_Field_Label__c, Children_Index_Field_API__c, Children_Objects_API__c,
                    Display_Order__c, Field_API_Name__c, Grand_Children_Field_API_Name__c,Grand_Children_Field_Label__c, Grand_Children_Index_Field_API__c,
                    Grand_Children_Objects_API__c,  Is_Field_Required__c, Linked_to_Portal__c,FieldType__c, Look_Up_Field__c, Object_Name__c,Has_GrandChildren__c,
                    queryCriteria__c,childQueryCriteria__c,gdChildQueryCriteria__c, Env__c
                    FROM Portal_Login_Custom_Field__c  where Id = : frontFieldId];
                    
                }else{
                    isEdit = false;
                    f = null;
                    f = new Portal_Login_Custom_Field__c();
                    f.Env__c = getCurrentEnv().Env__c;
                    
                }
                contactFields = getFieldsMap('Contact');
                appFields = getFieldsMap('EnrollmentrxRx__Enrollment_Opportunity__c');
            }
            return null;
        }


/*--------------------------------------------------------------------------------------------------
    @provide the support field type for user choosing and display
    corresponding field(s) for next question
*--------------------------------------------------------------------------------------------------*/
    public List<SelectOption> getSupportFieldType(){
        list<SelectOption> fieldTypeList = new list<SelectOption>();
        fieldTypeList.add(new SelectOption('-- None --','-- None --'));
        fieldTypeList.add(new SelectOption('STRING','String'));
        fieldTypeList.add(new SelectOption('PICKLIST','PickList'));
        fieldTypeList.add(new SelectOption('PHONE','Phone'));
        fieldTypeList.add(new SelectOption('EMAIL','Email'));
        fieldTypeList.add(new SelectOption('REFERENCE','Lookup'));
        fieldTypeList.add(new SelectOption('BOOLEAN','Checkbox'));
        fieldTypeList.add(new SelectOption('DATE','Date'));
        fieldTypeList.add(new SelectOption('DOUBLE','Number'));
        //fieldTypeList.add(new SelectOption('MULTIPICKLIST','multipicklist'));
        
        return fieldTypeList;
    } 


/*----------------------------------------------------------------------------------------------------
    @filter the fields on type
------------------------------------------------------------------------------------------------------*/
    public List<SelectOption> getSupportFields(){
        //create support type
        list<SelectOption> fieldsList = new list<SelectOption>();
        SelectOption sop = new SelectOption('','-- None --');
        fieldsList.add(sop);
        
        if(f.Object_Name__c != null){
            if(String.valueOf(f.Object_Name__c).trim().equals('Contact')){
                currFieldSet = contactFields;
            }
            else{
                currFieldSet = appFields;
            }
            //get field type
            //System.debug('----------------------------->here'+FieldType__c);
            if(f.FieldType__c != null && f.FieldType__c != ''){
	            for(String fdName : currFieldSet.keySet()){
	                Schema.SObjectField cf = currFieldSet.get(fdName);
	                Schema.DescribeFieldResult fd = cf.getDescribe();
	                if(fd.isAccessible() && fd.getType().name().equals(f.FieldType__c.trim())){
	                    fieldsList.add(new SelectOption(fdName.trim(),fd.getLabel()+' : '+fdName.trim()));
	                }
	            }
            }
            
            else{
            	for(String fdName : currFieldSet.keySet()){
	                Schema.SObjectField cf = currFieldSet.get(fdName);
	                Schema.DescribeFieldResult fd = cf.getDescribe();
	                if(fd.isAccessible() ){
	                    fieldsList.add(new SelectOption(fdName.trim(),fd.getLabel()+' : '+fdName.trim()));
	                }
	            }
            }
            
            fieldsList.sort();
            
        }
        
        return fieldsList;
    }
    
    /***************************************************************************************************************
    @ get children api list
    ****************************************************************************************************************/
    public List<SelectOption> getReferenceFields(){
        List<SelectOption> fieldsList = new List<SelectOption>();
        SelectOption sop = new SelectOption('','-- none --');
        fieldsList.add(sop);
        
        if(f.Object_Name__c != null){
            
            if(String.valueOf(f.Object_Name__c).trim().equals('Contact')){
                currFieldSet = contactFields;
            }
            else{
                currFieldSet = appFields;
            }
            //get field type
            
            for(String fdName : currFieldSet.keySet()){
                Schema.SObjectField cf = currFieldSet.get(fdName);
                Schema.DescribeFieldResult fd = cf.getDescribe();
                System.debug('--fieldName----->'+fd.getType().name());
                if(fd.isAccessible() && fd.getType().name().equals('REFERENCE')){
                    fieldsList.add(new SelectOption(fdName.trim(),fd.getLabel()+' : '+fdName.trim()));
                }
            }
        }
        
        return fieldsList;
    }
    
    /***************************************************************************************************************
            @ get all sobject name
    ****************************************************************************************************************/
    public List<SelectOption> getAllSobject(){
        List<SelectOption> objsList = new List<SelectOption>();
        objsList.add(new SelectOption('','-- none --'));
        Map<String, Schema.SObjectType> globalDescribeMap = Schema.getGlobalDescribe(); 
        for(String objName : globalDescribeMap.keySet()){
            Schema.SObjectType sobj = globalDescribeMap.get(objName);
            Schema.DescribeSObjectResult o = sobj.getDescribe();
            if(o.isAccessible() && o.isCustom() && !o.isCustomSetting()){
                //objsList.add(new SelectOption(o.getName().trim(),o.getLabel()+' : '+o.getName().trim()));
            	objsList.add(new SelectOption(o.getName().trim(),o.getLabel()+' : '+o.getName().trim()));
            }
        }
        return objsList;
    }
    
     /***************************************************************************************************************
            @ get related sobject name
    ****************************************************************************************************************/
    public List<SelectOption> getChildSobject(){
        List<SelectOption> childrenObjsList = new List<SelectOption>();
        childrenObjsList.add(new SelectOption('','-- none --'));
        List<Schema.SObjectType> tarObj = null;
        if(f.Field_API_Name__c != null && f.Children_Field_API_Name__c!=null){
        	//we have relationship name - need obj name
        	Map<String, Schema.SObjectField> fldSet = Schema.getGlobalDescribe().get(f.Object_Name__c.trim()).getDescribe().fields.getMap();
        	Schema.SObjectField tarLookup = null;
        	for(String fdName : fldSet.keySet()){
        		if(fdName != null && fdName.equals(f.Children_Field_API_Name__c)){
        			 tarLookup = fldSet.get(fdName);
        		}
        	}
		    if(tarLookup != null){
		    	tarObj = tarLookup.getDescribe().getReferenceTo();
		    	for(Schema.SObjectType ele : tarObj){
				    if(ele != null){
					     Schema.DescribeSObjectResult o = ele.getDescribe();
					     childrenObjsList.add(new SelectOption(o.getName().trim(),o.getLabel()+' : '+o.getName().trim()));
				    }
		    	}
		    }
        }
        return childrenObjsList;
    }
    
     /***************************************************************************************************************
            @ get grandchildren sobject name
    ****************************************************************************************************************/
    public List<SelectOption> getGrandChildSobject(){
        List<SelectOption> childrenObjsList = new List<SelectOption>();
        childrenObjsList.add(new SelectOption('','-- none --'));
        List<Schema.SObjectType> tarObj = null;
        if(f.Field_API_Name__c != null && f.Children_Field_API_Name__c!=null && f.Grand_Children_Field_API_Name__c != null){
        	//we have relationship name - need obj name
        	Map<String, Schema.SObjectField> fldSet = Schema.getGlobalDescribe().get(f.Object_Name__c.trim()).getDescribe().fields.getMap();
        	Schema.SObjectField tarLookup = null;
        	for(String fdName : fldSet.keySet()){
        		if(fdName != null && fdName.equals(f.Grand_Children_Field_API_Name__c)){
        			 tarLookup = fldSet.get(fdName);
        		}
        	}
		    if(tarLookup != null){
		    	tarObj = tarLookup.getDescribe().getReferenceTo();
		    	for(Schema.SObjectType ele : tarObj){
				    if(ele != null){
					     Schema.DescribeSObjectResult o = ele.getDescribe();
					     childrenObjsList.add(new SelectOption(o.getName().trim(),o.getLabel()+' : '+o.getName().trim()));
				    }
		    	}
		    }
        }
        return childrenObjsList;
    }
    
    /*********************************************************************************************
        @ get all related children object API as string 
    **********************************************************************************************/
    public List<SelectOption> getAllChildrenRelatedAPIName(){
        List<SelectOption> relationList = new List<SelectOption>();
        relationList.add(new SelectOption('','-- none --'));
        if(f.Children_Objects_API__c != null){
            Map<String, Schema.SObjectField> objDesMap = getFieldsMap(String.valueOf(f.Children_Objects_API__c).trim());
            for(String fdName : objDesMap.keySet()){
                Schema.SObjectField cf = objDesMap.get(fdName);
                Schema.DescribeFieldResult fd = cf.getDescribe();
                if(fd.isAccessible() && fd.getType().name().equals('REFERENCE')){
                    relationList.add(new SelectOption(fdName.trim(),fd.getLabel()+' : '+fdName.trim()));
                }
            }
        }
        return relationList;
    } 
    
    /*********************************************************************************************
        @ get all related children object API as string 
    **********************************************************************************************/
    public List<SelectOption> getAllGrandChildrenRelatedAPIName(){
        List<SelectOption> relationList = new List<SelectOption>();
        relationList.add(new SelectOption('','-- none --'));
        if(f.Grand_Children_Objects_API__c != null){
            Map<String, Schema.SObjectField> objDesMap = getFieldsMap(String.valueOf(f.Grand_Children_Objects_API__c).trim());
            for(String fdName : objDesMap.keySet()){
                Schema.SObjectField cf = objDesMap.get(fdName);
                Schema.DescribeFieldResult fd = cf.getDescribe();
                if(fd.isAccessible() && fd.getType().name().equals('REFERENCE')){
                    relationList.add(new SelectOption(fdName.trim(),fd.getLabel()+' : '+fdName.trim()));
                }
            }
        }
        return relationList;
    } 
    
    /***************************************************************************************************************
        @prepare field
    ****************************************************************************************************************/
    public void hideEdit(){
    	this.editTag = 'hide';
    	//return null;
    }
    public void addField(){
        //if(!validateFields()){
        //    Apexpages.addMessage(new Apexpages.Message(Apexpages.severity.ERROR, 'Please fill all required field information.')); 
        //    return null;
        //}
        
        //else if(!validateRelationship()){
        //	Apexpages.addMessage(new Apexpages.Message(Apexpages.severity.ERROR, 'Field relationship is not correct.')); 
        //	return null;
        //}
        
        //else if(!isEdit && isDuplicateFieldExist()){
        //	 Apexpages.addMessage(new Apexpages.Message(Apexpages.severity.ERROR, 'Field is existed.')); 
        //	 return null;
        //}
        //else{
        	system.debug('enriiiiii'+f.Id);
         	system.debug('enriiiiii'+f.Name);
         	system.debug('enriiiiii'+f.Field_API_Name__c);

            if(this.f.Id != null){
                update f;
            }else{
            	insert f;
            }
            this.editTag = 'hide';
            //Apexpages.addMessage(new Apexpages.Message(Apexpages.severity.CONFIRM, 'Field is added. You can close the window.')); 
            //PageReference pf = new PageReference('/apex/Portal_RegistrationSetting');
            //pf.setRedirect(true);
        	//return null;
        //}   
    }
    
    /************************************************************************************************************
    	@validate lookup relationship
    *************************************************************************************************************/
    public boolean validateRelationship(){
    	
    	return true;
    }
    
    /***********************************************************************************
    	@find duplicate field in list
    *************************************************************************************/
    public boolean isDuplicateFieldExist(){
    	List<Portal_Login_Custom_Field__c> dupFieldList=[SELECT Id,Name,Active__c,Children_Field_API_Name__c,
		Children_Field_Label__c, Children_Index_Field_API__c, Children_Objects_API__c,
		Display_Order__c, Field_API_Name__c, Grand_Children_Field_API_Name__c,
		Grand_Children_Field_Label__c, Grand_Children_Index_Field_API__c,
		Grand_Children_Objects_API__c,	Is_Field_Required__c, Linked_to_Portal__c,
		Look_Up_Field__c, Object_Name__c FROM Portal_Login_Custom_Field__c WHERE Field_API_Name__c =: f.Field_API_Name__c];
    	
    	if(dupFieldList != null && dupFieldList.size() > 0){
    		return true;
    	}
    	else{
    		return false;
    	}
    }
    
    public boolean validateFields(){
        if(f.Name == null || 
        (!isEdit && f.FieldType__c == null) || 
        f.Object_Name__c == null || 
        f.Display_Order__c == null || 
        f.Linked_to_Portal__c == null){
            return false;
        }
        
        if(f.Look_Up_Field__c && (f.Children_Field_API_Name__c == null || 
        f.Children_Field_Label__c == null || 
        f.Children_Objects_API__c == null || 
        f.Children_Index_Field_API__c == null)){
            return false;
        }
        
        if(f.Has_GrandChildren__c && (f.Grand_Children_Field_API_Name__c == null || 
        f.Grand_Children_Field_Label__c == null || 
        f.Grand_Children_Objects_API__c == null || 
        f.Grand_Children_Index_Field_API__c == null)){
            return false;
        }
        return true;
    }
    
    /**************************************************************************
        clear the input when input checkbox not selected
    ****************************************************************************/
    public void clearChildrenInput(){
        if(!f.Look_Up_Field__c || f.fieldType__c != 'REFERENCE'){
        	f.Look_Up_Field__c = false;
            f.Has_GrandChildren__c = false;
            f.Children_Field_API_Name__c=null;
            f.Children_Field_Label__c= null;
            f.Children_Objects_API__c=null;
            clearGrandChildrenInput();
        }
    }
    
    public void clearGrandChildrenInput(){
        if(!f.Has_GrandChildren__c || f.fieldType__c != 'REFERENCE'){
            f.Grand_Children_Field_API_Name__c = null;
            f.Grand_Children_Field_Label__c = null;
            f.Grand_Children_Objects_API__c = null;
            f.Grand_Children_Index_Field_API__c = null;
        }
    }
    
    public pageReference cancel(){
        PageReference pf = new PageReference('/apex/Portal_RegistrationSetting');
        pf.setRedirect(true);
        return pf;
    }

/*---------------------------------------------------------------------------------------------------------
	@fieldAPI Action
-----------------------------------------------------------------------------------------------------------*/
  	public void fieldAPIAction(){
  		if(currFieldSet.get(String.valueOf(f.Field_API_Name__c)).getDescribe().getType().name() != 'REFERENCE'){
  			clearChildrenInput();
  		}
  		else{
  			f.fieldType__c='REFERENCE';
  		}
  	}  
/*-----------------------------------------------------------------------------------------------------------
    @provide the field API list for select
-----------------------------------------------------------------------------------------------------------*/
    //create pick list on the head
    //validate fields in contact and application
    //insert fields
    //navigate to site login page if every thing is ready
    //selectlist like error messages, field info pop
    
/*------------------------------------------------------------------------------------------------------
    @get all of the fields
-------------------------------------------------------------------------------------------------------------*/
        //get one sobject fieldName/sobject field mapping by passing SobjectName
    public Map<String, Schema.SObjectField> getFieldsMap(String objectName) {  
        Map<String, Schema.SObjectType> globalDescribeMap = Schema.getGlobalDescribe(); 
        Schema.SObjectType sObjectTypeObj = globalDescribeMap.get(objectName);
        return sObjectTypeObj.getDescribe().fields.getMap();
    }
}