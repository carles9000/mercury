FUNCTION Controller( oTController )

	LOCAL oApp
	
	//	Objetos dentro de oTController
	
		?? '<h3>oTController<hr></h3>'

		? oTController:classname()	
		? oTController:oRequest:classname()
		? oTController:oResponse:classname()	 	 

	
	//	Objetos dentro de App()
	
		?? '<h3>App()<hr></h3>'	
		
		oApp := App()				//	Helper
		
		? oApp:ClassName()	
		? oApp:oRoute:ClassName()
		? oApp:oRequest:ClassName()
		? oApp:oResponse:ClassName()
		? oApp:ListApp()
	
	//	Respuesta directa desde oResponse
		oTController:oResponse:SendHtml( '<h2>Hello oResponse...</h2>' )
	
	//	Respuesta via método Vista
		oTController:View( 'vista_default.view' ) 		
		
RETU NIL
