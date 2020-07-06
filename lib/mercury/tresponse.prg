/*	-----------------------------------------------------------	
	TODAS las respuestas habrian de pasar por este método. 
	Básicamente podemos hacer un ? y esto genera una salida con 
	el AP_RPUTS, pero se ha de empezar a controlar el orden de 
	salida: código de error, cabeceras, validaciones de salida,
	si en un futuro	creamos un buffer per-salida...
	----------------------------------------------------------- */	

#define REDIRECTION  302

CLASS TResponse

   DATA aHeaders							INIT {}
   DATA cContentType						INIT 'text/plain'
   DATA cBody								INIT ''
   DATA nCode								INIT 200 
   DATA lRedirect							INIT .F.
   DATA cLocation							INIT ''
			
   METHOD New() 							CONSTRUCTOR
   METHOD Echo() 							//	print(), go(), exec(), out(), ...
   
   METHOD SetHeader( cHeader, uValue )
   
   METHOD SendCode( nCode )
   METHOD SendJson( uResult, nCode )
   METHOD SendXml ( uResult, nCode )
   METHOD SendHtml( uResult, nCode )
   
   METHOD Redirect( cUrl )
   
   METHOD SetCookie( cName, cValue, nSecs, cPath, cDomain, lHttps, lOnlyHttp )   

ENDCLASS

METHOD New() CLASS TResponse
	
	//	Por defecto dejamos activado el intercambio de Recursos de Origen Cruzado (CORS)
	
		::SetHeader( "Access-Control-Allow-Origin", "*" )

RETU Self

METHOD SetHeader( cHeader, cValue ) CLASS TResponse

	__defaultNIL( @cHeader, '' )
	__defaultNIL( @cValue, '' )
	
	Aadd( ::aHeaders, { cHeader, cValue } ) 

RETU NIL

METHOD SendJson( uResult, nCode, cCharset ) CLASS TResponse

	DEFAULT cCharSet  := 'ISO-8859-1'	//	'utf-8'

	::cContentType 	:= "application/json;charset=" + cCharSet	
	::cBody 			:= IF( HB_IsHash( uResult ) .or. HB_IsArray( uResult ), hb_jsonEncode( uResult ), '' )
	
	::echo()	

RETU NIL

METHOD SendXml( uResult, nCode, cCharset ) CLASS TResponse

	DEFAULT cCharSet  := 'ISO-8859-1'	//	'utf-8'
	
	::cContentType 	:= "text/xml;charset=" + cCharSet	
	::cBody 			:= IF( HB_IsString( uResult ), uResult, '' )
	
	::echo()	

RETU NIL

METHOD SendHtml( uResult, nCode ) CLASS TResponse
	
	::cContentType 	:= "text/html"
	::cBody 			:= IF( HB_IsString( uResult ), uResult, '' )
	
	::echo()

RETU NIL

METHOD Redirect( cUrl ) CLASS TResponse

	local cHtml := ''
	
	
		//	Tendriamos de decir al controller que cargue el nuevo
		
		//AP_HeadersOutSet( "Location", cUrl )		
	
		//ErrorLevel( REDIRECTION )	
		
		
		
		/*
		::SetHeader( "Location", cUrl )
		
		::nCode := REDIRECTION 
		
		::Echo()
		*/
		

	cHtml += '<script>'
	cHtml += "window.location.replace( '" + cUrl + "'); "
	cHtml += '</script>'

		
	::SendHtml( cHtml )									
	
RETU NIL

METHOD SendCode( nCode ) CLASS TResponse

	ErrorLevel( nCode )

RETU NIL 

METHOD Echo() CLASS TResponse

	LOCAL aHeader 

	//	La salida de retorno de la respuesta tendra 3 capas de envio:
	//	Errorlevel

	//	 No chuta. Pendiente de revisar
		
		IF ::nCode > 200
			ErrorLevel( ::nCode )
		ENDIF	
		
	//	Cabeceras

		FOR EACH aHeader IN ::aHeaders

			//	Si tenemos alguna cookie por enviar, la enviamos...					
			IF aHeader[1] == 'Set-Cookie'							
				AP_HeadersOutSet( "Set-Cookie", aHeader[2] )												
			ELSE
				AP_HeadersOutSet( aHeader[1], aHeader[2] )															
			ENDIF
			
		NEXT
		
	//	Set ContentType
		
		AP_SetContentType( ::cContentType )		
		
	//	Sino salida del Body...

		AP_RPUTS( ::cBody )								

RETU NIL

//	El método GetCookie estará en el oRequest

METHOD SetCookie( cName, cValue, nSecs, cPath, cDomain, lHttps, lOnlyHttp ) CLASS TResponse

	LOCAL cCookie := ''

		__defaultNIL( @cName		, '' )
		__defaultNIL( @cValue		, '' )
		__defaultNIL( @nSecs		, 3600 )		//	
		__defaultNIL( @cPath		, '/' )
		__defaultNIL( @cDomain	, '' )
		__defaultNIL( @lHttps		, .F. )
		__defaultNIL( @lOnlyHttp	, .F. )
	
	//	Validacion de parámetros
	
	
	//	Montamos la cookie
	
		cCookie += cName + '=' + cValue + ';'
		cCookie += 'expires=' + CookieExpire( nSecs ) + ';'
		cCookie += 'path=' + cPath + ';'
		cCookie += 'domain=' + cDomain + ';'
		

	//	Pendiente valores logicos de https y OnlyHttp

	//	Envio de la Cookie

		//AP_HeadersOutSet( "Set-Cookie", cCookie )
		::SetHeader( "Set-Cookie", cCookie )
	

RETU NIL


//	CookieExpire( nSecs ) Creará el formato de tiempo para la cookie
	
//		Este formato sera: 'Sun, 09 Jun 2019 16:14:00'
static function CookieExpire( nSecs )
    LOCAL tNow		:= hb_datetime()	
	LOCAL tExpire							//	TimeStampp 
	LOCAL cExpire 						//	TimeStamp to String

	
	__defaultNIL( @nSecs, 3600 )
   
    tExpire 	:= hb_ntot( (hb_tton(tNow) * 86400 - hb_utcoffset() + nSecs ) / 86400)

    cExpire 	:= cdow( tExpire ) + ', ' 
	cExpire 	+= alltrim(str(day( hb_TtoD( tExpire )))) + ' ' + cmonth( tExpire ) + ' ' + alltrim(str(year( hb_TtoD( tExpire )))) + ' ' 
    cExpire 	+= alltrim(str( hb_Hour( tExpire ))) + ':' + alltrim(str(hb_Minute( tExpire ))) + ':' + alltrim(str(hb_Sec( tExpire )))

return cExpire
