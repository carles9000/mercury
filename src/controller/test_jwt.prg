CLASS Test_JWT

	METHOD New() 	CONSTRUCTOR
	
	METHOD Create() 
	METHOD Valid() 
	
   
ENDCLASS

METHOD New( o ) CLASS Test_JWT	

RETU SELF

METHOD Create( o ) CLASS Test_JWT

	LOCAL oJWT 	:= JWT():New()
	LOCAL cToken 	:= ''

	//	Crearemos un JWT. Tiempo de validez (10 seg.). Default system 3600
	
		oJWT:SetTime( 10 )
		
	//	Añadimos datos al token...
	
		oJWT:SetVar( 'name'	, 'James Brown' )
		oJWT:SetVar( 'IBN'	, 'ABC-01234-654-234' )
		oJWT:SetVar( 'id'	, 12345 )
	
		cToken := oJWT:Encode()
		
	//	Cremos la vista mostrando el Token		

		o:View( 'test_jwt.view', cToken )
	
RETU NIL

METHOD Valid( o ) CLASS Test_JWT

	LOCAL oJWT 	:= JWT():New()
	LOCAL cToken 	:= o:PostValue( 'token' )
	LOCAL lValid	:= .F.
	LOCAL hData	:= {=>}
	LOCAL cError	:= ''

	//	Crearemos un JWT. Tiempo de validez (10 seg.)
	
		lValid 	:= oJWT:Decode( cToken )
		hData 	:= oJWT:GetData()
		cError 	:= oJWT:GetError()
		
	//	Cremos la vista validacion...

		o:View( 'test_jwt_valid.view', lValid, hData, cError )
	
RETU NIL

