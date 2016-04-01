public with sharing class PortalAcacdemicHistoryController{
    private Map<String, List<sObject>> mapOfSobjectList = null;
    private String fieldsToFetchJSON {get;set;}
    private List<WrapperModel> wrapperModelList;
    private List<SectionModelWrapper> sectionmodelWrap;
    public String modelsJSON {get;set;}
    public String jsonData {get;set;}
    
    public PortalAcacdemicHistoryController(PageBuildDirector ctrl){
    	initialize();
    }
    
    public PortalAcacdemicHistoryController() {
       initialize();
    }
    
    private void initialize(){
    	try{   
        mapOfSobjectList = new Map<String, List<sObject>>();        
        
        jsonData = '[{"isRepeat":true, "buttonLabel":"Add Another", "deleteButtonLabel":"Remove", "title":"Contact Details", "modelName":"contactDetails", "noOfcolumn":2, "field":[{"required":true, "isBlank":false, "type":"text", "label":"Email", "APIName":"Email", "rendered": "true"}, {"isBlank":true},  {"required":true, "isBlank":false, "type":"text", "label":"Last Name", "APIName":"LastName", "rendered": "true"}, {"required":true, "isBlank":false, "type":"text", "label":"First Name", "APIName":"FirstName", "rendered": "true"}]}]';
        fieldsToFetchJSON = '[{"modelName":"contactDetails", "objectName":"Contact", "condition": "Account.Name like \'%Avish%\'", "field":["FirstName", "LastName", "Email"]}]';
          
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
        //System.assert(false, sqlString);
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