global with sharing class AnkitSDLSDemoController {
	@RemoteAction
	global static List<Contact> getPlayersList(String name){
		System.debug('Select id,name from Contact  where Name  like \'' + '%' +  name + '%\'' + 'limit 25');
		List<Contact> allplayers = Database.query('Select id,name from Contact  where Name  like \'' + '%' +  name + '%\'' + 'limit 2000');
		//system.assert(false, allplayers);
		return allplayers;
		
	}
}