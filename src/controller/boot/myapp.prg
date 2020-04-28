CLASS MyApp

	METHOD New() 	CONSTRUCTOR
	
	METHOD default()	
	METHOD principal()			//	Menu de la aplicacion
	
	METHOD test1()				//	Módulos del sistema
	METHOD test2()				//	Módulos del sistema
	METHOD test3()				//	Módulos del sistema
   
ENDCLASS

METHOD New( o ) CLASS MyApp

	//	Control de acceso al controlador. El middleware se aplicará a todos los metodos
	//	excepto a los que indiquemos aqui

	IF o:cAction $ 'default' 			//	Modulo que no se validan: publicos, defaults,...
	
		// 'No middleware...'
		
	ELSE

		o:Middleware( 'jwt', 'boot/default.view'  )			//	View
		
	ENDIF
	
RETU SELF

METHOD Default( o ) CLASS MyApp

	o:View( 'boot/default.view' )

RETU NIL

METHOD Principal( o ) CLASS MyApp	

	App():Set( 'menu', '1' )

	o:View( 'boot/principal.view' )

RETU NIL


METHOD Test1( o ) CLASS MyApp

	App():Set( 'menu', '1' )

	o:View( 'boot/test1.view' )
	
RETU NIL

METHOD Test2( o ) CLASS MyApp

	App():Set( 'menu', '2' )
	
	o:View( 'boot/test2.view' )
	
RETU NIL

METHOD Test3( o ) CLASS MyApp
	
	LOCAl oMiddleware := o:oMiddleware
	
	App():Set( 'menu', '3' )

	o:View( 'boot/test3.view', oMiddleware:hJWTData )
	
RETU NIL
