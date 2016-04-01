public with sharing class CampusGenericLookUpController {
     
    private List<Schema.FieldSetMember> fieldSetMember;
    private String packageName = '';
    private final integer list_size=10; 
    private String query ='';
    private String whereCondition;
    private integer counter=0;  
    private String objectName;
    private integer total_size;
    private Map < String, Schema.SObjectType > GlobalDescribeMap = Schema.getGlobalDescribe();
    private Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(ObjectName);
    
    public Map<String, String> filterFieldsDisplayMap {get;set;}  
    public List<SearchRecordWrapper> searchRecordWrappers {get;set;}    
    public Integer pageNumber {get;set;}
    public String isErrorMessage {get;set;}
    
    public CampusGenericLookUpController(){           
        try{
          isErrorMessage = null;
            objectName =  ApexPages.currentPage().getParameters().get('objectname');
            GlobalDescribeMap = Schema.getGlobalDescribe();
        SObjectTypeObj = GlobalDescribeMap.get(ObjectName);
        if(SObjectTypeObj == null) {
         // throw new CampusPackageException('Invalid Object');
        }
            searchRecordWrappers = new List<SearchRecordWrapper>();
            pageNumber = 1;
            packageName = CampusUtility.getNameSpacePerfix();
            whereCondition = null;
            if(packageName  != '' && packageName  != null){
                packageName  =  packageName+'__' ;
            }
            total_size = Database.countQuery('select count() from '+objectName);
            String lookupFieldSet = 'Test';
            if(lookupFieldSet != null) {
              fieldSetMember = readFieldSet(lookupFieldSet,objectName);
            }
            filterFieldsDisplayMap = new Map<String, String>();
            filterFieldsDisplayMap.put('Name', 'Name');
      searchRecordWrappers.add(new SearchRecordWrapper('Name','Name','TEXT'));
            if(fieldSetMember != null) {
              for(Schema.FieldSetMember fsm: fieldSetMember){
                  if(fsm.getFieldPath().trim().toUpperCase() != 'NAME') {
                      filterFieldsDisplayMap.put(fsm.getFieldPath(), fsm.getLabel());
                      if(searchRecordWrappers.size() < 5){
                          if(String.valueOf(fsm.getType()).toUpperCase() != 'REFERENCE') {
                            SearchRecordWrapper searchRecord = new SearchRecordWrapper(fsm.getLabel(),fsm.getFieldPath(),String.valueOf(fsm.getType()));
                              searchRecordWrappers.add(searchRecord);
                              if(String.valueOf(fsm.getType()).toUpperCase() == CampusConstant.PICKLIST_FIELD_NAME.toUpperCase() || String.valueOf(fsm.getType()).toUpperCase() == CampusConstant.COMBOBOX_TYPE.toUpperCase()) {
                                searchRecord.options = CampusUtility.getPickListValuesWithFirstNone(CampusUtility.getFieldDescResult(packageName, objectName, fsm.getFieldPath(), SObjectTypeObj), true);
                              } else if(String.valueOf(fsm.getType()).toUpperCase() == CampusConstant.MULTIPICKLISTTYPE.toUpperCase()) {
                                searchRecord.inputTextList = new List<String>();
                                searchRecord.inputTextList.add('');
                                searchRecord.options = CampusUtility.getPickListValuesForMultiSelect(CampusUtility.getFieldDescResult(packageName, objectName, fsm.getFieldPath(), SObjectTypeObj), true);
                              }
                          }
                      }
                  }
              }
            }
        }catch(Exception e){
          if(e.getMessage() == 'Invalid Object') {
            isErrorMessage = 'Invalid Object. Object does not exists.';
          } else {
            isErrorMessage = 'There is no record to select.';
          }
        }  
    }
    
    private String createQuery(){
        query = 'SELECT ID,Name,';
        if(fieldSetMember != null) {
          for(Schema.FieldSetMember fsm: fieldSetMember){
              if(fsm.getFieldPath().trim().toUpperCase() != 'NAME') {
                  query += fsm.getFieldPath()+',';
              }                   
          }
        }
        query = query.subString(0,query.length()-1);
        query += ' FROM '+objectName;
        if(whereCondition != null){
            query += ' ' + whereCondition;
        }
        query += ' limit :list_size offset :counter';
        return query;
    }

    private List<Schema.FieldSetMember> readFieldSet(String fieldSetName, String ObjectName) {
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
        Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(packageName + fieldSetName);
        return fieldSetObj.getFields();
    }
    
    public List<Sobject> getRecords() {
        try {
            return Database.query(createQuery());
        }catch (QueryException e) {
            ApexPages.addMessages(e);   
            return null;
        }
    }       
      
    public PageReference Beginning() { //user clicked beginning
        counter = 0;
        return null;
    }
    
    public PageReference Previous() { //user clicked previous button
        counter -= list_size;
        return null;
    }
    
    public PageReference Next() { //user clicked next button
        counter += list_size;
        return null;
    }
    
    public PageReference End() { //user clicked end
        counter = total_size - math.mod(total_size, list_size);
        return null;
    }
    
    public Boolean getDisablePrevious() { 
        //this will disable the previous and beginning buttons
        if (counter>0) {
          return false; 
        } else {
          return true;
        }
    }
    
    public Boolean getDisableNext() { //this will disable the next and end buttons
        if (counter + list_size < total_size) {
          return false; 
        } else {
          return true;
        }
    }
    
    public Integer getTotal_size() {
        return total_size;
    }
    
    public Integer getPageNumber() {
        return counter/list_size + 1;
    }
    
    public Integer getTotalPages() {
        if (math.mod(total_size, list_size) > 0) {
            return total_size/list_size + 1;
        } else {
            return (total_size/list_size);
        }
    }
      
    public void go() {            
        counter = (list_size * (pageNumber-1));
    }
       
    public void searchRecords(){
      try {
          whereCondition = '';
          for(SearchRecordWrapper s : searchRecordWrappers){
            if(s.fieldType.toUpperCase() == CampusConstant.MULTIPICKLISTTYPE.toUpperCase()) {
              String tempStr = '';
              if(s.inputTextList != null) {
                for(String value : s.inputTextList) {
                  if(value != null && value != '') {
                    tempStr += ' '+s.fieldApiName+' = '+ '\''+ value +'\'' + ' OR ';
                  } else {
                    tempStr = '';
                    break;
                  }
                }
              }
              if(tempStr != '') {
                tempStr = tempStr.trim().subString(0,tempStr.length()-4);
                whereCondition += '(' + tempStr + ') AND ';
              }
          } else {
              if(s.fieldValue != null && s.fieldValue != ''){
                    whereCondition += ' '+s.fieldApiName+' like '+'\'%'+s.fieldValue.trim() +'%\''+' AND ';
                }
            }
          }
          if(whereCondition != '') {
              whereCondition = 'where ' + whereCondition;
            whereCondition = whereCondition.trim().subString(0,whereCondition.length()-5);
          }
          total_size = Database.countQuery('select count() from '+objectName+' '+whereCondition);
          counter = 0;
      } catch (QueryException e) {
            ApexPages.addMessages(e);   
        }                     
    }
    
    public void clearSearch(){
      try {
          whereCondition = '';
          for(SearchRecordWrapper s : searchRecordWrappers){
              s.fieldValue = '';
              if(s.fieldType.toUpperCase() == CampusConstant.MULTIPICKLISTTYPE.toUpperCase()) {
                s.inputTextList = new List<String>();
              s.inputTextList.add('');
              }        
          }
          total_size = Database.countQuery('select count() from '+objectName+' '+whereCondition);
          counter = 0;                        
      } catch (QueryException e) {
            ApexPages.addMessages(e);   
        }
    }
       
    public class SearchRecordWrapper{
        public String fieldLabel {get;set;}
        public String fieldValue {get;set;}
        public String fieldApiName {get;set;}
        public String fieldType {get;set;}
        public list < string > inputTextList {
            get;
            set;
        }
        // store picklist value of field if type if picklist
        public list < SelectOption > options {
            get;
            private set;
        }
        // Constructor
        public SearchRecordWrapper(String fieldLabel,String fieldApiName,String fieldType){
            this.fieldLabel = fieldLabel;
            this.fieldApiName = fieldApiName;
            this.fieldType = fieldType;
        }
    }
       
}