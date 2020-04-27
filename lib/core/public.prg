#include "FileIO.ch"
#include "common.ch"

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

	STATIC _l_file 		:= '/log.txt'
	
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

/*
FUNCTION _l( ... )

//	LOCAL cFileName 		:= IF ( HB_GETENV( 'LOG_FILE' ) == '',  hb_getenv( 'PRGPATH' ) + '/log.txt', HB_GETENV( 'LOG_FILE' ) )
	LOCAL cFileName 		:= hb_getenv( 'PRGPATH' ) + '/data/log.txt'
 	LOCAL cNow 				:= DToC( Date() ) + " " + Time() 
	LOCAL cInfo   			:= procname(1) + '(' +  ltrim(str(procline( 1 ))) + ')'	
	LOCAL nParam 			:= PCount()
	LOCAL cLine, cType, hFile, nI, uValue				

	//	Si no hay parámetros borramos el fichero 
	
		IF nParam == 0
			IF  fErase( cFilename ) == -1
				//	? 'Error eliminando ' + cFilename, fError()
			ENDIF
			RETU NIL		
		ENDIF
		
	//	Abrimos fichero log
	
		IF ! File( cFileName )
			IF fCreate( cFileName ) == -1 
				//	? 'Error creando ' + cFilename, fError()
			ELSE
				fClose( FCreate( cFileName ) )
			ENDIF
		ENDIF

		IF ( ( hFile := FOpen( cFileName, FO_WRITE ) ) == -1 )
			RETU NIL
		ENDIF
		
	//	Log	
	
		FOR nI := 1 TO nParam 
		
			uValue 	:= HB_PValue(nI)			
			cType 	:= ValType( uValue )	
			cLine  	:= cNow + ' ' + cInfo + ' ' + cType + ': ' + valtochar( uValue ) + Chr(13) + Chr(10)
			
			fSeek( hFile, 0, FS_END )
			fWrite( hFile, cLine, Len( cLine ) )		
			
		NEXT
	
	//	Close file log

		fClose( hFile )
   
RETU nil   
*/