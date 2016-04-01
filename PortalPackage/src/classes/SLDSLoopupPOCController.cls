public class SLDSLoopupPOCController {
    
    
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