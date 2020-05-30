//	------------------------------------------------------------------------------
//	Title......: Use Mercury !
//	Description: Example de web application with mercury...
//	Date.......: 22/05/2020
//	------------------------------------------------------------------------------
//	{% LoadHRB( '/lib/mercury/mercury.hrb' ) %}	//	Loading system MVC Mercury
//	------------------------------------------------------------------------------

#include {% MercuryInclude( 'lib/mercury' ) %}


function Main()

	local oApp 	

	//	Define App

		DEFINE APP oApp TITLE 'My web aplication...' ;
			ON INIT Config()							
		
		//	Config Routes		
		
			DEFINE ROUTE 'root' 		URL '/' 			VIEW 		'hello.view' 					METHOD 'GET' OF oApp		
			DEFINE ROUTE 'view1' 		URL 'view1'			VIEW 		'view1.view' 					METHOD 'GET' OF oApp		
			DEFINE ROUTE 'view2' 		URL 'view2'			VIEW 		'view2.view' 					METHOD 'GET' OF oApp		
			DEFINE ROUTE 'fruits' 		URL 'fruits'		CONTROLLER 'fruits@mycontroller.prg'		METHOD 'GET' OF oApp		
			DEFINE ROUTE 'idzip' 		URL 'idzip'			CONTROLLER 'idzip@mycontroller.prg' 		METHOD 'GET' OF oApp		


	//	System init...
	
		INIT APP oApp	

retu nil

function AppPath(); 			RETU AP_GetEnv( "DOCUMENT_ROOT" ) + AP_GetEnv( "PATH_APP" )
function AppPathData() ; 		RETU AP_GetEnv( "DOCUMENT_ROOT" ) + AP_GetEnv( "PATH_DATA" )

function AppUrlImg() ;		RETU AP_GetEnv( "PATH_URL" ) + '/images/'
function AppUrlLib() ;		RETU AP_GetEnv( "PATH_URL" ) + '/lib/'
function AppUrlJs() ;			RETU AP_GetEnv( "PATH_URL" ) + '/js/'
function AppUrlDat() ;		RETU AP_GetEnv( "PATH_DATA" )


function Config() 
	
	SET DATE FORMAT TO 'dd-mm-yyyy'	

retu nil 
