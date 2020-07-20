


function MercuryInclude( cPath )

	local cFile, oError

	DEFAULT cPath := MERCURY_PATH
	
	IF Right( cPath, 1 ) != '/'
		cPath += '/'
	ENDIF
	
	cFile := HB_GetEnv( "PRGPATH" ) + '/' + cPath + 'mercury.ch'
	
	if ! File( cFile )
		oError := ErrorNew()
		oError:Subsystem   := "System"
		oError:Severity    := 2	//	ES_ERROR
		oError:Description := "MercuryInclude() File not found: " + cFile 
		Eval( ErrorBlock(), oError)
   endif

	//	RETU '#include "' + cFile + '"'
	
RETU '"' + cFile + '"'

//	------------------------------------------------------------
//	FUNCTION from Mindaugas code -> esshop
//	------------------------------------------------------------

FUNCTION UHtmlEncode(cString)

   local cChar, cRet := "" 

   for each cChar in cString
		do case
			case cChar == "<"	; cChar := "&lt;"
			case cChar == '>'	; cChar := "&gt;"     				
			case cChar == "&"	; cChar := "&amp;"     
			case cChar == '"'	; cChar := "&quot;" 
			case cChar == "'"	; cChar := "&apos;"   			          
		endcase
		
		cRet += cChar 
   next
	
RETURN cRet

FUNCTION _l( uValue, cFile )

	thread STATIC _l_file 		:= '/log.txt'
	
//	LOCAL cFileName 		:= IF ( HB_GETENV( 'LOG_FILE' ) == '',  hb_getenv( 'PRGPATH' ) + '/log.txt', HB_GETENV( 'LOG_FILE' ) )
	LOCAL cFileName 		
 	LOCAL cNow 			:= DToC( Date() ) + " " + Time() 
	LOCAL cInfo   			:= procname(1) + '(' +  ltrim(str(procline( 1 ))) + ')'	
	LOCAL nParam 			:= PCount()
	LOCAL cLine, cType, hFile, nI			
	
	IF valtype( cFile ) == 'C'
		_l_file := cFile	
	ENDIF
	
	cFileName := hb_getenv( 'PRGPATH' ) + _l_file
	

	//	Si no hay parámetros borramos el fichero 
	
		IF nParam == 0
			IF  fErase( cFilename ) == -1
				//	? 'Error eliminando ' + cFilename, fError()
			ENDIF
			RETU NIL		
		ENDIF
		
	//	Abrimos fichero log
	
		IF ! File( cFileName )
			fClose( FCreate( cFileName ) )	
		ENDIF

		IF ( ( hFile := FOpen( cFileName, FO_WRITE ) ) == -1 )
			RETU NIL
		ENDIF
		
	//	Log	
	
		cLine  	:= cNow + ' ' + cInfo + ': ' + valtochar( uValue ) + Chr(13) + Chr(10)
			
		fSeek( hFile, 0, FS_END )
		fWrite( hFile, cLine, Len( cLine ) )		
	
	//	Close file log

		fClose( hFile )
   
RETU nil 

//	-------------------------------------------------------	//
//	From Fivewin.lib
//	-------------------------------------------------------	//

function cFileNoExt( cPathMask ) // returns the filename without ext

   local cName := AllTrim( cFileNoPath( cPathMask ) )
   local n     := RAt( ".", cName )

return AllTrim( If( n > 0, Left( cName, n - 1 ), cName ) )


function cFileNoPath( cPathMask )  // returns just the filename no path

    local n := RAt( "/", cPathMask )

return If( n > 0 .and. n < Len( cPathMask ),;
           Right( cPathMask, Len( cPathMask ) - n ),;
           If( ( n := At( ":", cPathMask ) ) > 0,;
           Right( cPathMask, Len( cPathMask ) - n ),;
           cPathMask ) )