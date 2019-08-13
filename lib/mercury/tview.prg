/*	----------------------------------------------------------------------------------
	Sistema de Vistas.
	
	Hay incorporado todas las funciones de apache.prg de compilado de código para 
	poder optimizar el sistema sin necesidad de recompilar el core.
	
	De cualquier manera, solo se usaran en este módulo por lo que no interfiriran 
	en otro lugar
	---------------------------------------------------------------------------------- */

CLASS TView

	DATA oRoute				INIT ''	
	DATA oResponse			INIT ''	
	
	METHOD New() CONSTRUCTOR	

	METHOD Load( cFile ) 
	METHOD Exec( cFile, ... ) 
	
ENDCLASS 

METHOD New() CLASS TView

	::oResponse := TResponse():New()
		
RETU Self


METHOD Load( cFile ) CLASS TView

	//	Por defecto la carpeta de los views estaran en src/view

	LOCAL cPath 		:= App():cPath + App():cPathView
	LOCAL cCode 		:= ''
	LOCAL cProg

	__defaultNIL( @cFile, '' )
	
	cProg 				:= cPath + cFile
	
	LOG 'View: ' + cProg
	LOG 'Existe fichero? : ' + ValToChar(file( cProg ))
	
	IF File ( cProg )
	
		cCode := MemoRead( cProg )
		
	ELSE
	
		LOG 'Error: No existe Vista: ' + cFile 		
			
		App():ShowError( 'No existe Vista: ' +  cFile,  'TView Error!' )						
	
	ENDIF				

RETU cCode

METHOD Exec( cFile, ... ) CLASS TView

	LOCAL o 		:= ''		
	LOCAL cHtml	:= ''		
	LOCAL cCode  	:= ::Load( cFile )
	LOCAL oInfo 	:= { => }
	LOCAL oExecute 

	IF !empty( cCode )
	
		oInfo := {=>}
		oInfo[ 'file' ] := cFile 
		
		zReplaceBlocks( @cCode, '{{', '}}', oInfo, ... )
		
		oInfo := {=>}
		oInfo[ 'file' ] := cFile 
		
		LOG '<b>CODE Replaced</b><br>'		
	
		//	AP_RPuts( zInlinePrg( cCode, oInfo,... ) )	
		
		//	La salida siempre la habr de hacer el objeto oResponse
		
			cHtml := zInlinePrg( cCode, oInfo,... ) 		
		
			::oResponse:SendHtml( cHtml )		
	
	ELSE
	
	
	ENDIF				

RETU ''


//	-----------------------------------------------------------	//
//	Funcion para usar en los views...
//	-----------------------------------------------------------	//

FUNCTION View( cFile, ... )

	LOCAL cCode := ''
	LOCAL oView := TView():New()
	LOCAL oInfo := { => }
	LOCAL oExecute 
	
	oInfo[ 'file' ] := cFile
	
	App():cLastView := cFile 
	
	cCode := oView:Load( cFile )
	
	
	zReplaceBlocks( @cCode, '{{', '}}', oInfo, ... )					

RETU cCode
