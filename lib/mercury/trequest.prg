

CLASS TRequest

	DATA hGet								INIT {=>}
	DATA hPost								INIT {=>}
	DATA hHeaders							INIT {=>}
	DATA hCookies							INIT {=>}
	DATA hRequest							INIT {=>}
	DATA hCgi								INIT {=>}
	
	METHOD New() CONSTRUCTOR
	METHOD Method()							INLINE AP_GetEnv( 'REQUEST_METHOD' )
	METHOD Get( cKey, uDefault, cType )	
	METHOD GetAll()							INLINE ::hGet
	METHOD Post( cKey, uDefault, cType )	
	METHOD PostAll()							INLINE ::hPost
	METHOD Cgi ( cKey )	
	METHOD CountGet()							INLINE len( ::hGet )
	METHOD CountPost()						INLINE len( ::hPost )
	METHOD LoadGet()
	METHOD LoadPost()
	METHOD LoadRequest()
	METHOD LoadHeaders()
	METHOD GetQuery()
	METHOD GetUrlFriendly()   
	METHOD GetCookie( cKey )					INLINE HB_HGetDef( ::hCookies, cKey, '' ) 
	METHOD Request( cKey, uDefault, cType )
	METHOD RequestAll()						INLINE ::hRequest
	METHOD ValueToType( uValue, cType )

ENDCLASS

METHOD New() CLASS TRequest
		
	::LoadGet()	
	::LoadPost()
	::LoadHeaders()

return Self

METHOD Get( cKey, uDefault, cType ) CLASS TRequest

	LOCAL nType 
	LOCAL uValue	:= ''

	__defaultNIL( @cKey, '' )
	__defaultNIL( @uDefault, '' )
	__defaultNIL( @cType, '' )		

	IF !empty(cKey) .AND. hb_HHasKey( ::hGet, cKey )
		uValue := hb_UrlDecode(::hGet[ cKey ])
	ELSE
		uValue := uDefault
	ENDIF

	uValue := ::ValueToType( uValue, cType )

RETU uValue

METHOD Post( cKey, uDefault, cType ) CLASS TRequest

	LOCAL nType 
	LOCAL uValue 	:= ''
	
	__defaultNIL( @cKey, '' )
	__defaultNIL( @uDefault, '' )	
	__defaultNIL( @cType, '' )			

	IF hb_HHasKey( ::hPost, cKey )
		uValue := hb_UrlDecode(::hPost[ cKey ])
	ELSE
		uValue := uDefault
	ENDIF
	
	uValue := ::ValueToType( uValue, cType )

RETU uValue

METHOD Request( cKey, uDefault, cType ) CLASS TRequest

	LOCAL nType 
	LOCAL uValue 	:= ''
	
	__defaultNIL( @cKey, '' )
	__defaultNIL( @uDefault, '' )	
	__defaultNIL( @cType, '' )	
	


	IF hb_HHasKey( ::hRequest, cKey )
		uValue := hb_UrlDecode(::hRequest[ cKey ])
	ELSE
	
		uValue := uDefault
	ENDIF

	uValue := ::ValueToType( uValue, cType )	

RETU uValue

METHOD ValueToType( uValue, cType ) CLASS TRequest

	DO CASE
		CASE cType == 'C'
		CASE cType == 'N'; uValue := If( valtype(uValue) == 'N', uValue, Val( uValue ) )
	ENDCASE

RETU uValue 

METHOD LoadRequest() CLASS TRequest

	//	Directiva request_order = 'EGPCS'
	//	ENV, GET, POST, COOKIE y SERVER
	
	// 	De momento rellenaremos en este orden GET, POST, pero lo trataremos de manera inversa: POST, GET,...
	//	porque HB_HMERGE machaca si existe una key, es decir la ultima q se procesa que es el GET si existe
	//	machacara la key del post. Vale mas GET que POST

	//	POST
	
		::hRequest := ::hPost
		
	//	GET
	//	https://github.com/zgamero/sandbox/wiki/2.7-Hashes	

		HB_HMerge( ::hRequest, ::hGet, HB_HMERGE_UNION )	

RETU NIL


METHOD LoadGet() CLASS TRequest

	LOCAL cArgs := AP_Args()
	LOCAL cPart, nI
	
	FOR EACH cPart IN hb_ATokens( cArgs, "&" )
	
		IF ( nI := At( "=", cPart ) ) > 0
			//::hGet[ lower(Left( cPart, nI - 1 )) ] := Alltrim(SubStr( cPart, nI + 1 ))
			HB_HSet( ::hGet, lower( hb_UrlDecode( Left( cPart, nI - 1 ) ) ), Alltrim(SubStr( cPart, nI + 1 )) )
		ELSE
			//::hGet[ lower(hb_UrlDecode(cPart)) ] :=  ''
			HB_HSet( ::hGet, lower(hb_UrlDecode(cPart)), '' )
		ENDIF
	   
	NEXT	

	IF Len( ::hGet ) == 1 .AND. empty( HB_HKeyAt( ::hGet, 1 ) )
		::hGet := {=>}
	ENDIF 

RETU NIL

METHOD LoadPost() CLASS TRequest

	LOCAL hPost := AP_PostPairs()
	LOCAL aPair
	LOCAL nI	
		
	//	Bug AP_PostPairs, si esta vacio devuelve un hash de 1 posicion sin key ni value
	
	IF Len( hPost ) == 1 .AND. empty( HB_HKeyAt( hPost, 1 ) )
	
		::hPost := {=>}
		
	ELSE
	
		//	Es posible que la key se haya de descodificar como por ejemplo cuando Datatables
		//	envia un post con muchos campos de este tipo: "columns%5B0%5D%5Bdata%5D". 
		//	Es por esto que se decodifica				
	
		FOR nI := 1 TO len( hPost )
		
			aPair := HB_HPairAt( hPost, nI )			

			HB_HSet( ::hPost, hb_UrlDecode(aPair[1]), hb_UrlDecode(aPair[2]) )
		
		NEXT				
	
	
	ENDIF 

RETU NIL

METHOD Cgi( cKey ) CLASS TRequest

	LOCAL uValue := ''
	
	__defaultNIL( @cKey, '' )		
	
	uValue := AP_GetEnv( cKey )

RETU uValue

METHOD GetUrlFriendly() CLASS TRequest

	LOCAL cUrlQuery 		:= ::GetQuery()
	LOCAL cUrlFriendly 	:= ''
	LOCAL nPos 			:= At( '?', cUrlQuery )
	
	//	Si existe un ? en la posicion 1 y nada mas, lo dejaremos....
	
	IF ( nPos > 0 )
		IF nPos == 1 .AND. Len( cUrlQuery ) == 1
			cUrlFriendly := cUrlQuery
		ELSE
			cUrlFriendly := Substr( cUrlQuery, 1, nPos-1 )
		ENDIF
		
	ELSE
		cUrlFriendly := cUrlQuery
		
	ENDIF	

RETU cUrlFriendly

METHOD GetQuery() CLASS TRequest

	LOCAL cPath, n, cQuery

	cPath := _cFilePath( ::Cgi( 'SCRIPT_NAME' ) )
	
	//LOG 'GetQuery() Path: ' + cPath
	
	n := At( cPath, ::Cgi( 'REQUEST_URI' ) )
	
	cQuery := Substr( ::Cgi( 'REQUEST_URI' ), n + len( cPath ) ) 
	
	IF ( len(cQuery ) == 0 )
		cQuery := '/'
	ENDIF

RETU cQuery

METHOD LoadHeaders() CLASS TRequest
	LOCAL nLen := AP_HeadersInCount() - 1 
	LOCAL n, nJ, cKey, cPart, uValue
	
	::hHeaders := {=>}	
	::hCookies := {=>}

	FOR n = 0 to nLen
	
		cKey 	:= AP_HeadersInKey( n )
		uValue 	:= AP_HeadersInVal( n )				
		
		::hHeaders[ cKey ] := uValue
		
		//	Si una de las cabeceras es una Cookie, la cargamos ya en una variable
		//	La cabecera Cookie, puede tener varias cookies, separadas por un ;
		
		IF ( lower(cKey) == 'cookie' )
		
			FOR EACH cPart IN hb_ATokens( uValue, ";" )				
		
				IF ( nJ := At( "=", cPart ) ) > 0
				
					IF ( !empty( cKey := Alltrim(Left( cPart, nJ - 1 )) ) )
						::hCookies[ cKey ] := Alltrim(SubStr( cPart, nJ + 1 ))
					ENDIF
					
				ELSE
				
					IF ( !empty( cKey := Alltrim(Left( cPart, nJ - 1 ))) )					
						::hCookies[ cKey ] :=  ''
					ENDIF
					
				ENDIF
				
				IF ( !empty( cKey ) )
					//LOG 'Load Cookie: ' + cKey + ' - ' + ::hCookies[ cKey ]
				ENDIF
		   
			NEXT		
		
		ENDIF		
		
	NEXT	

RETU NIL

//	SetCookie() en oResponse



static function _cFilePath( cFile )   // returns path of a filename

   //local lLinux := If( "Linux" $ OS(), .T., .F. )
   //local cSep := If( lLinux, "\", "/" )
   LOCAL cSep := '/'
   local n := RAt( cSep, cFile )

RETU Substr( cFile, 1, n )
