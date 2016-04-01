@isTest
public class ngForceController_TEST {
	private static String tooLongAccName = 'LOTS OF ' +
	                                       'CHARACTERS XXXXXXXXXXXXXXXXXXXXXXXX' +
	                                       'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX' +
	                                       'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX' +
	                                       'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX' +
	                                       'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX' +
	                                       'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX' +
	                                       'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX' +
	                                       'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX' +
	                                       'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX' +
	                                       'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX' +
	                                       'XXXXXXXXXXXXXXXX';

	static private void assertError(String jsonResult, String expectedError, String method) {
		system.debug('##################' + jsonResult);
		List<Object> errorArray = (List<Object>)JSON.deserializeUntyped(jsonResult);

		System.assertNotEquals(null, errorArray,
		                       'error array missing from ' + method + ' result');
		System.assertNotEquals(0, errorArray.size(),
		                       'error array is empty in ' + method + ' result');

		Map<String, Object> error = (Map<String, Object>)errorArray[0];
		String errorCode = (String)error.get('errorCode');
		System.assertNotEquals(null, errorCode,
		                       'errorCode property missing from ' + method + ' result');
		System.assertEquals(expectedError, errorCode,
		                    'errorCode should be ' + expectedError + ' in ' + method + ' result');
	}

	static testMethod void testDescribe() {
		// Assume we have accounts
		String jsonResult = ngForceController.describe('Account');

		System.assertNotEquals(null, jsonResult,
		                       'ngForceController.describe returned null');

		Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(jsonResult);

		System.assertNotEquals(null, result.get('fields'),
		                       'fields property missing from ngForceController.describe result');

		// TODO - more assertions on describe results

		// Invalid object type
		// Hope there isn't a QXZXQZXZQXZQ object type!
		jsonResult = ngForceController.describe('QXZXQZXZQXZQ');
		assertError(jsonResult, 'NOT_FOUND', 'ngForceController.describe');
	}

	static private void assertRecord(Map<String, Object> record, String accName, String accNumber, String method) {
		Map<String, Object> attributes = (Map<String, Object>)record.get('attributes');
		System.assertNotEquals(null, attributes,
		                       'attributes property missing from ' + method + ' result');
		System.assertNotEquals(0, attributes.keySet().size(),
		                       'empty attributes object in ' + method + ' result');

		String type = (String)attributes.get('type');
		System.assertNotEquals(null, type,
		                       'type property missing from ' + method + ' result');
		System.assertEquals('Account', type,
		                    'Wrong type in ' + method + ' result');

		String url = (String)attributes.get('url');
		System.assertNotEquals(null, url,
		                       'url property missing from ' + method + ' result');

		Id id = (Id)record.get('Id');
		System.assertNotEquals(null, id,
		                       'Id property missing from ' + method + ' result');
		Account account = [SELECT Id, Name FROM Account WHERE Id = :id LIMIT 1];
		System.assertNotEquals(null, account,
		                       'Couldn\'t find account record identified by ' + method + ' result');
		System.assertEquals(accName, account.Name,
		                    'Account name doesn\'t match in ' + method + ' result');

		String name = (String)record.get('Name');
		System.assertNotEquals(null, name,
		                       'Name property missing from ' + method + ' result');
		System.assertEquals(accName, name,
		                    'Wrong account name in ' + method + ' result');

		String accountNumber = (String)record.get('AccountNumber');
		System.assertNotEquals(null, name,
		                       'AccountNumber property missing from ' + method + ' result');
		System.assertEquals(accNumber, accountNumber,
		                    'Wrong account number in ' + method + ' result');
	}


	static private void testDelete(Id id) {
		String jsonResult = ngForceController.del('QXZXQZXZQXZQ', id);
		assertError(jsonResult, 'NOT_FOUND', 'ngForceController.del');

		jsonResult = ngForceController.del('Account', id);
		system.debug('$$$$$$$$$$$$' + jsonResult);
		System.assertEquals(null, jsonResult,
		                    'Non-null result from ngForceController.del');
		List<Account> accounts = [SELECT Id, Name FROM Account WHERE Id = :id];
		System.assertEquals(0, accounts.size(),
		                    'Account record was not deleted by ngForceController.del');

		jsonResult = ngForceController.del('Account', id);
		assertError(jsonResult, 'ENTITY_IS_DELETED', 'ngForceController.del');
	}

	static testMethod void testCRUD() {
		Account acc=new Account();
		acc.Name='testDante';
		insert acc;
		testDelete(acc.id);

		Account acc1=new Account();
		acc1.Name='testDante123';
		acc1.accountNumber='testDante123';
		insert acc1;
		
		ngForceController.query('Account','','','Name=\'testDante123\'');
		ngForceController.query('Account','Name','CreatedById','Name=\'testDante123\'');
		
		
		Contact c=new Contact();
		c.LastName='testDante';
		insert c;
		ngForceController.sObjectKlone(c.Id);
		ngForceController.sObjectKlone(acc1.Id);
		
		String accJSON=String.escapeSingleQuotes(JSON.serialize(acc1));
		ngForceController.upsertData('Account',accJSON);
	}
}