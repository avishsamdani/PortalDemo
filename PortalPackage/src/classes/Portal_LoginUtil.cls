public with sharing class Portal_LoginUtil {
	public Portal_LoginUtil() {
		
	}

	public static PageReference addErrorMessage(string info){
		ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, info);
        ApexPages.addMessage(msg);
		return null;
	}

    // -----------------------------------------------------------------------------------
    // Utility Method: getPickListValues()
    // - Returns a List<SelectOption> for a given picklist field
    // -----------------------------------------------------------------------------------
    public static List<SelectOption> getPickListValues(Schema.Describefieldresult fldDesc, boolean blankFirstValue) {
        List<SelectOption> rtnValue = new List<SelectOption>();
        if (blankFirstValue) rtnValue.add(new SelectOption('', '-- Please Select --'));
        try {
            for (Schema.Picklistentry p : fldDesc.getPicklistValues()) {
                if (p.isActive()) rtnValue.add(new SelectOption(p.getValue(), p.getLabel()));
            }
        } catch (exception ex) { }
        return rtnValue;
    }

}