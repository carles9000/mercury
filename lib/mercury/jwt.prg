/*	---------------------------------------------------------
	File.......: jwt.prg
	Description: Support to Json Web Token. 
	Author.....: Carles Aubia Floresvi
	Date:......: 10/07/2019
	Usage......: 
		oJWT:Encode() -> Create a new JWT
		oJWT:Decode( cJWT ) -> Decode Token. Return .T./.F.
		oJWT:SetVar( cVar, cValue ) -> Create a new var
		oJWT:GetVar( cVar ) -> Recover value var
		oJWT:GetData() -> Recover all
		oJWT:SetKey( cKey ) -> Set default server key 
	--------------------------------------------------------- */

CLASS JWT

	DATA aHeader 				INIT {=>}
	DATA aPayload 				INIT {=>}
	DATA cKey 					INIT 'HWeB!2019v1'
	DATA cError					INIT ''
	DATA nLapsus				INIT 3600			//	Lapsus in seconds...

	METHOD New() CONSTRUCTOR
	METHOD Reset()
	
	METHOD Encode()
	METHOD Decode()
	METHOD Refresh()					INLINE ::Encode()
	
	METHOD SetKey( cKey )				INLINE ::cKey := cKey 
	METHOD SetTime( nLapsus )			INLINE ::nLapsus := nLapsus
	
	METHOD SetData( hData )
	METHOD SetVar( cVar, cValue )

	METHOD GetLapsus()				INLINE HB_HGetDef( ::aPayLoad, 'lap', ::nLapsus )
	
	METHOD GetVar( cVar, uDefault )
	METHOD GetExp()						//	Exp = Expires 
	
	METHOD GetData()					INLINE ::aPayload
	METHOD GetError()					INLINE ::cError

ENDCLASS

METHOD New( cKey ) CLASS JWT

	DEFAULT cKey := ''
	
	if !empty( cKey )
		::cKey := cKey 
	endif

	//	At the moment we're working in this method...
		
		::aHeader[ 'typ' ] := 'JWT'
		::aHeader[ 'alg' ] := 'HS256'	

RETU SELF

METHOD Encode() CLASS JWT

	LOCAL cHeader, cHeader64 		
	LOCAL cPayload, cPayload64  	
	LOCAL cSignature, cSignature64
	LOCAL cJWT
	
	//	Actualizamos fecha de expiracion (CLAIMS)
	
		::aPayload[ 'iss'  ]:= 'mercury'					//	Emisor
		::aPayload[ 'exp'  ]:= Seconds() + ::nLapsus		//	Expire
		::aPayload[ 'lap'  ]:= ::nLapsus					//	lapsus
		
	//	Codificamos Header y Payload
	
		cHeader   		:= hb_jsonEncode( ::aHeader ) 
		cPayload 		:= hb_jsonEncode( ::aPayload ) 
		cHeader64   	:= hb_base64Encode( cHeader )
		cPayload64  	:= hb_base64Encode( cPayload )	
	
	//	Clean special codes...
	
		cHeader64		:= hb_StrReplace( cHeader64 , '+/=', '-_ ' )
		cPayload64 	:= hb_StrReplace( cPayload64, '+/=', '-_ ' )

	//	Make signature	
	
		cSignature 	:= HB_HMAC_SHA256( ( cHeader64 + '.' + cPayload64 ), ::cKey )
		cSignature64 	:= hb_base64Encode( cSignature )
		cSignature64 	:= hb_StrReplace( cSignature64, '+/=', '-_ ' )
		
	//	Make JWT
	
		cJWT := cHeader64 + '.' + cPayload64 + '.' + cSignature64	
		
RETU cJWT

METHOD Reset() CLASS JWT

	::aHeader 	:= {=>}
	::aPayload := {=>}	
	::cError	:= ''
	
RETU NIL 

METHOD Decode( cJWT ) CLASS JWT

	LOCAL aJWT
	LOCAL cSignature, cNewSignature 
	
	//	Antes de decodificar reseteamos datas
	
		::Reset()
		
	//	Una firma JWT consta de 3 parte separadas por "."	

		aJWT := HB_ATokens( cJWT, '.' )		
	
		IF len(aJWT) <> 3 
			::cError := 'Error estructura token' 
			RETU .F.
		ENDIF
	
	//	Recuperamos datos del Header	
	
		::aHeader 	:= hb_jsonDecode( hb_base64Decode( aJWT[1] ))
		
	//	Recuperamos datos del PayLoad
	
		::aPayload 	:= hb_jsonDecode( hb_base64Decode( aJWT[2] ))
		
	//	Recuperamos Firma
	
		cSignature  := hb_base64Decode( aJWT[3] )
	
	//	Creamos una firma nueva para validar que es la misma que hemos recuperado
	
		cNewSignature 	:= HB_HMAC_SHA256( ( aJWT[1] + '.' + aJWT[2]) , ::cKey )
		
		IF ( cSignature == cNewSignature )
		ELSE
			::cError := 'Verificacion de firma ha fallado'
			RETU .F.
		ENDIF

	//	Validamos 'exp' (JWT Claims)
	
		IF ::aPayLoad[ 'exp' ] < Seconds()
			::cError := 'Token ha expirado'
			RETU .F.		
		ENDIF
		
	//	Restauramos nuestro CLAIM lap
	
		::nLapsus := ::GetLapsus()

RETU .T.


METHOD SetData( hData ) CLASS JWT
	LOCAL nI, h 

	FOR nI := 1 TO len( hData )
		h := HB_HPairAt( hData, nI )
		::SetVar( h[1], h[2] )		
	NEXT			

RETU NIL

METHOD SetVar( cVar, uValue ) CLASS JWT

	__defaultNIL( @cVar, '' )
	
	cVar := alltrim(lower( cVar ))
	
	//	Xec Claims var
	
		IF ( cVar $ 'exp;iss;lap' )
			RETU NIL
		ENDIF
	
	//	Set var
	
		::aPayload[ cVar ] := uValue 	

RETU NIL

METHOD GetVar( cVar ) CLASS JWT

	LOCAL uValue := ''

	__defaultNIL( @cVar, '' )
	
	cVar := alltrim(lower(cVar))			

RETU HB_HGetDef( ::aPayLoad, cVar, '' )

METHOD GetExp() CLASS JWT				//	Exp = Expire.... Por efecto devolveremos el default de la clase
RETU ::Getvar( 'exp', ::nLapsus )

