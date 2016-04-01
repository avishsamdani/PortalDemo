public with sharing class TestPageController{
    private Map<String, List<sObject>> mapOfSobjectList = null;
    private String fieldsToFetchJSON {get;set;}
    private List<WrapperModel> wrapperModelList;
    private List<SectionModelWrapper> sectionmodelWrap;
    public String modelsJSON {get;set;}
    public String jsonData {get;set;}
    
    public TestPageController() {
     try{   
        mapOfSobjectList = new Map<String, List<sObject>>();        
        
        jsonData = '[{"isRepeat":true,"addAnotherbuttonLabel":"Add Another Record","deleteButtonLabel":"Delete Record","title":"High School/Secondary School Information", "modelName":"currentApplication", "noOfcolumn":2, "field": [{"required":true,"isBlank":false, "type":"date", "label":"Graduation Date: (mm/yyyy)", "APIName":"EnrollmentrxRx__ACT_Date_Test_Taken__c","rendered": "true"},{"required":true,"isBlank":false, "type":"picklist", "label":"High School/Secondary School", "APIName":"EnrollmentrxRx__Do_You_Plan_to_Apply_For_Financial_Aid__c","rendered": "true"},{"lookupNameObject":"EnrollmentrxRx__Marketing_Initiatives__c","displayValueAPIName":"EnrollmentrxRx__Marketing_Initiative__r","required":true,"isBlank":false, "type":"lookup", "label":"High School/Secondary School lookup", "APIName":"EnrollmentrxRx__Marketing_Initiative__c", "rendered":"obj.EnrollmentrxRx__Do_You_Plan_to_Apply_For_Financial_Aid__c!=\'Yes\'", "columnNo":1},{"isBlank":true},{"isBlank":true},{"required":true,"isBlank":false, "type":"picklist", "label":"Admission Status", "APIName":"EnrollmentrxRx__Admissions_Status__c","rendered": "true"},{"isBlank":true},{"lookupNameObject":"Contact","required":true,"isBlank":false, "type":"lookup", "label":"Contact","displayValueAPIName":"EnrollmentrxRx__Applicant__r", "APIName":"EnrollmentrxRx__Applicant__c", "rendered":"true"},{"isBlank":true},{"required":true,"isBlank":false, "type":"text", "label":"Parent 1", "APIName":"EnrollmentrxRx__Parent_1__c","rendered": "true"},{"isBlank":true}]},{"isRepeat":true,"addAnotherbuttonLabel":"Add Another Contact","deleteButtonLabel":"Delete Contact","title":"Contact", "modelName":"Contact", "noOfcolumn":2, "field": []}]';
        fieldsToFetchJSON = '[{"modelName": "currentApplication","objectName": "EnrollmentrxRx__Enrollment_Opportunity__c","field": ["EnrollmentrxRx__ACT_Date_Test_Taken__c", "EnrollmentrxRx__Do_You_Plan_to_Apply_For_Financial_Aid__c", "EnrollmentrxRx__Marketing_Initiative__c","EnrollmentrxRx__Applicant__c","EnrollmentrxRx__Admissions_Status__c"  ,"EnrollmentrxRx__Parent_1__c","EnrollmentrxRx__Marketing_Initiative__r.Name","EnrollmentrxRx__Applicant__r.Name"]},{"modelName": "Contact","objectName": "Contact","field": []}]';
          
        wrapperModelList = (List<WrapperModel>) JSON.deserialize(fieldsToFetchJSON, List<WrapperModel>.class);
        sectionmodelWrap = (List<SectionModelWrapper>) JSON.deserialize(jsonData, List<SectionModelWrapper>.class);
        
        Map<String,String> modelAPI = new  Map<String,String>();
        for(WrapperModel w : wrapperModelList){
            modelAPI.put(w.modelName,w.objectName);
        }
        
        
        for(SectionModelWrapper s:sectionmodelWrap){
            for(FieldModelWrapper f :s.field){
                if(f.type == 'picklist'){
                        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
                        Schema.SObjectType objchema = schemaMap.get(modelAPI.get(s.modelName) );
                        
                        Map<String, Schema.SObjectField> mapoffields = objchema.getDescribe().fields.getMap();
                        SObjectField fieldToken = mapoffields.get(f.APIName);
                        DescribeFieldResult selectedField = fieldToken.getDescribe();
                        List<SelectOption> opList = getPickListValues(selectedField,false);
                        
                        List<SelectOpWrap> optionList = new List<SelectOpWrap>();
                        for(SelectOption so : opList){
                            optionList.add(new SelectOpWrap(so.getLabel(),so.getLabel()));
                        }
                    
                        f.selectOptionList = optionList;
                        
                }
            }
            
        }
        
        jsonData = JSON.serialize(sectionmodelWrap);
        for(WrapperModel w : wrapperModelList) {
            List<sObject>  sList = constructSQlList(w.objectName, w.field, w.condition);
            if(sList.size() == 0){
                   sObject sobj  = Schema.getGlobalDescribe().get(w.objectName).newSObject() ;  
                   for(String f : w.field) {
                        sobj.put(f,null);
                   } 
                   sList.add(sobj);
            }
            mapOfSobjectList.put(w.modelName,sList);
        }
      
        modelsJSON = JSON.serialize(mapOfSobjectList);
       }catch(Exception e){
         System.assert(false,e);
       }  
    }
    
    public class SelectOpWrap{
        public String id {get;set;}
        public String name {get;set;}
        public SelectOpWrap(String id ,String name){
            this.id = id;
            this.name = name;
        }
    }
    
     public  List<SelectOption> getPickListValues(Schema.Describefieldresult fldDesc, boolean blankFirstValue) {
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
    
    
    
    public class SectionModelWrapper {
        public String title {get;set;}
        public String modelName {get;set;}
        public List<FieldModelWrapper> field {get;set;}
        public String noOfcolumn {get;set;}
        public boolean isRepeat {get;set;}
        public String buttonLabel {get;set;}
        public String deleteButtonLabel {get;set;}
        
     
    }
    
    
     public class FieldModelWrapper {
        public boolean  required {get;set;}
        public boolean  isBlank {get;set;}
        public String type {get;set;}
        public String label {get;set;}
        public String rendered {get;set;}
        public String APIName {get;set;}
        public String lookupNameObject{get;set;}
        public Integer columnNo{get;set;}
        public List<SelectOpWrap> selectOptionList{get;set;}
        public String displayValueAPIName {get;set;}
        public List<SelectOpWrap> lookupValueList {get;set;} 
        
        public FieldModelWrapper(boolean required, boolean isBlank, String type, String label,String rendered,String APIName,Integer columnNo) {
            this.required = required;  
            this.isBlank = isBlank;
            this.type = type;
            this.label = label;
            this.rendered = rendered;
            this.APIName = APIName;
            this.columnNo = columnNo;
        }
    }
    
    
    
    
    public class WrapperModel {
        public String modelName {get;set;}
        public String objectName {get;set;}
        public List<String> field {get;set;}
        public String condition {get;set;}
        
        public WrapperModel(String modelName, String objectName, List<String> field, String condition) {
            this.modelName = modelName;  
            this.objectName = objectName;
            this.field = field;
            this.condition = condition;
        }
    }
    
    public static List<sObject> constructSQlList (String objectName, List<String> fieldList, String condition) {
        
        String sqlString = 'Select ID,';
        for(String f : fieldList) {
        	if(f.toUpperCase() != 'ID') {
            	sqlString += f + ',';
        	}
        }
        sqlString = sqlString.substring(0, sqlString.length() - 1);     
        sqlString += ' from ' + objectName;
        if(!String.IsEmpty(condition)) {
            sqlString += ' where ' + condition;
        }
        sqlString += '';
       // if(objectName != 'Contact')
     //   system.assert(false, Database.query(sqlString));
        return Database.query(sqlString);
    }
    
    
    @RemoteAction
    public static String deleteData(String deletedId) {
       try{
         delete (Sobject)JSON.deserialize(deletedId,Sobject.class);
       }catch(Exception e){
          System.assert(false,e);
       }
       return null;
    }
    
    @RemoteAction
    public static Map<String, List<sObject>> updateData(String data) {
          Map<String, List<sObject>> mapOfSobjectList = new Map<String, List<sObject>>();
          try {
            
              mapOfSobjectList = (Map<String, List<sObject>>)JSON.deserialize(data, Map<String, List<sObject>>.class);
              //system.assert(false, mapOfSobjectList);
              List<Sobject> objectsToUpdate = new List<Sobject>();
              List<Sobject> objectsToInsert = new List<Sobject>();
              for(List<Sobject> s : mapOfSobjectList.values()) {
                  for(Sobject t : s){
                     if(t.id != null){
                       objectsToUpdate.add(t);
                     }else{
                       objectsToInsert.add(t);
                     }
                  }
                   
                    
              } 
              //System.assert(false, objectsToInsert + '@@@@' + objectsToUpdate);
              insert objectsToInsert;
              update objectsToUpdate;
          } catch (Exception e) {
              system.assert(false, e + '***' + e.getStackTraceString());
          }
          return mapOfSobjectList;            
     }
     
 	@RemoteAction
	public static List<sObject> getLookupDataByObjectAndName(String objectName, String searchStringValue) {
		List<sObject> returnObjectList;
        try {
            String query = 'SELECT ID, NAME from ' + JSON.deserialize(objectName, String.class) + ' WHERE NAME LIKE \'%' + JSON.deserialize(searchStringValue, String.class) + '%\'';
            returnObjectList = DataBase.query(query);
        } catch(Exception e) {
            System.assert(false, e);
            //return null;
        }
        return returnObjectList;
    }
}