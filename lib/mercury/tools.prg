//#define __LOG__

#ifdef __LOGOLD__
	#xcommand log <cText> => TLog( <cText> )	//	Tracear el sistema
#else
	#xcommand log <cText> =>
#endif

#define MERCURY_PATH 		'lib/'
#define FILELOG   			App():cFileLog


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





FUNCTION SetLogView()

	LOCAL n := GetLogView()
	
	n++

	MemoWrit( FILELOG, ltrim(str(n)) )	
	
RETU NIL

FUNCTION GetLogView() ; RETU Val(MemoRead( FILELOG ))

//	--------------------------------------------------------------------------------------

FUNCTION TLog( uValue, cTab ) 

	LOCAL cType 	:= ValType( uValue )
	LOCAL cLine 	:= ''
	LOCAL cPart, aKeys, cKey			
	__defaultNIL( @cTab , '' )

	cLine   := cTab + ' Line: ' +  ltrim(str(procline( 1 ))) +  ' Type Value: ' + cType	 
	//? cTab, 'Line: ' + cLine, cType	
	//QOut( )
	
	DO CASE
		CASE cType == 'C'			
			cLine += ' ' + uValue
		CASE cType == 'H'
		
			cLine += ' ' + 'Hash'
			
			aKeys := hb_HKeys( uValue )
			
			FOR EACH cKey IN aKeys
			
				cType := Valtype( uValue[ cKey ] )
				
				DO CASE
					CASE cType == 'H'
						cLine += ' ' +  cTab + ' ' + cKey + ' ' + '=> Hash'
						cTab := '--->'
						TLog( uValue[ cKey ], cTab )
					OTHERWISE
						cLine += ' ' + cTab + ' ' + cKey + ' => ' +  ValToChar(uValue[ cKey ])
				ENDCASE
			
			NEXT
										
		OTHERWISE
			cLine += ' ' + ValToChar( uValue )
	ENDCASE		

	QOut( cLine )

RETU NIL

//	From Fivewin.lib

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