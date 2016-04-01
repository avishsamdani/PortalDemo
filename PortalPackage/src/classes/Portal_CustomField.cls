public  class Portal_CustomField {
    public string label        { get; private set; }
    public string fldType      { get; private set; }   // String | Picklist | Integer | Decimal | Checkbox
    public string objectName   { get; private set; }
    public string fieldName    { get; private set; }
    public boolean isRequired  { get; private set; }
    public boolean lookUpField  { get; private set; }
    //public boolean isRequired  { get; private set; }
    public integer sortOrder;
    
    //front-page input
    public string inputText         	{ get; set; }
    public list<string> inputTextList   { get; set; }
    public boolean inputCheckBox   		{ get; set; }
    public integer inputNumber    		{ get; set; }
    public decimal inputDecimal    		{ get; set; }
    public String inputDate				{ get; set; }
    public String queryCriteria			{ get;set;  }
    public boolean hasCriteria			{ get;set;  }
    
    public list<SelectOption> options { get; private set; }

    public boolean hasChildren	{ get; set; }
    public string childrenInputText   	{ get; set; }
    public string childrenLabel   	{ get; set; }
    public string childrenFieldAPI   	{ get; set; }
    public String childQueryCriteria			{ get;set;  }
    public boolean hasChildCriteria		{get;set;}
    
    
    
    
    //look up field API Name - Select Options Map
    public map<string, list<SelectOption>> childrenMapOptions { get; private set; }

    public boolean hasGrandChildren	{ get; set; }
    public string grandChildrenInputText   	{ get; set; }
    public string grandChildrenLabel   	{ get; set; }
    public string grandChildrenFieldAPI  	{ get; set; }
    public String gdChildQueryCriteria			{ get;set;  }
    public String hasGdChildCriteria			{get;set;}
    public map<string, list<SelectOption>> grandChildrenMapOptions { get; private set; }
    
    /*********************************************************************************
    	one field processing
    *********************************************************************************/
	public Portal_CustomField(Portal_Login_Custom_Field__c cf) {
		
       	label = cf.Name;
        objectName = cf.Object_Name__c;
        fieldName = cf.Field_API_Name__c;
		childrenFieldAPI = cf.Children_Field_API_Name__c;
        grandChildrenFieldAPI = cf.Grand_Children_Field_API_Name__c;
        isRequired = cf.Is_Field_Required__c;
        lookUpField = cf.Look_Up_Field__c;
        hasChildren = (cf.Children_Objects_API__c != null);
        childrenLabel = cf.Children_Field_Label__c;
        hasGrandChildren = (cf.Grand_Children_Objects_API__c != null);
        grandChildrenLabel = cf.Grand_Children_Field_Label__c;
        queryCriteria = cf.queryCriteria__c;
        childQueryCriteria = cf.childQueryCriteria__c;
        gdChildQueryCriteria = cf.gdChildQueryCriteria__c;
        //get contact and application describe result.
        map<String, Schema.SObjectField> contactFields = Schema.SObjectType.Contact.fields.getMap();
       	map<String, Schema.SObjectField> applicationFields = Schema.SObjectType.EnrollmentrxRx__Enrollment_Opportunity__c.fields.getMap();
       	Schema.DescribeFieldResult fldDescribe;

        if (objectName.toLowerCase() == 'contact') {
        	fldDescribe = contactFields.get(cf.Field_API_Name__c).getDescribe();
        }
        else{ 
        	fldDescribe = applicationFields.get(cf.Field_API_Name__c).getDescribe();
        }
        
        // Field Types
        if (fldDescribe.getType().name() == 'BOOLEAN')
            fldType = 'Checkbox';
        else if (fldDescribe.getType().name() == 'DATE'){
            fldType = 'Date';
            this.label += ' (MM/DD/YYYY)';
            //populatePickerDates(cf);                
        }else if (fldDescribe.getType().name() == 'DATETIME'){
            fldType = 'Date';
            this.label += ' (MM/DD/YYYY)';
        }
        else if (fldDescribe.getType().name() == 'STRING' || fldDescribe.getType().name() == 'EMAIL')
            fldType = 'String';
        else if (fldDescribe.getType().name() == 'PHONE')
            fldType = 'Phone';
        else if (fldDescribe.getType().name() == 'MULTIPICKLIST'){
            options = Portal_LoginUtil.getPickListValues(fldDescribe, true);
            fldType = 'Multipicklist';
        }
        else if (fldDescribe.getType().name() == 'TEXTAREA')
            fldType = 'TextArea';
        else if (fldDescribe.getType().name() == 'DOUBLE')
            fldType = 'Decimal';
        else if (fldDescribe.getType().name() == 'DOUBLE')
            fldType = 'Number';
        else if (fldDescribe.getType().name() == 'CURRENCY')
            fldType = 'Decimal';
        else if (fldDescribe.getType().name() == 'PICKLIST' || fldDescribe.getType().name() == 'COMBOBOX') {
            // If this is a picklist field, get the current picklist values for that field
            options = Portal_LoginUtil.getPickListValues(fldDescribe, true);
            fldType = 'Picklist';
        }else if (fldDescribe.getType().name() == 'REFERENCE') {
            // If this is a picklist field, get the current picklist values for that field
            //options = getPickListValues(fldDescribe, true);
            fldType = 'Reference';
        }

        //process lookup field
        if(fldType == 'Reference'){
        	String criteria = '';
        	if(queryCriteria != null && queryCriteria != ''){
        		criteria += ' WHERE '+ queryCriteria.trim();
        	}
        	
        	list<Sobject> objList = new list<Sobject>();
        	string queryStr = 'SELECT Name,Id FROM ' + fldDescribe.getReferenceTo().get(0).getDescribe().getName()+criteria;
        	System.debug('curQuery---->'+queryStr);
        	objList = Database.query(queryStr);
			//set of ID for children query
			set<Id> parentIdSet = new set<Id>();
			set<Id> parentIdSet2 = new set<Id>();
			
        	if(objList.size() > 0){
        		options = new list<SelectOption>();
        		options.add(new SelectOption('', '-- Please Select --'));
        		for(Sobject o : objList){
        			options.add(new SelectOption((string)o.get('Id'), (string)o.get('Name')));
        			parentIdSet.add((Id)o.get('Id'));
        		}
        	}

        	if(cf.Children_Objects_API__c != null){
        		String chcriteria = '';
        		if(childQueryCriteria != null && childQueryCriteria != ''){
        			chcriteria = ' AND '+childQueryCriteria.trim();
        		}
        		childrenMapOptions = new map<string, list<SelectOption>>();
        		string qStr = 'SELECT Name,Id,'+cf.Children_Index_Field_API__c+' FROM '+cf.Children_Objects_API__c+' WHERE '+ cf.Children_Index_Field_API__c + ' in: parentIdSet' + chcriteria;
        		list<Sobject> childrenObjList = new list<Sobject>();
        		childrenObjList = Database.query(qStr);
        		for(Sobject s: childrenObjList){
        			parentIdSet2.add((Id)s.get('Id'));
        			if(childrenMapOptions.get((string)s.get(cf.Children_Index_Field_API__c)) == null)
        			childrenMapOptions.put((string)s.get(cf.Children_Index_Field_API__c), new list<SelectOption>());
        		}
        		for(Sobject s: childrenObjList){
        			if(childrenMapOptions.get((string)s.get(cf.Children_Index_Field_API__c)) != null){
        				childrenMapOptions.get((string)s.get(cf.Children_Index_Field_API__c)).add(new SelectOption((string)s.get('Id'),(string)s.get('Name')));
        			}
        		}
        	}

        	if(cf.Grand_Children_Objects_API__c != null){
        		String gchcriteria = '';
        		if(gdChildQueryCriteria != null && gdChildQueryCriteria != ''){
        			gchcriteria = ' AND '+gdChildQueryCriteria.trim();
        		}
        		grandChildrenMapOptions = new map<string, list<SelectOption>>();
        		string qStr = 'SELECT Name,Id,'+cf.Grand_Children_Index_Field_API__c+' FROM '+cf.Grand_Children_Objects_API__c+' WHERE '+ cf.Grand_Children_Index_Field_API__c + ' in: parentIdSet2'+gchcriteria;
        		list<Sobject> grandChildrenObjList = new list<Sobject>();
        		grandChildrenObjList = Database.query(qStr);
        		for(Sobject s: grandChildrenObjList){
        			if(grandChildrenMapOptions.get((string)s.get(cf.Grand_Children_Index_Field_API__c)) == null)
        			grandChildrenMapOptions.put((string)s.get(cf.Grand_Children_Index_Field_API__c), new list<SelectOption>());
        		}
        		for(Sobject s: grandChildrenObjList){
        			if(grandChildrenMapOptions.get((string)s.get(cf.Grand_Children_Index_Field_API__c)) != null){
        				grandChildrenMapOptions.get((string)s.get(cf.Grand_Children_Index_Field_API__c)).add(new SelectOption((string)s.get('Id'),(string)s.get('Name')));
        			}
        		}
        	}
        	
        }
	}

	
	//dynamic display the dependency
    public list<SelectOption> getChildrenOptions(){
        list<SelectOption> returnOpts = new list<SelectOption>();
        returnOpts.add(new SelectOption('','-- Please Select --'));
        if(inputText != null && inputText != '' && childrenMapOptions.get(inputText) != null){
        	returnOpts.addAll(childrenMapOptions.get(inputText));
        }
        return returnOpts;
    }

    //dynamic display the dependency
    public list<SelectOption> getGrandChildrenOptions(){
    	list<SelectOption> returnOpts = new list<SelectOption>();
        returnOpts.add(new SelectOption('','-- Please Select --'));
        if(childrenInputText != null && childrenInputText != '' && grandChildrenMapOptions.get(childrenInputText)!=null){
        	returnOpts.addAll(grandChildrenMapOptions.get(childrenInputText));
        }
        return returnOpts;
    }

}