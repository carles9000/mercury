CLASS ClientController	

	DATA cDef		INIT 'Dummy text of ClientController...'

	METHOD New() 	CONSTRUCTOR
	METHOD Edit() 
   
ENDCLASS

METHOD New( o ) CLASS ClientController	

RETU SELF

METHOD Edit( o ) CLASS ClientController

	?? '<h2>Controller Class ! ==> Method Edit()...</h2>'
	
RETU NIL
