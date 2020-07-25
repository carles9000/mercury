//	-----------------------------------------------------------------------------------------
//	FUNCIONES en apache.prg. Se intenta optimizarlas sin tener que tocar el core apache
//	Si se consiguen optimizar y estabilizar, se acoplaran y/o reemplazaran las que ya 
//	tenemos....
//	-----------------------------------------------------------------------------------------


FUNCTION zReplaceBlocks( cCode, cStartBlock, cEndBlock, oInfo, ... )

    LOCAL bErrorHandler 	:= {|oError| GetErrorInfo( oError, cCode, oInfo ), Break(oError) }  
	LOCAL bLastHandler 		:= ErrorBlock(bErrorHandler)
	LOCAL lReplaced 		:= .F.
	LOCAL nStart, nEnd, cBlock
	LOCAL uValue, bBloc 	
	LOCAL cCodeA, cCodeB
	LOCAL hPP
   
	hb_default( @cStartBlock, "{{" )
	hb_default( @cEndBlock, "}}" )
	hb_default( @oInfo, {=>} )

	oInfo[ 'block' ] := 0    
	
    hPP := __pp_init()
	__pp_addRule( hPP, "#xcommand PARAM <nParam> => AP_Get( IF( valtype( pvalue(<nParam>) ) <> 'U', pvalue(<nParam>), '' ) )" )
	__pp_addRule( hPP, "#xcommand PARAM <nParam>,<uIndex> => AP_Get( hb_pvalue(<nParam>),<uIndex> )" )
    __pp_addRule( hPP, "#xcommand DEFAULT <v1> TO <x1> [, <vn> TO <xn> ] => ;" + ;
                      "IF <v1> == NIL ; <v1> := <x1> ; END [; IF <vn> == NIL ; <vn> := <xn> ; END ]" )	
					  
					  
	WHILE ( nStart := At( cStartBlock, cCode ) ) != 0 .and. ;
          ( nEnd := At( cEndBlock, cCode ) ) != 0		 
		 
		oInfo[ 'block' ]++		 
		 
		cCodeA := SubStr( cCode, 1, nStart - 1 ) 
		cCodeB := SubStr( cCode, nEnd + Len( cEndBlock ) )

		cBlock := SubStr( cCode, nStart + Len( cStartBlock ), nEnd - nStart - Len( cEndBlock ) )
		cBlock := alltrim(cBlock)
		uValue := ''
		
		oInfo[ 'code' ] := cBlock

	    IF !empty( cBlock )
		  
			cBlock := __pp_process( hPP, cBlock )


			bBloc  := &( '{|...| '  + cBlock + ' }' )
			uValue := Eval( bBloc, ... )

			IF Valtype( uValue ) <> 	'C'

				uValue := ValToChar( uValue )

			ENDIF	 

	    ENDIF
	  
		cCode  := cCodeA + uValue + cCodeB
		lReplaced := .T.
    end
  
	oInfo[ 'code' ] := cCode
   
    ErrorBlock(bLastHandler) // Restore handler    

RETU If( HB_PIsByRef( 1 ), lReplaced, cCode )


FUNCTION AP_Get( uValue, uInd )

	LOCAL cTypeValue	:= Valtype( uValue )
	LOCAL cType 		:= ValType( uInd )

	DO CASE
	
		CASE cTypeValue == 'C'
			
		CASE cTypeValue == 'A'
		
			IF cType == 'N'
				uValue := uValue[ uInd ]
			ELSE
				uValue := ValToChar( uValue )
			ENDIF
		
		CASE cTypeValue == 'H'
	
			IF cType == 'C' .AND. hb_HHasKey( uValue, uInd )
				uValue := uValue[ uInd ]	
			ELSE
				uValue := 'Hash value'
			ENDIF
			
		CASE cTypeValue == 'U'
		
			uValue := ''
			
		
	ENDCASE		

RETU valtochar( uValue )




FUNCTION zInlinePRG( cText, oInfo, ... )


	LOCAl BlocA, BlocB
	LOCAL nStart, nEnd, cCode, cResult

	
	DEFAULT oInfo TO {=>}

	oInfo[ 'block' ] := 0  	
	
	WHILE ( nStart := At( "<?prg", cText ) ) != 0
	
		oInfo[ 'block' ]++
	
		nEnd  := At( "?>", SubStr( cText, nStart + 5 ) )
	  
		BlocA := SubStr( cText, 1, nStart - 1 )
		BlocB := SubStr( cText, nStart + nEnd + 6 )
		cCode := SubStr( cText, nStart + 5, nEnd - 1 )

		oInfo[ 'code' ] := cCode 
	  
		cResult := zExecInline( cCode, oInfo, ... ) 
		
		IF Valtype( cResult ) <> 'C' 
			DoError( "Don't return string", oInfo, 'Prg Block' )
			retu ''		//	No podemos usar QUIT 
		ENDIF
		
		cText 	:= BlocA + cResult + BlocB              
 
	END
   
RETU cText


FUNCTION zExecInline( cCode, oInfo, ... )

RETU zExecute( "function __Inline()" + HB_OsNewLine() + cCode, oInfo, ... )



FUNCTION zExecute( cCode, oInfo, ... )

	STATIC hPP
	
    LOCAL oHrb, uRet
    local cHBheaders1 := "~/harbour/include"
    LOCAL cHBheaders2 
	LOCAL bErrorHandler 	:= {|oError| GetErrorInfo( oError, @cCode, oInfo ), Break(oError) } 
	LOCAL bLastHandler 		:= ErrorBlock(bErrorHandler)

	
	__hCargo[ '__oInfo' ] :=  oInfo 	//	Usado en zBlocks para conocer la file

	
	//	Si no funciona htacces...
	IF empty( AP_GETENV( 'PATH_APP' ) )
		cHBheaders2 := HB_GETENV( 'PRGPATH' ) + "/include"	
	ELSE
		cHBheaders2 := AP_GETENV( 'DOCUMENT_ROOT' ) + AP_GETENV( 'PATH_APP' ) + "/include"	//	"c:\harbour\include"
	ENDIF

	IF hPP == NIL

		hPP := __pp_init()
		__pp_path( hPP, "~/harbour/include" )
		__pp_path( hPP, cHBheaders2 )
		IF ! Empty( hb_GetEnv( "HB_INCLUDE" ) )
		 __pp_path( hPP, hb_GetEnv( "HB_INCLUDE" ) )
		ENDIF 	 

		__pp_addRule( hPP, "#xcommand ? [<explist,...>] => AP_RPuts( '<br>' [,<explist>] )" )
		__pp_addRule( hPP, "#xcommand ?? [<explist,...>] => AP_RPuts( [<explist>] )" )
		__pp_addRule( hPP, "#define CRLF hb_OsNewLine()" )
		__pp_addRule( hPP, "#xcommand TEMPLATE [ USING <x> ] [ PARAMS [<v1>] [,<vn>] ] => " + ;
						  '#pragma __cstream | AP_RPuts( InlinePrg( %s, [@<x>] [,<(v1)>][+","+<(vn)>] [, @<v1>][, @<vn>] ) )' )
		__pp_addRule( hPP, "#xcommand BLOCKS => " + ;
						  '#pragma __cstream | AP_RPuts( ReplaceBlocks( %s, "{{", "}}" ) )' )
		__pp_addRule( hPP, "#command ENDTEMPLATE => #pragma __endtext" )		
		__pp_addRule( hPP, "#xcommand DEFAULT <v1> TO <x1> [, <vn> TO <xn> ] => ;" + ;
                      "IF <v1> == NIL ; <v1> := <x1> ; END [; IF <vn> == NIL ; <vn> := <xn> ; END ]" )
					  
		__pp_addRule( hPP, "#xcommand PARAM <nParam> => AP_Get( IF( valtype( pvalue(<nParam>) ) <> 'U', pvalue(<nParam>), '' ) )" )
		__pp_addRule( hPP, "#xcommand PARAM <nParam>,<uIndex> => AP_Get( hb_pvalue(<nParam>),<uIndex> )" )					  
		__pp_addRule( hPP, "#xcommand TEXT <into:TO,INTO> <v> => #pragma __cstream|<v>:=%s" )					  
		
		
		//__pp_addRule( hPP, "#xcommand OLDBLOCKS VIEW <v>[ PARAMS [<v1>] [,<vn>] ] => " + ;
		//			"#pragma __cstream |<v>+= InlinePrg( ReplaceBlocks( %s, '<$', '$>' [,<(v1)>][+','+<(vn)>] [, @<v1>][, @<vn>] ) )" )

		__pp_addRule( hPP, "#xcommand BLOCKS VIEW <v>[ PARAMS [<v1>] [,<vn>] ] => " + ;
					"#pragma __cstream |<v>+= zBlocks( %s [,<(v1)>][+','+<(vn)>] [, @<v1>][, @<vn>] )" )					
							
	
	
	ENDIF

	
	cCode = __pp_process( hPP, cCode )

	

    oHrb = HB_CompileFromBuf( cCode, .T., "-n", "-I" + cHBheaders1, "-I" + cHBheaders2,;
                              "-I" + hb_GetEnv( "HB_INCLUDE" ), hb_GetEnv( "HB_USER_PRGFLAGS" ) )   

    IF ! Empty( oHrb )
       uRet = hb_HrbDo( hb_HrbLoad( oHrb ), ... )
    ENDIF		   
   
RETU uRet

//	Load file form document_root + PATH_APP


FUNCTION zInclude( cFile ) 

   local cPath 		:= AP_GetEnv( "DOCUMENT_ROOT" ) 
   local cPath_App 	:= AP_GetEnv( "PATH_APP" ) 
   local oError 

   hb_default( @cFile, '' )
   cFile = cPath + cPath_App + cFile   
   
   if "Linux" $ OS()
      cFile = StrTran( cFile, '\', '/' )     
   endif   
    
   if File( cFile )
      return MemoRead( cFile )
	else

		oError := ErrorNew()
		oError:Subsystem   := "System"
		oError:Severity    := 2	//	ES_ERROR
		oError:Description := "Include() File not found: " + cFile 
		Eval( ErrorBlock(), oError)
   endif

RETU ''

//	zInclude() no queda bonita en el prg. Crearemos LoadFile()

/*	-----------------------------------------------------------------------
	En el modulo de Diego si p.e. tenemos la directiva 
		#ifndef _CONTENTMODEL_CH
		#define _CONTENTMODEL_CH
			...
		#endif
		
	No hace caso a partir de la 2 vez, es decir mantiene en memoria que ya se habia
	cargado, pero al tratarse de otra request no carga el contenido y por consecuencia
	no carga el symbolo del fichero.
	
	Ahora lo q hacemos es q al iniciarse App() se crea una thread static __hFiles en 
	la q ire poniendo los ficheros que se cargan, de tal manera q si esta cargado no
	lo vuelvo a cargar, emulando  asi estas directivas...
	
	Creo q lo suyo habria de ser a cada request vaciar de memoria #ifdef 
--------------------------------------------------------------------------- */	

FUNCTION LoadFile( cFile ) 

   local cPath 		:= AP_GetEnv( "DOCUMENT_ROOT" ) 
   local cPath_App 	:= AP_GetEnv( "PATH_APP" ) 
   local oError 
   
   hb_default( @cFile, '' )
   
    if HB_HPos( __hFiles, cFile ) > 0
		retu ''
	endif
	
	__hFiles[ cFile ] := .t.		

   cFile = cPath + cPath_App + cFile   
   
   if "Linux" $ OS()
      cFile = StrTran( cFile, '\', '/' )     
   endif   
    
   if File( cFile )
      return MemoRead( cFile )
	else

		oError := ErrorNew()
		oError:Subsystem   := "System"
		oError:Severity    := 2	//	ES_ERROR
		oError:Description := "LoadFile() File not found: " + cFile 
		Eval( ErrorBlock(), oError)
   endif

RETU ''


function LoadInclude( cPathPluggin )
RETU '"' + AP_GetEnv( "DOCUMENT_ROOT" ) + AP_GetEnv( "PATH_APP" ) + cPathPluggin

FUNCTION VersionPreApache(); RETU  'v0.1'

//--------------------------------------------------------------

function ZAP_PostPairs( lUrlDecode )	//	Prototype

    local cPair, uPair, hPairs := {=>}
	local nTable, aTable, cKey, cTag	
	
	__defaultNIL( @lUrlDecode, .T. )
	
	cTag := if( lUrlDecode, '[]', '%5B%5D' )

    for each cPair in hb_ATokens( AP_Body(), "&" )
	
	//	Podriamos decodificar con hb_UrlDecode(), pero hasta ahora
	//	era una opcion del programador de si querer o no usarla...	
	
		if lUrlDecode
			cPair := hb_urldecode( cPair )
		endif				
		
	//	----------------------------------------------------------
	
      if ( uPair := At( "=", cPair ) ) > 0	  
			cKey := Left( cPair, uPair - 1 )	
			
			if ( nTable := At( cTag, cKey ) ) > 0 		
			
				cKey 	:= Left( cKey, nTable - 1 )			
				aTable 	:= HB_HGetDef( hPairs, cKey, {} ) 				
				Aadd( aTable, SubStr( cPair, uPair + 1 ) )				
				hPairs[ cKey ] := aTable
			else						
				hb_HSet( hPairs, cKey, SubStr( cPair, uPair + 1 ) )
			endif
      endif
    next

return hPairs

//--------------------------------------------------------------

function ZAP_GetPairs( lUrlDecode )	//	Prototype

	local cArgs 	:= AP_Args()	//	FastCgi -> mh_query()
    local hPairs 	:= {=>}
    local cPair, uPair, nPos, cKey, uValue
	
	__defaultNIL( @lUrlDecode, .T. )	
	
	FOR EACH cPair IN hb_ATokens( cArgs, "&" )
	
		if lUrlDecode
			cPair := hb_urldecode( cPair )
		endif		
	
		IF ( uPair := At( "=", cPair ) ) > 0
		
			cKey := Left( cPair, uPair - 1 )			

			//	Chequeamos si existe la key en nuestro hPairs
			
			if ( nPos := HB_HPos( hPairs, cKey ) ) == 0
		
				hb_HSet( hPairs, cKey, SubStr( cPair, uPair + 1 ) )
			else			

				if valtype( hPairs[ cKey ] ) <> 'A'
				
					uValue 			:= hPairs[ cKey ] 				
					hPairs[ cKey ] 	:= {}
					Aadd( hPairs[ cKey ], uValue )
					
				endif
				
				Aadd( hPairs[ cKey ], SubStr( cPair, uPair + 1 ) )
				
			endif				
			
		else
			HB_HSet( hPairs, lower(cPair), '' )
		endif
	   
	next


return hPairs

//----------------------------------------------------------------//







//----------------------------------------------------------------//

function zBlocks( cCode, cParams, ... )

	local cText 	
	local oInfo	:= __hCargo[ '__oInfo' ]
	
	cText := yReplaceBlocks( cCode, oInfo,  cParams, ... )
	
	cText := yInlinePRG( cText, oInfo )

retu cText

function yReplaceBlocks( cCode, oInfo, cParams, ... )

   local nStart, nEnd, cBlock
   local cStartBlock := "<$"
   local cEndBlock 	:= "$>"

   hb_default( @cParams, "" )

   while ( nStart := At( cStartBlock, cCode ) ) != 0 .and. ;
         ( nEnd := At( cEndBlock, cCode ) ) != 0
		 
      cBlock := SubStr( cCode, nStart + Len( cStartBlock ), nEnd - nStart - Len( cEndBlock ) )
      cCode  := SubStr( cCode, 1, nStart - 1 ) + ;
                ValToChar( Eval( &( "{ |" + cParams + "| " + cBlock + " }" ), ... ) ) + ;
      SubStr( cCode, nEnd + Len( cEndBlock ) )
          
   end
   
return cCode 

//----------------------------------------------------------------//

function yInlinePRG( cText, oInfo )

   local nStart, nEnd, cCode, cResult
   

   while ( nStart := At( "<?prg", cText ) ) != 0
   
      nEnd  := At( "?>", SubStr( cText, nStart + 5 ) )
      cCode := SubStr( cText, nStart + 5, nEnd - 1 )

      cText := SubStr( cText, 1, nStart - 1 ) + ( cResult := zExecInline( cCode, oInfo ) ) + ;
               SubStr( cText, nStart + nEnd + 6 )

   end 
   
return cText

//----------------------------------------------------------------//