CLASS Validator

	METHOD New() 	CONSTRUCTOR
	
	METHOD Test() 
	METHOD Run()		
   
ENDCLASS

METHOD New( o ) CLASS Validator	

RETU SELF

METHOD Test( o ) CLASS Validator

	//	Crearemos una pagina para entrar datos para posteriormente valorarlos...

		o:View( 'test_validator.view' )
	
RETU NIL


METHOD Run( o ) CLASS Validator
	
	LOCAL oValidator := TValidator():New()
	LOCAL hRoles     := {=>}	
	
		hRoles[ 'name' ] := 'required|string|maxlen:5'
		hRoles[ 'age'  ] := 'required|numeric'

		IF ! oValidator:Run( hRoles )
			o:View( 'test_validator_run.view', oValidator:ErrorMessages() )			
			RETU NIL
		endif		


	o:View( 'test_validator_run.view' )
	
RETU NIL
