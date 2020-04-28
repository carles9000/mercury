CLASS ExampleController

	METHOD New( oController )
	
	METHOD Default( oController )	
	
ENDCLASS 


//	--------------------------------------------------	//

METHOD New( oController ) CLASS ExampleController

RETU SELF


//	--------------------------------------------------	//

METHOD Default( oController ) CLASS ExampleController

	local cVersion := Version()
	
	oController:View( 'hello.view', cVersion )

RETU nil


//	--------------------------------------------------	//