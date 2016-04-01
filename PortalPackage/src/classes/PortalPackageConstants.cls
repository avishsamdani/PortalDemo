public with sharing class PortalPackageConstants {
	public final static string PAGE_UPSERTION_DELETION_ERROR_MESSAGE = 'Page can not be inserted or deleted from the live Env';
	public final static string SECTION_UPSERTION_DELETION_ERROR_MESSAGE = 'Section can not be inserted or deleted from the live Env';
	public final static string TEMPLATE_UPSERTION_DELETION_ERROR_MESSAGE = 'Template can not be inserted or deleted from the live Env';
	public final static string ENV_DELETION_ERROR_MESSAGE = 'You can not delete live Env';
	
	
	public final static String EQUALS = ' = ';
	
	// Constants By Avish.
	public static final List<String> OPERATOR_LIST = new List<String>{'=', '!=', '>', '>=', '<', '<=', 'Contains'}; // Operators that are used in Condition.
	public static final List<String> RENDERED_OPERATOR_LIST = new List<String>{'=', '!=', '>', '>=', '<', '<='};
	public static final String INVALID_PAGE_ID_ERROR_MESSAGE = 'Invalid Page Id.'; // Invalid Page Id Error Message.
	public static final String INVALID_PAGE_ERROR_MESSAGE = 'Invalid Page.'; // Invalid Page Error Message.
	public static final String SOME_THING_WENT_WRONG_ERROR_MESSAGE = 'Some Thing Went Wrong. Please Try After Some Time.'; // Exception Message while saving the data.
	
	// Field instruction position dropdown values.
	public static final List<String> FIELD_INSTRUCTION_POSITIONS = new List<String>{'Above Field', 'Above Label', 'Below Field', 'Below Label'};
	
	public static final String SECTION_MODEL = 'SECTIONMODEL'; //model type of section
	public static final String FIELD_MODEL = 'FIELDMODEL'; 
	
	// Upload source dropdown values.
	public static final String GLOBAL_VARIABLE = 'Global Variable';
	public static final String MODEL = 'Model';
	public static final String PARAM = 'Param';
	public static final String STATIC_CONS = 'Static';
	
	public static final List<String> UPLOAD_SOURCE_LIST = new List<String>{MODEL, PARAM, STATIC_CONS};
	
	public static final List<String> CRITERIA_CONDITION_SOURCE_LIST = new List<String>{MODEL, PARAM, STATIC_CONS, GLOBAL_VARIABLE};
	
	// File Size Data Units Constants
	//public static final Map<String, Long> FILE_SIZE_DATA_LIMITS = new Map<String, Long>{'1MB'=> (1*1024*1024), '2MB'=> (2*1024*1024), '3MB'=> (3*1024*1024), '4MB'=> (4*1024*1024), '5MB'=> (5*1024*1024)};
	// Note: Creating Map in Reverse order due to known issue of JSON.serialize with Map for Reference https://success.salesforce.com/issues_view?id=a1p300000008Z1fAAE 
	public static final Map<String, Long> FILE_SIZE_DATA_LIMITS = new Map<String, Long>{'5MB'=> (5*1024*1024), '4MB'=> (4*1024*1024), '3MB'=> (3*1024*1024), '2MB'=> (2*1024*1024), '1MB'=> (1*1024*1024)};
	
	// File Supported Types in Upload Constants
	public static final List<String> UPLOAD_SUPPORTED_FILES = new List<String>{'Pdf', 'Doc', 'Jpg', 'Gif', 'Png', 'Txt'};
	
	// Field Type (Change Reference Field Type)
	public static final List<String> REFERENCE_FIELD_TYPE = new List<String>{'Reference', 'Type Ahead', 'Picklist'};
	
	public static final String RICH_TEXT_AREA = 'RICHTEXT';
	
	public static final List<String> REQUIRED_SYMBOL_LIST = new List<String>{'*', '|'};
	
	/*
		Added by arpit 2/25/2016
	*/
	//operator used for rendering condition	
	public static final String EQUALS_TO = 'equals';
	public static final String NOT_EQUALS_TO = 'not equals to';
	public static final String CONTAINS = 'contains';
	public static final String DOES_NOT_CONTAINS = 'does not contains';
	public static final String STARTS_WITH = 'starts with';
	public static final String ENDS_WITH = 'ends with';
	public static final String INCLUDES = 'includes'; 
	public static final String EXCLUDES = 'excludes'; 
	public static final String LESS_THAN = 'less than';
	public static final String GREATER_THAN = 'greater than';
	public static final String LESS_THAN_EQUALS = 'less than equals';
	public static final String GREATER_THAN_EQUALS = 'greater than equals';
	
	public static final String TYPE_AHEAD_FLD = 'TYPE AHEAD';
	public static final String LOOKUP_FLD = 'LOOKUP';
	public static final String IDFIELD = 'ID';
	public static final String PICKLISTFLD = 'PICKLIST';
	public static final String DATEFLD = 'DATE';
	public static final String DATETIMEFLD = 'DATETIME';
	public static final String REFERENCEFLD = 'REFERENCE';
	public static final String IDFLD = 'ID';
	public static final String TEXTFLD = 'STRING';
	public static final String TEXTAREAFLD = 'TEXTAREA';
	public static final String DOUBLEFLD = 'DOUBLE';
	public static final String NUMBERFLD = 'NUMBER';
	public static final String CURRENCYFLD = 'CURRENCY';
	public static final String CHECKBOXFLD = 'BOOLEAN'; 
	public static final String EMAILFLD = 'EMAIL'; 
	public static final String MULTIPICKLISTFLD = 'MULTIPICKLIST'; 
	public static final String PERCENTFLD = 'PERCENT'; 
	public static final String TIMEFLD = 'TIME'; 
	public static final String URLFLD = 'URL'; 
	public static final String PHONEFLD = 'PHONE';
	public static final String ENCRYPTEDSTRINGFLD = 'ENCRYPTEDSTRING';
	public static final String UPLOADFLD = 'UPLOAD';
	
	public static final Map<String, List<String>> TYPE_OPERATOR_LIST_MAP = new Map<String, List<String>> {IDFIELD => new List<String>{EQUALS_TO, NOT_EQUALS_TO}, TEXTFLD => new List<String>{EQUALS_TO, NOT_EQUALS_TO, CONTAINS, DOES_NOT_CONTAINS, STARTS_WITH, ENDS_WITH}, PICKLISTFLD => new List<String>{EQUALS_TO, NOT_EQUALS_TO, CONTAINS, DOES_NOT_CONTAINS, STARTS_WITH, ENDS_WITH}, MULTIPICKLISTFLD => new List<String>{INCLUDES, EXCLUDES}, DATEFLD => new List<String>{EQUALS_TO, NOT_EQUALS_TO, DOES_NOT_CONTAINS, LESS_THAN, GREATER_THAN, LESS_THAN_EQUALS, GREATER_THAN_EQUALS}, DATETIMEFLD => new List<String>{EQUALS_TO, NOT_EQUALS_TO, CONTAINS, LESS_THAN, GREATER_THAN, LESS_THAN_EQUALS,GREATER_THAN_EQUALS}, CHECKBOXFLD => new List<String>{EQUALS_TO, NOT_EQUALS_TO}, REFERENCEFLD => new List<String>{EQUALS_TO, NOT_EQUALS_TO, STARTS_WITH}, NUMBERFLD => new List<String>{EQUALS_TO, NOT_EQUALS_TO, CONTAINS, LESS_THAN, GREATER_THAN, LESS_THAN_EQUALS,GREATER_THAN_EQUALS}, EMAILFLD => new List<String>{EQUALS_TO, NOT_EQUALS_TO, CONTAINS, DOES_NOT_CONTAINS, STARTS_WITH, ENDS_WITH}, PHONEFLD => new List<String>{EQUALS_TO, NOT_EQUALS_TO,CONTAINS, DOES_NOT_CONTAINS, STARTS_WITH, ENDS_WITH}, DOUBLEFLD => new List<String>{EQUALS_TO, NOT_EQUALS_TO, LESS_THAN, GREATER_THAN, LESS_THAN_EQUALS, GREATER_THAN_EQUALS}, CURRENCYFLD => new List<String>{EQUALS_TO, NOT_EQUALS_TO, LESS_THAN, GREATER_THAN, LESS_THAN_EQUALS, GREATER_THAN_EQUALS}, URLFLD => new List<String>{EQUALS_TO, NOT_EQUALS_TO, CONTAINS, DOES_NOT_CONTAINS, STARTS_WITH, ENDS_WITH}, ENCRYPTEDSTRINGFLD => new List<String>{EQUALS_TO, NOT_EQUALS_TO, CONTAINS, DOES_NOT_CONTAINS, STARTS_WITH, ENDS_WITH}, PERCENTFLD => new List<String>{EQUALS_TO, NOT_EQUALS_TO, LESS_THAN, GREATER_THAN, LESS_THAN_EQUALS,GREATER_THAN_EQUALS}};
	public static final Set<String> STRING_TYPE_FIELDS = new Set<String>{PortalPackageConstants.PICKLISTFLD, PortalPackageConstants.REFERENCEFLD, PortalPackageConstants.IDFLD, PortalPackageConstants.TEXTFLD, PortalPackageConstants.TEXTAREAFLD, PortalPackageConstants.EMAILFLD, PortalPackageConstants.URLFLD, PortalPackageConstants.PHONEFLD, PortalPackageConstants.ENCRYPTEDSTRINGFLD};
	public static final Set<String> NUMBER_TYPE_FIELDS = new Set<String>{PortalPackageConstants.DATEFLD, PortalPackageConstants.DATETIMEFLD, PortalPackageConstants.DOUBLEFLD, PortalPackageConstants.NUMBERFLD, PortalPackageConstants.CURRENCYFLD, PortalPackageConstants.EMAILFLD, PortalPackageConstants.PERCENTFLD, PortalPackageConstants.TIMEFLD};
	public static final Set<String> NUMBER_OPERATORS = new Set<String>{PortalPackageConstants.EQUALS_TO, PortalPackageConstants.NOT_EQUALS_TO, PortalPackageConstants.LESS_THAN, PortalPackageConstants.GREATER_THAN, PortalPackageConstants.LESS_THAN_EQUALS, PortalPackageConstants.GREATER_THAN_EQUALS};
	public static final Map<String, String> NUMBER_OPERATOR_MAP = new Map<String, String>{PortalPackageConstants.EQUALS_TO => ' = ', PortalPackageConstants.NOT_EQUALS_TO => ' != ', PortalPackageConstants.LESS_THAN => ' < ', PortalPackageConstants.GREATER_THAN => ' > ', PortalPackageConstants.LESS_THAN_EQUALS => ' <= ',PortalPackageConstants.GREATER_THAN_EQUALS => ' >= '};	
	//public static final Set<String> STRING_OPERATORS = new Set<String>{PortalPackageConstants.CONTAINS, PortalPackageConstants.DOES_NOT_CONTAINS, PortalPackageConstants.STARTS_WITH, PortalPackageConstants.ENDS_WITH};
	public static final String LIKE_OPERATOR = ' LIKE ';
	public static final string NOT_OPERATOR = ' NOT ';
	public static final string AND_OPERATOR = ' AND ';
	
	public static final String CURRENTUSERID = 'CurrentUserId';	
	public static final String CURRENTCONTACTID = 'CurrentContactId';	
	public static final String CURRENTPROFILEID = 'CurrentProfileId';	
	public static final String CURRENTCOMMUNITYID = 'CurrentCommunityId';
	public static final String CONTACTOBJ = 'Contact';
	public static final String USEROBJ = 'User';
	public static final String PROFILEOBJ = 'Profile';
	public static final String NETWORKOBJ = 'Network';	
	public static final List<String> GLOBAL_VAR = new List<String>{CURRENTUSERID, CURRENTCONTACTID, CURRENTPROFILEID, CURRENTCOMMUNITYID};
	public static final Map<String, String> GLOBAL_VAR_MAP = new Map<String, String>{CURRENTUSERID => USEROBJ, CURRENTCONTACTID => CONTACTOBJ, CURRENTPROFILEID => PROFILEOBJ, CURRENTCOMMUNITYID => NETWORKOBJ};
	
}