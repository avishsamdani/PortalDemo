public with sharing class ApplicantPortalController {
	public String networkName {get;set;}
	
	public ApplicantPortalController() {
		List<Network> networkList = [Select Id, Name from Network where id =: Network.getNetworkId()];		
		if(networkList.size() > 0) {
			networkName = networkList[0].Name;
		}
	} 
}