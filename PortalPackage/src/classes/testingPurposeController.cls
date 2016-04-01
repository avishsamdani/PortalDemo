public class testingPurposeController {
    
    @RemoteAction
    public static String populateMultiPickList()  {
        String str = '';
        Integer count = 0;
        Schema.DescribeFieldResult fieldResult = Schema.SObjectType.Contact.fields.Test_Multi__c;
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple) {
            if(count != ple.size()-1 ) {
                str = str + f.getValue() + ',' ;
            }
            else {
                str = str + f.getValue();
            }
            count++;
        } 
        system.debug(str);
        return str;
    }
    
}