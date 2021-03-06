CLASS Access

	METHOD New() 	CONSTRUCTOR
	
	METHOD login() 
	METHOD Autentica() 
	METHOD Logout() 
	
   
ENDCLASS

METHOD New( o ) CLASS Access	


RETU SELF

METHOD login( o ) CLASS Access

	//	Crearemos una pagina para entrar datos para posteriormente valorarlos...

		o:View( 'app/login.view' )
	
RETU NIL


METHOD Autentica( o ) CLASS Access

	LOCAL oMiddleware	:= o:oMiddleware
	LOCAL oResponse		:= o:oResponse
	LOCAL oValidator 	:= TValidator():New()
	LOCAL hRoles     	:= { 'user' => 'required|string|maxlen:8', 'psw' => 'required' }	
	LOCAL cUser 		:= o:PostValue( 'user' )
	LOCAL cPsw 			:= o:PostValue( 'psw' )
	LOCAL hReg 
	LOCAL hUser	 		:= {=>}
	LOCAL hTokenData 	:= {=>}
	
	//	IMPORTANTE: En este sistema JWT como enviamos una cookie con el JWT, no podremos hacer
	//	redirect, por lo que enviaremos la vista que queramos y listos.
	
	
	//	Nuestro sistema de errores decidimos que devolvera un hash con la siguiente estructura
	//	success 	= .T./.F.
	//	type 		= 'validator/user
	//	msg 		= Si es del validator es un array de mensajes de error: 1..n/ Si es de usuario un string	
	//	-------------------------------------------------------------------------------------------------


	//	Validacion de datos
	
		IF ! oValidator:Run( hRoles )
			o:View( 'app/login.view' ,  { 'success' => .F., 'type' => 'validator', 'error' => oValidator:ErrorMessages() } )					
			RETU NIL
		ENDIF
		
		
		
	//	Validacion de Usuario
	
		IF cUser == 'dummy' .AND. cPsw == '1234'
		
			//	Recojo datos de Usuario (from model)
			
				hUser := { 'id' => 1234, 'user' => 'dummy', 'name' => 'Usuario Dummy...' }				
			
			//	Datos que incrustarer en el token...	
				
				hTokenData := { 'entrada' => time(), 'empresa' => 'Intelligence System', 'user' => hUser } 			
			
			//	Inicamos nuestro sistema de Validación del sistema basado en JWT
			
				oMiddleware:SetAutenticationJWT( hTokenData, 10 )															
			
			//	Mostramos página principal
			
				//o:View( 'app/principal.view', hTokenData )
				o:Redirect( Route( 'app.principal' ) )
				
		ELSE
		
			o:View( 'app/login.view' , { 'success' => .F., 'type' => 'user', 'error' => 'No se ha podido autenticar correctamente' } )
			
		ENDIF

RETU NIL

METHOD logout( o ) CLASS Access

	LOCAL oMiddleware	 := o:oMiddleware		///App():oMiddleware
	
	oMiddleware:CloseJWT()

	o:View( 'app/default.view' )

RETU NIL