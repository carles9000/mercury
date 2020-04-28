//	{% LoadHRB( '/lib/wdo_lib.hrb' ) %}			//	Loading system WDO

CLASS Users

	METHOD New() 	CONSTRUCTOR
	
	METHOD Info() 			
   
ENDCLASS

METHOD New( o ) CLASS Users	

	//o:Middleware( 'auth' )			

RETU SELF

METHOD Info( o ) CLASS Users

	LOCAL oValidator 	:= TValidator():New()
	LOCAL hRoles     	:= { 'id' => 'required|numeric' }	
	LOCAL nId 			:= o:RequestValue( 'id', 0, 'N' )
	LOCAL oUsers, hReg	

	//	Validacion de datos
	/*
		IF ! oValidator:Run( hRoles )
			o:oResponse:sendjson( { 'error' => oValidator:ErrorMessages(), 'metodo' => o:oRequest:Method() } )			
			RETU NIL
		endif
		*/

	//	Recuperación de datos
	
		oUsers		:= TUsers():New()
		hReg		:= oUsers:Get( nId )
		
	//	Respuesta

		o:oResponse:sendjson( hReg )
	
RETU NIL

{% include( AP_GETENV( 'PATH_APP' ) + "/src/model/tusers.prg" ) %}