/**
*The purpose of this class is to reduce the Describe limits and increasing performance of your app
*author:Sandeep
**/
public with sharing class SchemaCache {
    private static Map<String, SObjectType> gdMap {get;set;}
    private static Map<String, DescribeSobjectResult> dsrMap = new Map<String, DescribeSobjectResult>();
    private static Map<String, DescribeFieldResult> dfrMap = new Map<String, DescribeFieldResult>();
    private static Map<String, Map<String, Schema.SObjectField>> sObjFldMap = new Map<String, Map<String, Schema.SObjectField>>();
     
    //Only retrive map of sobjects if not already retrieved
    public static Map<String, SObjectType> getGlobalDescribeMap() { 
        if(gdMap == null) {
            gdMap = Schema.getGlobalDescribe();
        }
        return gdMap;
    }
     
    //Describe an object only once otherwise returns already described
    public static DescribeSobjectResult getSobjectDescribe(String obj) { 
        try {
            if(!dsrMap.containsKey(obj)) { 
                dsrMap.put(obj, getGlobalDescribeMap().get(obj).getDescribe());
            }
        } catch (Exception e) {
            ERx_PortalPackUtil.logAndThrow(e.getMessage() + '***obj***' + obj + '###' + e.getStackTraceString() + '***' + getGlobalDescribeMap().get(obj));
        }
        return dsrMap.get(obj);
    } 
     
    //Return map of sobject obj's field using efficient approach
    public static Map<String, Schema.SObjectField> getSobjectFieldsMap(String obj) {
        try {
          if(!sObjFldMap.containsKey(obj)) {
                sObjFldMap.put(obj, getSobjectDescribe(obj).fields.getMap());
            }
        } catch (Exception e) {
            ERx_PortalPackUtil.logAndThrow(e.getMessage() + '***obj' + obj +'&&&'+ e.getStackTraceString());
        }
        return sObjFldMap.get(obj); 
    }
     
    //Describe a field of an object only once otherwise returns field already described
    public static DescribeFieldResult getFieldDescribe(String obj, String fld) {
      
      String key = obj+'___'+fld;
        try {
          if(!dfrMap.containsKey(key)) {           
              dfrMap.put(key, getSobjectFieldsMap(obj).get(fld).getDescribe());
            }
        } catch (Exception e) {
            ERx_PortalPackUtil.logAndThrow(e.getMessage() + '***obj' + obj + '###fld' + fld + '###' + e.getStackTraceString());
        }
        return dfrMap.get(key);
    }
}