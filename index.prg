//	------------------------------------------------------------------------------
//	Title......: MVC_MERCURY
//	Description: Test MVC system for mod_harbour with Hrb Lib
//	Date.......: 09/07/2019
//	Last Upd...: 28/04/2020
//	------------------------------------------------------------------------------
//	{% LoadHRB( '/lib/mercury/mercury.hrb' ) %}	//	Loading system MVC Mercury
//	------------------------------------------------------------------------------

#include {% MercuryInclude( 'lib/mercury' ) %}

FUNCTION Main()

	local oApp
	
		DEFINE APP oApp TITLE 'My First App'

	//	Config Routes
		
		//	Basic pages...
		
			DEFINE ROUTE 'default' 	URL '/' CONTROLLER 'default.prg' 	METHOD 'GET' OF oApp
			DEFINE ROUTE 'help' 		URL '?' CONTROLLER 'help.prg' 		METHOD 'GET' OF oApp
			
		//	Test Controller and parameter received and oRoute:Get()
		
			DEFINE ROUTE 'vista' 	URL 'vista' 		VIEW 'vista.prg'	METHOD 'GET' OF oApp
			DEFINE ROUTE 'vista1' 	URL 'vista/(id)' 	VIEW 'vista.prg'	METHOD 'GET' OF oApp
			
		//	Test Router() function 
		
			DEFINE ROUTE 'router' 	URL 'router' 		VIEW 'router.prg'	METHOD 'GET' OF oApp
			
		//	Test controller via function/class
		/*
			oApp:oRoute:Map( 'GET'	, 'client'				, 'client'				, 'clientfunction.prg' )
			oApp:oRoute:Map( 'GET'	, 'client.edit'			, 'client/edit'			, 'edit()clientfunction.prg' )
			oApp:oRoute:Map( 'GET'	, 'client.edit2'		, 'client/edit2'		, 'edit@clientcontroller.prg' )
			*/
				
		//	Test TResponse	
		
			DEFINE ROUTE 'response.json' 		URL 'response/json' 	CONTROLLER 'json@response.prg'		OF oApp
			DEFINE ROUTE 'response.xml' 		URL 'response/xml' 		CONTROLLER 'xml@response.prg'		OF oApp
			DEFINE ROUTE 'response.html' 		URL 'response/html'		CONTROLLER 'html@response.prg'		OF oApp
			DEFINE ROUTE 'response.401' 		URL 'response/401'		CONTROLLER 'error401@response.prg'	OF oApp
			DEFINE ROUTE 'response.redirect'	URL 'response/redirect'	CONTROLLER 'redirect@response.prg'	OF oApp

			
		//	Test sub-folder Controller
		
			DEFINE ROUTE 'my_new'	URL 'new' 	CONTROLLER 'module_A/new.prg'		OF oApp
			
			
		//	Test TValidator	/ Test oRoute:Get()		
		
			DEFINE ROUTE 'validator'		URL 'validator' 	CONTROLLER 'test@validator.prg'	METHOD 'GET'	OF oApp
			DEFINE ROUTE 'validator.run'	URL 'validator/run' CONTROLLER 'run@validator.prg'	METHOD 'POST'	OF oApp

			
		//	Test Model/Validator	
		
			DEFINE ROUTE 'users'			URL 'users/(id)' 	CONTROLLER 'info@users.prg'		METHOD 'GET'	OF oApp
			
	
		//	Test JWT	
		
			DEFINE ROUTE 'jwt'				URL 'jwt' 			CONTROLLER 'create@test_jwt.prg'	METHOD 'GET'	OF oApp
			DEFINE ROUTE 'jwt.valid'		URL 'jwt/valid' 	CONTROLLER 'valid@test_jwt.prg'		METHOD 'POST'	OF oApp
	
	
		//	Test Login				
		
			DEFINE ROUTE 'app'				URL 'app' 				CONTROLLER 'default@app/myapp.prg'		METHOD 'GET'	OF oApp
			DEFINE ROUTE 'app.login'		URL 'app/login'			CONTROLLER 'login@app/access.prg'		METHOD 'GET'	OF oApp
			DEFINE ROUTE 'app.logout'		URL 'app/logout'		CONTROLLER 'logout@app/access.prg'		METHOD 'GET'	OF oApp
			DEFINE ROUTE 'app.autentica'	URL 'app/autentica'		CONTROLLER 'autentica@app/access.prg'	METHOD 'POST'	OF oApp
			DEFINE ROUTE 'app.principal'	URL 'app/principal'		CONTROLLER 'principal@app/myapp.prg'	METHOD 'GET'	OF oApp
			DEFINE ROUTE 'app.test1'		URL 'app/test1'			CONTROLLER 'test1@app/myapp.prg'		METHOD 'GET'	OF oApp
			DEFINE ROUTE 'app.test2'		URL 'app/test2'			CONTROLLER 'test2@app/myapp.prg'		METHOD 'GET'	OF oApp
			DEFINE ROUTE 'app.test3'		URL 'app/test3'			CONTROLLER 'test3@app/myapp.prg'		METHOD 'GET'	OF oApp

			
		//	Test Login - Bootstrap		
		
			DEFINE ROUTE 'boot'				URL 'boot' 				CONTROLLER 'default@boot/myapp.prg'		METHOD 'GET'	OF oApp
			DEFINE ROUTE 'boot.autentica'	URL 'boot/autentica' 	CONTROLLER 'autentica@boot/access.prg'	METHOD 'POST'	OF oApp
			DEFINE ROUTE 'boot.logout'		URL 'boot/logout' 		CONTROLLER 'logout@boot/access.prg'		METHOD 'GET'	OF oApp
			DEFINE ROUTE 'boot.principal'	URL 'boot/principal' 	CONTROLLER 'principal@boot/myapp.prg'	METHOD 'GET'	OF oApp
			DEFINE ROUTE 'boot.test1'		URL 'boot/test1' 		CONTROLLER 'test1@boot/myapp.prg'		METHOD 'GET'	OF oApp
			DEFINE ROUTE 'boot.test2'		URL 'boot/test2' 		CONTROLLER 'test2@boot/myapp.prg'		METHOD 'GET'	OF oApp
			DEFINE ROUTE 'boot.test3'		URL 'boot/test3' 		CONTROLLER 'test3@boot/myapp.prg'		METHOD 'GET'	OF oApp

			
		//	Test Paramaters	
		
			DEFINE ROUTE 'param'			URL 'param'		 		CONTROLLER 'test@param.prg'	OF oApp
			

		//	View Direct
		
			DEFINE ROUTE 'view'				URL 'view'		 		VIEW 'vista_default.view'	OF oApp
			
			
			
	//	Init Aplication
	
		INIT APP oApp
	

RETU NIL

exit procedure ppp


	
retu