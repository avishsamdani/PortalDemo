/**
 * @author : Avish Samdani (Metacube)
 * @date : 25-02-2016
 * @description : Lookup Picklist Value Controller
 * @name : PortalPackageUtility.cls
 * @type: Utility 
 */
public with sharing class PortalPackageUtility {
	
	/**
    * Method is used to read the field set and returns the field list
    *
    */
	public static List<Schema.FieldSetMember> readFieldSetbyFieldSetNameAndObj(String fieldSetName, Schema.SObjectType SObjectTypeObj) {
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
        Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName);
        if(fieldSetObj == null) {
            return null;
        }
        return fieldSetObj.getFields();
    }
    
    /**
    * Method Returns The Prefix Namae Spaces.
    *
    */
    public static String getNameSpacePerfix(){
        String namespace = null;
        List<ApexClass> apxs = [SELECT NameSpacePrefix 
                         FROM ApexClass
                         WHERE Name = 'PortalPackageUtility' and NameSpacePrefix != null];
            if(apxs.size() > 0) {
              namespace = apxs[0].NameSpacePrefix;
            } else {
           namespace = '';
            }         
        
         return namespace;   
    }
    
    /**
    * Method is used to escape quotes in String.
    *
    */
    public static String escapeQuotes(String str) {
        if(!String.IsBlank(str)) {
            str = String.escapeSingleQuotes(str);
        }
        return str;
    }
    
    /**
    * Methos used to find the element in list.
    *
    */
    public static boolean isElementFoundInList(List<String> elementList, String element) {
    	boolean isFound = false;
    	for(String ele : elementList) {
    		if(ele == element) {
    			isFound = true;
    			break;
    		}    		
    	}
    	return isFound;
    } 
}