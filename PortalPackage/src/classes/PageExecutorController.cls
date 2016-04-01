public with sharing class PageExecutorController {
    
    public PageExecutorController(PageBuildDirector ctrl){
    	initialize();
    }
    
    public PageExecutorController() { 
       initialize();
    }
    
    private void initialize(){
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
        }
        return returnObjectList;
    }
}