@istest
public class Portal_RegisterControllerTest {
	static testmethod void testMethodRegister(){
		dataReady();
		Portal_RegisterController pr = new Portal_RegisterController();

		pr.uWrap.firstName = 'testtesttest';
		pr.uWrap.lastName = 'testtesttest';
		pr.uWrap.email = 'testDante1122@test.com';
		pr.uWrap.password = '443322334';
		pr.register();

		pr.uWrap.confirmPassword = '';
		pr.register();

		pr.uWrap.confirmPassword = '443322334';
		pr.register();

	}

	private static void dataReady(){
		Lead l=new Lead();
		l.Email='testDante1122@test.com';
		l.LastName='test';
		l.Company='test';
		insert l;

		Contact c=new Contact();
		c.LastName='c';
		c.Email='testDante@testDante.com';
		insert c;
	}
}