//	------------------------------------------------------------------------------
//	Title......: MVC_MERCURY
//	Description: Test MVC system for mod_harbour from Hrb Lib
//	Date.......: 09/07/2019
//
//	{% AAdd( getList, hb_milliseconds()  ) %}	//	Ocupará el 1 elemento del array
//	{% LoadHRB( '/lib/core/core_lib.hrb' ) %}	//	Loading core
//	{% LoadHRB( '/lib/hmvc/tmvc_lib.hrb' ) %}	//	Loading system MVC Mercury
//	------------------------------------------------------------------------------



FUNCTION Main()

	LOCAL oApp 	:= App()

	//	Configuramos nuestra Aplicacion
	
		oApp:cTitle		:= 'My First App'

	//	Configuramos las Rutas
	
		//			     		Method	,  ID					, Mascara				, Controller 			
		//	Basic pages...
			oApp:oRoute:Map( 'GET'	, 'default'				, '/'					, 'default.prg' )
			oApp:oRoute:Map( 'GET'	, 'help'				, '?'					, 'help.prg' )
			
		//	Test Controller and parameter received and oRoute:Get()
			oApp:oRoute:Get( 'vista'				, 'vista'				, 'vista.prg' )
			oApp:oRoute:Get( 'vista1'				, 'vista/(id)'			, 'vista.prg' )
			
		//	Test Router() function 
			oApp:oRoute:Map( 'GET'	, 'router'				, 'router'				, 'router.prg' )
				
		//	Test controller via function/class
			oApp:oRoute:Map( 'GET'	, 'client'				, 'client'				, 'clientfunction.prg' )
			oApp:oRoute:Map( 'GET'	, 'client.edit'			, 'client/edit'			, 'edit()clientfunction.prg' )
			oApp:oRoute:Map( 'GET'	, 'client.edit2'		, 'client/edit2'		, 'edit@clientcontroller.prg' )
				
		//	Test TResponse
			oApp:oRoute:Map( 'GET'	, 'response.json'		, 'response/json'		, 'json@response.prg' )
			oApp:oRoute:Map( 'GET'	, 'response.xml'		, 'response/xml'		, 'xml@response.prg' )
			oApp:oRoute:Map( 'GET'	, 'response.html'		, 'response/html'		, 'html@response.prg' )
			oApp:oRoute:Map( 'GET'	, 'response.401'		, 'response/401'		, 'error401@response.prg' )
			oApp:oRoute:Map( 'GET'	, 'response.redirect'	, 'response/redirect'	, 'redirect@response.prg' )
			
		//	Test sub-folder Controller
			oApp:oRoute:Map( 'GET'	, 'my_new'				, 'new'					, 'module_A/new.prg' )

		//	Test TValidator	/ Test oRoute:Get()		
			oApp:oRoute:Map( 'GET'	, 'validator'			, 'validator'			, 'test@validator.prg' )
			oApp:oRoute:Map( 'POST'   , 'validator.run'		, 'validator/run'		, 'run@validator.prg' )
				
		//	Test Model/Validator	
			oApp:oRoute:Map( 'GET'	,'users'				, 'users/(id)'			, 'info@users.prg' )								
	
		//	Test JWT	
			oApp:oRoute:Map( 'GET'	, 'jwt'					, 'jwt'					, 'create@test_jwt.prg' )
			oApp:oRoute:Map( 'POST'	, 'jwt.valid'			, 'jwt/valid'			, 'valid@test_jwt.prg' )
	
		//	Test Login				
			oApp:oRoute:Map( 'GET'  , 'app'					, 'app'					, 'default@app/myapp.prg' )		
			oApp:oRoute:Map( 'GET'  , 'app.login'				, 'app/login'			, 'login@app/access.prg' )		
			oApp:oRoute:Map( 'GET'  , 'app.logout'			, 'app/logout'			, 'logout@app/access.prg' )	
			oApp:oRoute:Map( 'POST' , 'app.autentica'			, 'app/autentica'		, 'autentica@app/access.prg' )	
			oApp:oRoute:Map( 'GET'  , 'app.principal'			, 'app/principal'		, 'principal@app/myapp.prg' )		
			oApp:oRoute:Map( 'GET'  , 'app.test1'				, 'app/test1'			, 'test1@app/myapp.prg' )		
			oApp:oRoute:Map( 'GET'  , 'app.test2'				, 'app/test2'			, 'test2@app/myapp.prg' )		
			oApp:oRoute:Map( 'GET'  , 'app.test3'				, 'app/test3'			, 'test3@app/myapp.prg' )
	
		//	Test Login - Bootstrap		
			oApp:oRoute:Map( 'GET'  , 'boot'					, 'boot'				, 'default@boot/myapp.prg' )
			oApp:oRoute:Map( 'POST' , 'boot.autentica'		, 'boot/autentica'		, 'autentica@boot/access.prg' )
			oApp:oRoute:Map( 'GET'  , 'boot.logout'			, 'boot/logout'			, 'logout@boot/access.prg' )
			oApp:oRoute:Map( 'GET'  , 'boot.principal'		, 'boot/principal'		, 'principal@boot/myapp.prg' )				
			oApp:oRoute:Map( 'GET'  , 'boot.test1'			, 'boot/test1'			, 'test1@boot/myapp.prg' )		
			oApp:oRoute:Map( 'GET'  , 'boot.test2'			, 'boot/test2'			, 'test2@boot/myapp.prg' )		
			oApp:oRoute:Map( 'GET'  , 'boot.test3'			, 'boot/test3'			, 'test3@boot/myapp.prg' )			

		//	Test Paramaters	
			oApp:oRoute:Map( 'GET'  , 'param'					, 'param'				, 'test@param.prg' )
			
			
	//	Iniciamos el sistema
		oApp:Init()
	

RETU NIL

exit procedure e

	LOCAl nLap 	:= ( hb_milliseconds() - M->getList[ 1 ] )
	LOCAL cHtml 
	
	cHtml 	:= '<div style="position:fixed;bottom:0px;background-color: #98cfff;">&nbsp;Lapsus milliseconds: ' 
	cHtml  	+= '<b>' + ltrim(str( nLap )) + '</b>&nbsp;'
	cHtml  	+= '</div>'
	
	? cHtml

retu 
