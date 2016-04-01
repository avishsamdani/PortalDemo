public interface IPageBuilder {
	
	Boolean checkIsAuthorized();
	
	void getRawPageData();
	
	HtmlPage getFinalPage();
}