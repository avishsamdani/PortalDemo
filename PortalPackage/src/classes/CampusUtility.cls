/* **************************************************************************************
* ? 2015 Enrollment Rx, LLC. All Rights Reserved
*
* Public class: CampusUtility
  static utility methods for campus package
*   
* Created by Arpit Sharma, Enrollmentrx: Feb/17/2015
*****************************************************************************************/
public with sharing class CampusUtility {
   
   /*
     Returns a List<SelectOption> for a given picklist field
   */    
   public static List<SelectOption> getPickListValues(Schema.Describefieldresult fldDesc, boolean blankFirstValue) {
        List<SelectOption> rtnValue = new List<SelectOption>();
        
        if (blankFirstValue){
            rtnValue.add(new SelectOption('', ''));
        }
        
        for (Schema.Picklistentry p : fldDesc.getPicklistValues()) {
            if (p.isActive()){
                rtnValue.add(new SelectOption(p.getValue(), p.getLabel())); 
            }
        }
        return rtnValue;
    }
    
    /*
     Returns a List<SelectOption> for a given picklist field
    */ 
    static public Boolean validateId(String idParam) {
        if((idParam.length() == 15 || idParam.length() == 18) && Pattern.matches('^[a-zA-Z0-9]*$', idParam)) {
            return true;
        }
        return false;
    }
    
    
    
   /*
     this method create date from string
   */
   public static Date getDate(String dateValue){
        List<String> dateArr = dateValue.split('/',3);
        Date tempDate;
        if(dateArr.size()>2){
              tempDate = date.newInstance(Integer.valueOf(dateArr[2]),Integer.valueOf(dateArr[0]),Integer.valueOf(dateArr[1]));              
        } 
        return tempDate;
   }
    
   /*
     this method create date from string
   */
   public static String getFormet(String dateValue){
        List<String> dateArr = dateValue.split('-',3);
        String tempDate = dateValue ;
        if(dateArr.size()>2){
              tempDate = Integer.valueOf(dateArr[2])+'/'+Integer.valueOf(dateArr[0])+'/'+Integer.valueOf(dateArr[1]);                
        } 
        return tempDate;
   }
   
   public static String avoidSOQLInjection(string queryStringVal){
        return string.escapeSingleQuotes(queryStringVal);
    }
    
    
    public static void logInfo(string infoMsg){
        system.debug('' + infoMsg);
    }
    
    public static void logError(string errorMsg){
        system.debug('' + errorMsg);
    }
    
    public static void logWarning(string warningMsg){
        system.debug('' + warningMsg);
    }
    
    public static void logAndThrow(string msg){
        system.debug('' + msg); 
       // throw new CampusPackageException('' + '' + msg);
    }
    
    public static String getNameSpacePerfix(){
        String namespace = null;
        List<ApexClass> apxs = [SELECT NameSpacePrefix 
                         FROM ApexClass
                         WHERE Name = 'CampusUtility' and NameSpacePrefix != null];
            if(apxs.size() > 0) {
              namespace = apxs[0].NameSpacePrefix;
            } else {
           namespace = '';
            }         
        
         return namespace;   
    }
    
    public static String getReferencedObjectNameByObjectNameAndFieldName(String objectName, String fieldName) {
      String returnObjectName = null;
      Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
    Schema.SObjectType objchema = schemaMap.get(objectName);
    if(objchema != null) {
      Map<String, Schema.SObjectField> mapoffields = objchema.getDescribe().fields.getMap();
      SObjectField fieldToken = mapoffields.get(fieldName);
      if(fieldToken != null) {
        returnObjectName = String.valueOf(fieldToken.getDescribe().getReferenceTo()[0]);
      }
    }
    return returnObjectName;
    }
    
    public static Schema.Describefieldresult getFieldDescResult(String packageName, String objectName, String fieldName, Schema.SObjectType sObjectTypeObj) {
        Map<String, Schema.SObjectField> mapOfFields = sObjectTypeObj.getDescribe().fields.getMap();
    SObjectField fieldToken = mapOfFields.get(fieldName);
    return fieldToken.getDescribe();
    }
    
    public static List<SelectOption> getPickListValuesForMultiSelect(Schema.Describefieldresult fldDesc, boolean blankFirstValue) {
        List<SelectOption> rtnValue = new List<SelectOption>();
        
        if (blankFirstValue){
            rtnValue.add(new SelectOption('', '*'));
        }
        
        for (Schema.Picklistentry p : fldDesc.getPicklistValues()) {
            if (p.isActive()){
                rtnValue.add(new SelectOption(p.getValue(), p.getLabel())); 
            }
        }
        return rtnValue;
    }
    
    public static List<SelectOption> getPickListValuesWithFirstNone(Schema.Describefieldresult fldDesc, boolean blankFirstValue) {
        List<SelectOption> rtnValue = new List<SelectOption>();
        
        if (blankFirstValue){
            rtnValue.add(new SelectOption('', '-None-'));
        }
        
        for (Schema.Picklistentry p : fldDesc.getPicklistValues()) {
            if (p.isActive()){
                rtnValue.add(new SelectOption(p.getValue(), p.getLabel())); 
            }
        }
        return rtnValue;
    }  
}