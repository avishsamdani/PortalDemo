/* **************************************************************************************
* ? 2013 Enrollment Rx, LLC. All Rights Reserved
*
* Public class: CampusConstant
  Stores all hard coded values 
*  
* Created by Arpit Sharma, Enrollmentrx: Feb/10/2015
*

*****************************************************************************************/
public with sharing class CampusConstant {
   
  public static final string SYSTEM_ERROR = '[Campus System Error] : ';
  public static final string LOG_INFO = '[Campus Package Info] : ';
  public static final string LOG_ERROR = '[Campus Package Error] : ';
  public static final string LOG_WARNING = '[Campus Package Warning] : ';
  
  public static final string HTML_BREAK = '</br>';
  
  public static final string BLANK  ='';
  
  public static final string EMPTY_STRING = '';
  public static final string SELECT_CLAUSE = ' SELECT ';
  public static final string FROM_CLAUSE = ' FROM ';
  public static final string WHERE_CLAUSE = ' WHERE ';
  public static final String NONE= '--None--';
  public static final String CONTACT_API_NAME = 'contact';
  public static final String CAMPAGIN_API_NAME = 'campaignmember';
    public static final String BOOLEAN_TYPE = 'BOOLEAN';
    public static final String DATETIME_TYPE = 'DATETIME';
    public static final String DATE_TYPE = 'DATE';
    public static final String STRING_TYPE = 'STRING';
    public static final String EMAIL_TYPE = 'EMAIL';
    public static final String PHONE_TYPE = 'PHONE';
    public static final String MULTIPICKLISTTYPE = 'MULTIPICKLIST';
    public static final String TEXTAREA_TYPE = 'TEXTAREA';
    public static final String DOUBLE_TYPE = 'DOUBLE';
    public static final String CURRENCY_TYPE = 'CURRENCY';
    public static final String REFERENCE_TYPE = 'REFERENCE';
    public static final String PICKLIST_TYPE = 'PICKLIST';
    public static final String COMBOBOX_TYPE = 'COMBOBOX';
    public static final String INTEGER_TYPE = 'INTEGER';
    public static final String URL_TYPE = 'URL';
    
    public static final String EVENT_ID ='eventId';
    public static final String CM ='cm';
    public static final String DUPLICATE = 'DUPLICATE_VALUE';
    public static final String EMAIL_ALREADY_MESSAGE ='Your email address has already been used to register for this event. If you believe this was in error, please contact us at the email address above.';  
    public static final String ERROR_SAVE = 'Error Saving Registration: ';
    public static final String CURRENCY_FIELD_NAME = 'Currency';    
    public static final String DATE_FIELD_NAME = 'Date';
    public static final String STRING_FIELD_NAME = 'String';
    public static final String PHONE_FIELD_NAME = 'Phone';
    public static final String MULTIPICKLIST_FIELD_NAME = 'Multipicklist';
    public static final String TEXTAREA_FIELD_NAME = 'TextArea';
    public static final String INTEGER_FIELD_NAME = 'Integer';
    public static final String DECIMAL_FIELD_NAME = 'Decimal';
    public static final String REFERENCE_FIELD_NAME = 'Reference';
    public static final String PICKLIST_FIELD_NAME = 'Picklist';
    public static final String CHECKBOX_FIELD_NAME = 'Checkbox';
    public static final String EMAIL_FIELD_NAME = 'Email';
    public static final String URL_FIELD_NAME = 'Url';
    public static final String FALSE_VAR = 'false';
    public static final String SEVERITY_INFO = 'alert-info';
    public static final String SEVERITY_ERROR = 'alert-error';
    public static final String SEVERITY_FATAL = 'alert-danger';
    
    public static final String GUEST_PANEL = 'Guest Panel';
    public static final String EMAIL_REGEX = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$';
    public static final String VALIDATE_MESSAGE = 'WARNING: All fields marked as Required must be completed.';
    public static final String GUEST_VALIDATE_MESSAGE = 'WARNING: All fields for the Guest marked as Required must be completed.';
    public static final String EVENT_ID_NOT_FOUND_MESSAGE = 'The Event ID provided cannot be located.';
    public static final String UNEQUAL_EMAIL_MESSAGE = 'Please verify that you have entered your email address correctly.';
    public static final String INVALID_EMAIL = 'Please verify that you have entered your email address correctly.';
    public static final String INVALID_URL = 'Invalid URL';
    public static final String BRINGING_GUEST = 'Yes';
    public static final String BRINGING_GUEST_NO = 'No';
    public static final String CLOSE_BRACKET = ')';
    public static final String TERMINATION = ';';
    public static final String STATUS = 'Sent';
    public static final String REG_STATUS = 'Registered';
    
    public static final String ATTEND_TYPE = 'Guest';
    public static final String PRIMARY_ATTEND_TYPE = 'Primary';
    public static final String CONTACT_OBJ_CODE = '003';
    public static final String ALREADY_REGISTERED = 'WARNING: This attendee has already completed a successful registration.';
    public static final String URL_CONTACT_VAR = 'c';
    
    public static final String DEFAULTS ='DEFAULTS';
    public static final String THANKS_SETTING ='Thank you for registering';   
    public static final String CLOSE_SETTING ='This event is closed for further registrations';  
    public static final String EMAIL_SETTING ='nobody@enrollmentrx.com'; 
    public static final String TEMPLATE_SETTING ='ERx_SampleTemplate';   
    public static final String FULL_SETTING ='This event is full and cannot accept further registrations';
    public static final String REG_SETTING ='Event Registration';
    public static final String VALID_SETTING ='Please choose a valid date from calendar.';
    public static final String UNEQUAL_GUEST_EMAIL_MESSAGE =   'Please verify that you have entered your guest\'s email correctly.';
    public static final String ERROR_SAVE_CONTACT = 'Error Saving Contact Information: ';
    public static final String ERROR_SAVE_CAMPAGIN = 'Error Saving Lead Information:';
    public static final String ERROR_SAVE_GUEST ='Error Saving Guest Registration:';
  
    public static final String GEORGIA = 'Georgia';
    public static final String PALATINO = 'Palatino Linotype';    
    public static final String ANTIQUA = 'Book Antiqua';  
    public static final String TIMES = 'Times New Roman';   
    public static final String ARIAL = 'Arial';  
    public static final String HELVETICA = 'Helvetica';
    public static final String IMPACT = 'Impact';     
    public static final String ARIAL_BLACK = 'Arial Black';
    public static final String LUCIDASANS = 'Lucida Sans Unicode';    
    public static final String TAHOMA = 'Tahoma';  
    public static final String VERDANA = 'Verdana';   
    public static final String LUCIDACONSOLE = 'Lucida Console';  
    public static final String LUCIDA = 'Lucida';
    
    public static final String SECTION_NAME =  'Name';
    public static final String SECTION_COLUMN =  'SectionColumn__c';
    public static final String SECTION_DESCRIPTION =  'Section_Descriptions__c';
    public static final String SECTION_ORDER =  'Section_Order__c';
    public static final String SECTION_STYLE =  'Section_Style__c';
    public static final String GUEST_PANEL_ALREADY = 'Guest panel is already exist.';
    public static final String SECTION_SUCCESS = 'Section successfully inserted';
    public static final String SECTION_SHOW = 'Is_Show__c'; 
    public static final String SECTION_NAME_FIELD = 'Name Field is required.';
    public static final String VALUE_INTEGER_MESSAGE = 'Section Order should be In Integer'; 
    public static final String VALUE_INTEGER_GREATER_THEN_ZERO = 'Section Order should be greater then Zero';
    public static final String SECTION_ALREADY_EXIST = 'A section with that name has already been created for this event.'; 
    public static final String LAST_NAME_API = 'LastName';
    public static final String IS_CUSTOM = 'isCustom';
    
    public static final String FIELD_LABEL = 'Name';
    public static final String FIELD_OBJECT = 'Object_Name__c';
    public static final String FIELD_FIELD_NAME = 'Field_API_Name__c';  
    public static final String FIELD_REQUIRED = 'Is_Required__c';
    public static final String FIELD_RECORDTYPE = 'Record_Type__c';
    public static final String FIELD_EVENT_SUBJECT = 'Event_Subject__c';
    public static final String FIELD_END_DATE = 'End_Date__c';
    public static final String FIELD_START_DATE = 'Start_Date__c';
    public static final String FIELD_CALENDER_USER = 'Calendar_User__c';
    public static final String FIELD_DESCRIBE = 'Field_Descriptions__c';
    public static final String FIELD_INSERT_MESSAGE = 'Successfully inserted';
    public static final String NOT_REFERENCE = 'Not REFERENCE';
    public static final String NAME_FIELD = 'Label is Required.';
    public static final String RECORD_ERROR = 'Reference Field required record type.';
    public static final String DATE_ERROR = 'Please enter an Event Subject and Calendar User, or Start Date and End Date.';
    public static final String DATE_LESS_THEN_ERROR = 'End Date cannot be less than Start Date.';
    public static final String DATE_LESS_THEN_TODAY_ERROR = 'date field is not less then today.';
    public static final String FIELD_API_ALREADY =  'Field API name already exist.';
    public static final String SECTION_KEY = 'Section';
    public static final String FIELD_KEY = 'fieldSection';
    public static final String CAMPAGIN_ID = 'cmpId';
    public static final String dateTimeFormet = 'MM/dd/yyyy HH:mm:ss';
    public static final String PROTOCOL = 'https://';
    public static final String SUBDOMAIN = '.na16.force.com/';
    public static final String QUESTION = '?';
    public static final String EQUAL = '=';
    public static final String DASH = '-';
    public static final String EVENT_CLASS= 'event-class';
    public static final String FORWORD_SLASH = '/';
    public static final String REGISTRATION_PAGE_NAME = 'CampusRegistration';
    public static final String APEX = 'apex';
    
    public static final String ZERO = '0'; 
    public static final String FIRST = '1';
    public static final String SECOND = '2';
    public static final String THIRD = '3';
    public static final String FOURTH = '4';
    public static final String FIFTH = '5';
    
    public static final String ALL_DAY_TIME = '0:00 AM - 11:59 PM';
    public static final String ALL_DAY_TIME_SET = '00:00 - 23:59'; 
    public static final String DAY_OF_MONTH = 'day of the Month';
    public static final STring START_DATE_BLANK = 'Start Date is not Blank.';
    public static final STring END_DATE_BLANK = ' Please enter the End date for this recurring event.';
    public static final String START_DATE_NOT_LESS = 'Start Date cannot be less then today.';
    public static final String END_DATE_NOT_LESS = 'End date cannot be less than today.';
    public static final String RECURRENCE_DATE = 'Recurrence End date cannot be less than the Start Date of the event.';
    public static final String RECURRENCE_NUMBER = 'Recurrence number cannot be less than one.';
    public static final String SELECT_AT_LEAST_ONE = 'Please Select At least on day.';
    public static final String START_TIME = 'Start Time and End Time cannot be left Blank.';
    public static final String OVERLAP = 'Overlapping of Event is not Allowed.';
    public static final String EVENT_DURATION = 'Recurrence End date cannot be less than event End Date.';
    public static final String EEEE ='EEEE';
    public static final String DATE_LESS_THAN = 'Start Date cannot be less then today.';
    
    public static final String MON = 'Monday';
    public static final String WED = 'Wednesday';
    public static final String FRI = 'Friday';
    
    public static final String SAT = 'Saturday';
    public static final String SUN = 'Sunday';
    public static final String TUE = 'Tuesday'; 
    public static final String THU = 'Thursday';  
    
    public static final String NOT_EDIT = 'Event is not editable because event is completed.';
    public static final String ALL_DAY_WEEK = 'All day of this week is gone.';
    public static final String NOT_MORE_THEN = 'For yearly recurring  is not allowed for more then 1 year.';
    public static final String TIME_SIGN = ':';
    public static final String TIME_ERROR = 'Time not equal in case of 1 day.';
    public static final String RSVP_DATE = 'RSVP date cannot be smaller than End Date.';
    public static final String QR_CODE_URL = 'https://chart.googleapis.com/chart?chs=150x150&cht=qr&chl=';
    public static final String GET = 'GET';
    public static final String HASH = '##';
    public static final String Contact_NAME = 'Contact';
    public static final String Lead_NAME = 'Lead';
    public static final String IS_SEND_EMAIL = 'Simple Email';
    public static final String IS_SEND_QR = 'Email With QR Code';
    public static final String CAM = 'Campaign';
    public static final String CAM_FIELD_SET = 'CampusEmailTemplateFieldSet';
    public static final String QUERY_STRING =',Name,Email_Setting__c,(SELECT Attendee_QR_Code__c,Status,Contact.FirstName,Contact.LastName,Lead.FirstName,Lead.LastName,Lead.Name  FROM CampaignMembers WHERE ID=';
    public static final String SUCESS = 'Successfully Saved';
    public static final String RSVP_DATE_ERROR = 'RSVP DATE should be less than or equal to the start date of the event.';
    public static final String DOUBLEDASH  = '   ';
    public static final String CAM_RECORD = 'Campus Campaign';
    public static final String CAM_MEM_RECORD = 'Campus Campaign Member';
    public static final String NAME = 'Name';
    public static final String AM = 'AM';
    public static final String PM = 'PM';
    public static final String VALID_RECCURENCE = 'Please enter a valid number of occurrences.';
    public static final String VALID_INTEGER = 'Invalid integer';
    public static final String CUSTOM_LABEL  = 'customLabel';
    public static final String COMMA = ',';
    public static final String CAMPUS_CAM_PAGE = '/apex/CampusCampaign';
    public static final String STD_NEW_PAGE = '/701/e';
    public static final String STD_DETAIL_PAGE = '/701/o';
    public static final String STD_CAM_MEM = 'Standard Campaign Member';
    public static final String STD_CAM = 'Simple Campaign';
    public static final String CAMPAGIN_FIELD_SET = 'CampusCampaginFieldSet';
    
}