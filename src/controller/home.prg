CLASS Home

	METHOD New() 	CONSTRUCTOR
	
	METHOD Default() 

	
   
ENDCLASS

METHOD New( o ) CLASS Home

? 'Home'
? 'cargo: ' , 	o:oMiddleware:cargo

RETU SELF

METHOD Default( o ) CLASS Home

	o:View( 'home.view' )
	
RETU NIL
