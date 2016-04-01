global class ngForceController {
    @remoteAction
    public static String describe(String objtype) {
        // Just enough to make the sample app work!
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(objtype);
        if (targetType == null) {
            return '[{"message":"The requested resource does not exist","errorCode":"NOT_FOUND"}]';
        }

        Schema.DescribeSObjectResult sobjResult = targetType.getDescribe();

        Map<String, Schema.SObjectField> fieldMap = sobjResult.fields.getMap();

        List<Object> fields = new List<Object>();
        for (String key : fieldMap.keySet()) {
            Schema.DescribeFieldResult descField = fieldMap.get(key).getDescribe();
            Map<String, Object> field = new Map<String, Object>();

            field.put('type', descField.getType().name().toLowerCase());
            field.put('name', descField.getName());
            field.put('label', descField.getLabel());
            field.put('picklistValues', descField.getPicklistValues());
            field.put('controllerName', String.valueOf(descField.getController()));
            List<String> references = new List<String>();
            for (Schema.sObjectType t : descField.getReferenceTo()) {
                references.add(t.getDescribe().getName());
            }
            if (!references.isEmpty()) {
                field.put('referenceTo', references);
            }

            fields.add(field);
        }

        Map<String, Object> result = new Map<String, Object>();
        result.put('fields', fields);

        return JSON.serialize(result);
    }

    @remoteAction
    public static String sObjectKlone(String iId) {
        Id id = (id) iId;
        sObjectType type = id.getSObjectType();
        Schema.DescribeSObjectResult dr = type.getDescribe();
        map<String, Schema.SObjectField> fieldMap = dr.fields.getMap();
        String qs = 'SELECT Id';
        Set<string> querySet = new Set<string>();
        querySet.addAll(fieldMap.keySet());
        querySet.remove('id');
        for (String f : querySet) {
            qs += ', ' + f;
        }
        qs += ' FROM ' + dr.getName() + ' WHERE id = \'' + id + '\' LIMIT 1';
        sObject toClone = Database.query(qs);
        sObject cloned = toClone.clone(false, true, false, false);
        system.debug('###dr.getName(): '+dr.getName());
        if(dr.getName()!='Contact')
        cloned.put('Name',toClone.get('Name') + ' - Copy');
        String results;
        try {
            upsert cloned;
            results = cloned.id;
        } catch (DMLException e) {
            system.debug(e);
            results = e.getMessage();
            system.debug('###e.getMessage(): '+e.getMessage());
        }
        return results;
    }
    
    @remoteAction
    public static String del(String objtype, String id) {
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(objtype);
        if (targetType == null) {
            return '[{"message":"The requested resource does not exist","errorCode":"NOT_FOUND"}]';
        }

        SObject obj = targetType.newSObject(id);

        try {
            delete obj;
        } catch (DMLException e) {
            return '[{"message":"' + e.getDmlMessage(0) + '","errorCode":"' + e.getDmlType(0).name() + '"}]';
        }

        return null;
    }

   @remoteAction
    public static String query(String objectName,String fields,String lookupFields, String queryCondition) {
        List<sObject> records;
        String query;
        
        query = 'SELECT ';
        
        if(!String.isBlank(fields)){
            query +=fields;
        }else{
            Map<String, Schema.SObjectField> objectFields = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
            // add the fields from the describe method and append them to the queryString one by one.
            for(String s : objectFields.keySet()) {
               query +=s + ',';
            }
        }
        // Manually add related object's fields that are needed.
        if(!String.isBlank(lookupFields))
        query += lookupFields;
        
        // Strip off the last comma if it exists.
        if (query.subString(query.Length()-1,query.Length()) == ','){
            query = query.subString(0,query.Length()-1);
        }
        
        // Add FROM statement
        query += ' FROM ' + objectName;
        
        // Add on a WHERE/ORDER/LIMIT statement as needed
        if (!String.isBlank(queryCondition)){
            query += ' WHERE ' + queryCondition; //firstName = \'test\''; add condition
        }

        try {
            records = Database.query(query);
        } catch (QueryException qe) {
            return '[{"message":"' + qe.getMessage() + '","errorCode":"INVALID_QUERY"}]';
        }

        Map<String, Object> result = new Map<String, Object>();
        result.put('records', records);
        result.put('totalSize', records.size());
        result.put('done', true);

        return JSON.serialize(result);
    }

    @remoteAction
    public static SObject upsertData(String objType,String strJSON) {
        SObject sObj=(SObject) JSON.deserialize(strJSON, Type.forName(objType));
        upsert sObj;
        return sObj;
    }
}