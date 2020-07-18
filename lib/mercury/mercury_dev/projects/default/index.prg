//	------------------------------------------------------------------------------
//	Title......: 
//	Description: 
//	Date.......: 
//
//	{% LoadHRB( '/lib/core/core_lib.hrb' ) %}		//	Loading core
//	{% LoadHRB( '/lib/mercury/mercury.hrb' ) %}		//	Loading system MVC Mercury
//	------------------------------------------------------------------------------

#include {% MercuryInclude( 'lib/mercury' ) %}

FUNCTION Main()

	LOCAL oApp 	:= App()

	//	Config Routes

		DEFINE ROUTE 'default' URL '/' CONTROLLER 'default@examplecontroller.prg' 	METHOD 'GET' OF oApp

		
	//	System start...
	
		oApp:Init()
	

RETU NIL

