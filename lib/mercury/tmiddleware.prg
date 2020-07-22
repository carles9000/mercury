
//	-----------------------------------------------------------	//

CLASS TMiddleware

	CLASSDATA cPsw 			          					INIT 'HWeB!2019v1'			
	CLASSDATA cId_Cookie           					INIT 'HFW_APP'					
	CLASSDATA cView_Default       						INIT 'HFW_APP'					
	CLASSDATA nTime			     						INIT 3600
	DATA oController									
	DATA oResponse				
	DATA hTokenData				
	DATA hJWTData				
	DATA cError 										INIT ''				
					
					
	CLASSDATA lHasAutenticate							INIT .F.
	CLASSDATA cType					 					INIT ''
	CLASSDATA cToken									INIT ''
	CLASSDATA cargo										INIT ''
	
	METHOD New( cAction, hPar ) 						CONSTRUCTOR
	METHOD Exec( oController, cType, cView )
	
	
	METHOD SetAutentication( cType, cCargo, cCargo2, cCargo3 )
	METHOD Credentials( cType, cId_Cookie, cPsw, nTime )		INLINE ::SetAutentication( 	cType, cId_Cookie, cPsw, nTime )
	
	METHOD SetAutenticationJWT( hData, nTime  )	
	METHOD SetAutenticationToken( hData, nTime )	
	
	METHOD ValidateJWT()			
	METHOD ValidateToken()
	
	METHOD CloseJWT()

	METHOD GetDataJWT()			
	METHOD GetDataToken()								INLINE  ::hTokenData
	
ENDCLASS 

METHOD New() CLASS TMiddleware

RETU Self


METHOD Exec( oController, cType, cRoute, hError, lJson ) CLASS TMiddleware

	LOCAL lValidate 	:= .F.
	LOCAL oResponse 	:= App():oResponse

	__defaultNIL( @cType, '' )		//	Por defecto habria de ser 'jwt'
	__defaultNIL( @cRoute, '' )		
	__defaultNIL( @hError, { 'success' => .f., 'error' => 'Error autentication' } )		
	__defaultNIL( @lJson, .F. )		
	
	cType := lower( cType )


	DO CASE
		CASE cType == 'jwt' 

			lValidate := ::ValidateJWT()

			
			IF ! lValidate


				IF !empty( cRoute ) 
			
					IF right( lower(cRoute), 5 ) == '.view'

				
						//	Borrar cookie

							oResponse:SetCookie( ::cId_Cookie, '', -1 )
						

						//	Redireccionamos pantalla incial
							oController:View( cRoute )
						
					ELSE


						oResponse:Redirect( Route( cRoute ) )

					
					ENDIF 
					
				ELSE
				
					IF lJson 
						oResponse:SendJson( hError )	
					else														
						?? ''		//	White screen					
					endif
				
				ENDIF
			
				//	Exit				
				//	QUIT
		
				
			ENDIF
			
		CASE cType == 'token' 

			lValidate := ::ValidateToken()

			
			IF ! lValidate			
				
				oResponse:SendJson( hError )							
				
				//	Exit				
				//	QUIT
				
			ENDIF			
			
		OTHERWISE
		
			//	Error porque no existe el middleware.... (ya veremos...)
			
	ENDCASE


RETU lValidate


METHOD SetAutenticationJWT( hData, nTime ) CLASS TMiddleware

	LOCAL oJWT 			:= JWT():New( ::cPsw )	
	LOCAL oResponse 		:= App():oResponse
	LOCAL cToken 
	
	__defaultNIL( @hData, {=>} )
	DEFAULT nTime := 0
	
	::lHasAutenticate	:= .T.
	::cType 				:= 'jwt'
	::hTokenData 			:= hData
	::nTime 				:= if( nTime > 0, nTime, ::nTime )

	//	Crearemos un JWT. Default system 3600
		
		oJWT:SetTime( ::nTime )			
		
	//	Añadimos datos al token...

		oJWT:SetData( hData )										
		
	//	Cremos Token

		cToken := oJWT:Encode()		
	
	//	Preparamos la Cookie. NO se envia aun, hasta que haya un sendhtml()...

		oResponse:SetCookie( ::cId_Cookie, cToken, ::nTime )


RETU NIL

METHOD SetAutenticationToken( hData, nTime ) CLASS TMiddleware

	LOCAL oJWT 			:= JWT():New( ::cPsw )	
	LOCAL oResponse 		:= App():oResponse
	LOCAL cToken 
	local lValid
	
	__defaultNIL( @hData, {=>} )
	DEFAULT nTime := 0
	
	::lHasAutenticate	:= .T.
	::cType 				:= 'token'
	::hTokenData 			:= hData
	::nTime 				:= if( nTime > 0, nTime, ::nTime )

	//	Crearemos un JWT. Default system 3600
		
		oJWT:SetTime( ::nTime )			
		
	//	Añadimos datos al token...

		oJWT:SetData( hData )										
		
	//	Cremos Token

		cToken := oJWT:Encode()					
	
	//	A diferencia de SetAutenticationJWT, no enviamos cookie. 
	//	Devolveremos el Token

RETU cToken

METHOD GetDataJWT() CLASS TMiddleware

	LOCAL oRequest 			:= App():oRequest
	LOCAL cToken 			:= oRequest:GetCookie( ::cId_Cookie )
	LOCAL oJWT 				:= JWT():New( ::cPsw )	
	LOCAL lValid 			:= oJWT:Decode( cToken )	
	LOCAL hData 			:= NIL
	
	IF lValid 
		hData := oJWT:GetData()
	ENDIF
	
RETU hData


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
	
		oJWT 	:= JWT():New( ::cPsw ) 	
		lValid 	:= oJWT:Decode( cToken )						

		IF ! lValid
			
			RETU .F.
			
		ELSE
		
			//	En este punto tenemos el token decodificado dentro del objeto oJWT
			
				::hJWTData := oJWT:GetData()
				
			//	Consultamos el lapsus que hay definidio, para ponerla en la nueva cookie
				nLapsus 	:= oJWT:GetLapsus()

		
			//	Si el Token es correcto, prepararemos el sistema para que lo refresque cuando genere una nueva salida

				cToken 	:= oJWT:Refresh()		//	Vuelve a crear el Token teniendo en cuenta el lapsus
				
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

//	--------------------------------------------------------------------------

METHOD ValidateToken( cToken ) CLASS TMiddleware

	LOCAL oRequest 		:= App():oRequest
	LOCAL oResponse 		:= App():oResponse	
	LOCAL oJWT	
	LOCAL lValid, nLapsus,nPos, h
	
	DEFAULT cToken := ''
	
	if empty( cToken )
		cToken 	:= oRequest:GetHeader( 'Authorization' )
		
		if !empty( cToken )
			nPos := At( 'Bearer', cToken )
			
			if nPos > 0 
				cToken := alltrim(Substr( cToken, 7 ))
			endif
			
		endif
	endif
	

	::hJWTData := NIL		
	
	IF empty( cToken )

		RETU .F.
		
	ELSE	//	Chequearemos validez del token...					

		oJWT 	:= JWT():New( ::cPsw ) 	
		lValid 	:= oJWT:Decode( cToken )						

		IF ! lValid
			
			RETU .F.
			
		ELSE
		
			h = oJWT:GetData()
			
			//	Check expiration time
			
				if h[ 'exp' ] < Seconds() 
					::cError := 'Time expired'
					retu .f.
				endif
				

			//	En este punto tenemos el token decodificado dentro del objeto oJWT
			
				::hTokenData := oJWT:GetData()
				
		/*
				
			//	Consultamos el lapsus que hay definidio, para ponerla en la nueva cookie
			
				nLapsus 	:= oJWT:GetLapsus()

		
			//	Si el Token es correcto, prepararemos el sistema para que lo refresque cuando genere una nueva salida

				cToken 	:= oJWT:Refresh()		//	Vuelve a crear el Token teniendo en cuenta el lapsus
				
			//	Crearemos una cookie con el JWT, con el mismo periodo			
			
				oResponse:SetCookie( ::cId_Cookie, cToken, nLapsus )
		*/
			
			RETU .T.
			
		ENDIF				
	
	ENDIF		

RETU .T.





//	--------------------------------------------------------------------------

METHOD SetAutentication( cType, cPar1, cPar2, cPar3 ) CLASS TMiddleware

	DEFAULT cType :=  'jwt'
	DEFAULT cPar1 :=  ''
	DEFAULT cPar2 :=  ''
	DEFAULT cPar3 :=  ''
	

	DO CASE
		CASE cType = 'jwt' 
			::cId_Cookie 	:= if( !empty(cPar1), cPar1, ::cId_Cookie )
			::cPsw 			:= if( !empty(cPar2), cPar2, ::cPsw )
			::nTime 		:= if( !empty(cPar3), cPar3, 3600 )
	ENDCASE

RETU NIL

//	-----------------------------------------------------------	//