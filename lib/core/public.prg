#include "FileIO.ch"

//	------------------------------------------------------------
//	FUNCTION from Mindaugas code -> esshop
//	------------------------------------------------------------

FUNCTION UHtmlEncode(cString)

	LOCAL nI, cI, cRet := ""

	FOR nI := 1 TO LEN(cString)
		cI := SUBSTR(cString, nI, 1)

		IF cI == "<"
		  cRet += "&lt;"
		ELSEIF cI == ">"
		  cRet += "&gt;"
		ELSEIF cI == "&"
		  cRet += "&amp;"
		ELSEIF cI == '"'
		  cRet += "&quot;"
		ELSE
		  cRet += cI
		ENDIF	
		
	NEXT
	
RETURN cRet

function _l( uValue )

	local cFileName 		:= hb_getenv( 'PRGPATH' ) + '/log.txt'
    local hFile, cLine 	:= DToC( Date() ) + " " + Time() + " " + valtype( uValue) + ": ", n	
	
	
	if uValue == '_DEL' 
		ferase( cFilename )
		retu nil
	endif

	cLine += valtochar( uValue ) + Chr(13) + Chr(10)
	
/*
   for n = 1 to Len( uValue )
      cLine += ValToChar( uValue[ n ] ) + Chr( 9 )
   next
   
   cLine += Chr(13) +Chr(10)
*/


   if ! File( cFileName )
      FClose( FCreate( cFileName ) )
   endif

   if( ( hFile := FOpen( cFileName, FO_WRITE ) ) != -1 )
      FSeek( hFile, 0, FS_END )
      FWrite( hFile, cLine, Len( cLine ) )
      FClose( hFile )
   endif
   
retu nil   
