#include {% MercuryInclude( 'lib/mercury' ) %}

CLASS MyApp

	METHOD New() 	CONSTRUCTOR
	
	METHOD default()	
	METHOD principal()		//	Menu de la aplicacion
	
	METHOD test1()				//	Módulos del sistema
	METHOD test2()				//	Módulos del sistema
	METHOD test3()				//	Módulos del sistema
   
ENDCLASS

METHOD New( o ) CLASS MyApp

	//	Control de acceso al sistema. El middleware se aplicará a todos los metodos
	//	excepto a los que indiquemos aqui

	// Si method direct...
	
	IF o:cAction $ 'default' 			//	Modulo que no se validan: publicos, defaults,...
	
		// 'No middleware...'
		
	ELSE

		AUTENTICATE CONTROLLER o DEFAULT 'app.login'
		
		//o:Middleware( 'jwt', 'app/default.view'  )			


		//Podriamos ejecutar mas middleware... (not yet)
		//	o:Middleware( 'roles', Route( 'app' ), ... )
		
	ENDIF
	
RETU SELF

METHOD Default( o ) CLASS MyApp

	o:View( 'app/default.view' )

RETU NIL

METHOD Principal( o ) CLASS MyApp

	o:View( 'app/principal.view' )

RETU NIL


METHOD Test1( o ) CLASS MyApp

	o:View( 'app/test1.view' )
	
RETU NIL

METHOD Test2( o ) CLASS MyApp

	o:View( 'app/test2.view' )
	
RETU NIL

METHOD Test3( o ) CLASS MyApp

	LOCAl oMiddleware := o:oMiddleware

	o:View( 'app/test3.view', oMiddleware:hJWTData )
	
RETU NIL
