public class TP_Manage_SiteTemplateReviewController {
	public String templateHeader {get;set;}
	public String templateFooter {get;set;}
	public String templateName {get;set;}
	
	public String tmpId {get;set;}
	
	public SiteLoginTemplate__c curTmp {get;set;}
	
	public TP_Manage_SiteTemplateReviewController(){
		tmpId = ApexPages.currentPage().getParameters().get('tmpId');
		if(tmpId != null){
			curTmp = [SELECT Id,Name,SiteTemplateHeader__c,SiteTemplateFooter__c FROM SiteLoginTemplate__c WHERE Id=:tmpId];
			templateHeader = curTmp.SiteTemplateHeader__c;
			templateFooter = curTmp.SiteTemplateFooter__c;
		}
		else{
			templateHeader = 'Configure page Header';
			templateFooter = 'Configure page Footer';
		}
	}
	
	
}