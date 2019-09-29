
//	-----------------------------------------------------------	//

CLASS TMiddleware

	DATA cId_Cookie           		INIT 'HFW_APP'					
	DATA cView_Default       		INIT 'HFW_APP'					
	DATA oController					
	DATA oResponse
	DATA hTokenData
	DATA hJWTData
	
	
	CLASSDATA lHasAutenticate		INIT .F.
	CLASSDATA cType					INIT ''
	CLASSDATA cToken				INIT ''
	CLASSDATA cargo					INIT ''
	
	METHOD New( cAction, hPar ) CONSTRUCTOR
	METHOD Exec( oController, cValid )
	
	METHOD SetAutentication( cType, cCargo )
	METHOD SetAutenticationJWT( cType )			
	METHOD ValidateJWT()			
	METHOD CloseJWT()			

	
ENDCLASS 

METHOD New() CLASS TMiddleware

	//CASCA ::oResponse := App():oResponse
	//::oResponse := App():oResponse

RETU Self


METHOD Exec( oController, cValid, cView ) CLASS TMiddleware

	LOCAL lValidate 	:= .F.
	LOCAL oResponse 	:= App():oResponse


	__defaultNIL( @cValid, '' )		//	Por defecto habria de ser 'auth'
	
	cValid := lower( cValid )

	DO CASE
		CASE cValid == 'jwt' 
	
			IF ! ::ValidateJWT()
			
				IF right( lower(cView), 5 ) == '.view'
			
					//	Borrar cookie
						oResponse:SetCookie( ::cId_Cookie, '', -1 )
					
					//	Redireccionamos pantalla incial
						oController:View( cView )
					
					//	Exit				
						QUIT
					
				ELSE
				
					oResponse:Redirect( cView ) 
					
				ENDIF 
			ENDIF
			
		OTHERWISE
		
			//	Error porque no existe el middleware.... (ya veremos...)
			
	ENDCASE


RETU lValidate

METHOD SetAutenticationJWT( hData, nTime ) CLASS TMiddleware

	LOCAL oJWT 		:= JWT():New()	
	LOCAL oResponse 	:= App():oResponse
	LOCAL cToken 
	
	__defaultNIL( @hData, {=>} )
	__defaultNIL( @nTime, 3600 )
	
	::lHasAutenticate	:= .T.
	::cType 			:= 'jwt'
	::hTokenData 		:= hData
	
	//	Crearemos un JWT. Tiempo de validez (10 seg.). Default system 3600
	
		oJWT:SetTime( nTime )	
		
	//	Añadimos datos al token...

		oJWT:SetData( hData )										
		
	//	Cremos Token

		cToken := oJWT:Encode()		
	
	//	Preparamos la Cookie. NO se envia aun, hasta que haya un sendhtml()...

		oResponse:SetCookie( ::cId_Cookie, cToken, nTime )


RETU NIL

METHOD ValidateJWT( cRoute ) CLASS TMiddleware

	LOCAL oRequest 		:= App():oRequest
	LOCAL oResponse 		:= App():oResponse
	LOCAL cToken 			:= oRequest:GetCookie( ::cId_Cookie )
	LOCAL oJWT	
	LOCAL lValid, nLapsus	

	::hJWTData := NIL
	
	IF empty( cToken )

		RETU .F.
		
	ELSE	//	Chequearemos validez del token...
	
		oJWT 	:= JWT():New()	
		lValid 	:= oJWT:Decode( cToken )						

		IF ! lValid
			
			RETU .F.
			
		ELSE
		
			//	En este punto tenemos el token decodificado dentro del objeto oJWT
			
				::hJWTData := oJWT:GetData()
				
			//	Consultamos el lapsus que hay definidio, para ponerla en la nueva cookie
				nLapsus 	:= oJWT:GetLapsus()
		
		
			//	Si el Token es correcto, prepararemos el sistema para que lo refresque cuando genere una nueva salida

				cToken 		:= oJWT:Refresh()		//	Vuelve a crear el Token teniendo en cuenta el lapsus
				
			//	Crearemos una cookie con el JWT, con el mismo periodo			
			
				oResponse:SetCookie( ::cId_Cookie, cToken, nLapsus )
			
			RETU .T.
			
		ENDIF				

	
	ENDIF
	

RETU .T.


METHOD CloseJWT( cRoute ) CLASS TMiddleware

	LOCAL oResponse 	:= App():oResponse		
			
	oResponse:SetCookie( ::cId_Cookie, '', -1 )

RETU .T.

METHOD SetAutentication( cType, cCargo ) CLASS TMiddleware

	DO CASE
		CASE cType = 'jwt' 
			::cId_Cookie := cCargo 
	ENDCASE

RETU NIL



//	-----------------------------------------------------------	//