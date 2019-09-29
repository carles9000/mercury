#include 'mercury.ch'

FUNCTION App()
	
	STATIC oApp
	
	IF oApp == NIL
		oApp := TApp():New()
	ENDIF

RETU oApp

CLASS TApp
	
   DATA oRequest					
   DATA oResponse				
   DATA oRoute					
   DATA oMiddleware
   DATA oData
   DATA lShowError							INIT .T.
   DATA cLastView							INIT ''
   
   //DATA bError							INIT {|cError, cTitle| ::ShowError( cError, cTitle ) }							
   
   //CLASSDATA cPath							INIT AP_GETENV( 'PATH_APP' )
   CLASSDATA cPath							INIT AP_GETENV( 'DOCUMENT_ROOT' ) + AP_GETENV( 'PATH_APP' )
   CLASSDATA cUrl							INIT AP_GETENV( 'PATH_URL' )
   CLASSDATA cPathCss						INIT '/css/'
   CLASSDATA cPathView						INIT '/src/view/'
   CLASSDATA cPathController				INIT '/src/controller/'
   CLASSDATA cPathModel					INIT '/src/model/'
   CLASSDATA cPathData						INIT AP_GETENV( 'DOCUMENT_ROOT' ) + AP_GETENV( 'PATH_DATA' )
   CLASSDATA cTitle							INIT AP_GETENV( 'APP_TITLE' )
   CLASSDATA cFileLog						INIT AP_GETENV( 'DOCUMENT_ROOT' ) + AP_GETENV( 'PATH_DATA' ) + '/logview.txt'
   CLASSDATA lLog							INIT .F.
   CLASSDATA aLog							INIT {}							
   CLASSDATA aSys							INIT {=>}							


   METHOD New() CONSTRUCTOR

   METHOD Version() 							INLINE MVC_VERSION
   METHOD Path() 								INLINE ::cPath
   METHOD Url() 								INLINE ::cUrl
   METHOD Route() 								
   METHOD Init() 
   METHOD Config() 
   METHOD ListApp() 
   
   METHOD Set( cKey, uValue ) 					INLINE ::oData:Set( cKey, uValue )	
   METHOD Get( cKey, uKey )						INLINE ::oData:Get( cKey, uKey  )	
   METHOD GetAll()								INLINE ::oData:GetAll()	
   
   METHOD ShowError( cError, cTitle )		   
   //METHOD Error( cError, cTitle )			INLINE Eval( ::bError, cError, cTitle )
   
   
   
ENDCLASS

METHOD New() CLASS TApp

	::oRequest 	:= TRequest():New()	
	::oResponse 	:= TResponse():New()	
	::oMiddleware 	:= TMiddleware():New()	
	::oRoute 		:= TRoute():New( SELF )
	::oData 		:= TData():New()	

	//	Chequeamos que se ha cargado las variables del .htaccess
	
		IF empty( AP_GETENV( 'PATH_APP' ) ) 
		
			::cPath					:= HB_GETENV( 'PRGPATH' ) 			//	AP_GETENV( 'DOCUMENT_ROOT' ) + AP_GETENV( 'PATH_APP' )				
		
		ENDIF
	


RETU Self


METHOD Init() CLASS TApp


	::Config()	
	
	::aSys[ 'time_init' ]	:= hb_milliseconds()	

	::oRoute:Listen()


RETU NIL

METHOD Config() CLASS TApp

	SET DATE TO ITALIAN	

RETU NIL

METHOD ShowError( cError, cTitle ) CLASS TApp

	if !::lShowError 
		retu nil
	endif
	
	__defaultNIL( @cError, '' )
	__defaultNIL( @cTitle, 'Error' )	
	
	?? '<meta charset="utf-8" />' 
	
	?? '<h3>' + cTitle + '<hr></h3>'
	
	?? '<h4>' + cError + '</h3><hr>'


RETU NIL

METHOD Route( cRoute, aParams ) CLASS TApp

	LOCAL aRoute
	LOCAL aDefParams, nDefParams, cDefParam
	LOCAL cUrl 	:= ''
	LOCAL aMap 	:= ::oRoute:aMap
	LOCAL lError 	:= .F.
	LOCAL lFound	:= .F.
	LOCAL hError 	:= {=>}
	LOCAL cError 	:= ''
	LOCAL nI
	
	__defaultNIL( @cRoute, '' )
	__defaultNIL( @aParams, {=>} )
	
	FOR EACH aRoute IN aMap
	
		IF aRoute[ MAP_ID ] == cRoute
		
			lFound := .T.
		
			//	URL Base
			
				IF aRoute[ MAP_QUERY ] <> '/' 	//	Default page		
					cUrl := ::cUrl + '/' + aRoute[ MAP_QUERY ]
				ELSE
					cUrl := ::cUrl + '/' 
				ENDIF
	
			// 	Cuantos parámetros tiene la Ruta
			
				aDefParams := aRoute[ MAP_PARAMS ]
				nDefParams := len( aParams )									
				
			// 	Si los parámetros definidos == parametros recibidos -> OK
			
				IF nDefParams == len( aParams )
				
						FOR nI := 1 TO nDefParams

							cDefParam := aDefParams[nI]
							
							IF HB_HHasKey( aParams, cDefParam )

								cUrl += '/'
								cUrl += ValToChar( aParams[ cDefParam ] ) 								
								
							ELSE	
							
								//	Generamos ERROR ?	=> Yo diria que si
								
								lError 				:= .T.
								/*
								hError[ 'id' ]		    := cRoute
								hError[ 'define' ]		:= aRoute[ MAP_ROUTE ]
								hError[ 'descripcion' ]:= 'Parámetro definido<strong> ' + cDefParam + ' </strong>no existe'
								*/
								
								cError := aRoute[ MAP_ROUTE ] + ' => ' +  'Parámetro definido<strong> ' + cDefParam + ' </strong>no existe'
							
							ENDIF						
						
						NEXT				
				
				ENDIF
				
			//	Salir...
				exit
			
	
		ENDIF
		
	NEXT	
	
	//	Si NO tenemos ningun error devolvemos la URL
	
		IF lFound .AND. !lError			
			RETU cUrl
		ELSEIF !lFound .AND. lError

			::ShowError( cError, 'Error TRoute => ' + App():cLastView )
		ELSE 
		
			cError := 'Route ' + cRoute + " doesn't exist !"
			::ShowError( cError, 'Error TRoute => ' + App():cLastView )			
		ENDIF		
	
RETU ''

METHOD ListApp() CLASS TApp

	LOCAl cHtml

	cHtml := '<h3>ListApp()</h3>'
	cHtml += '<table border="1" style="font-weight:bold;">'
	cHtml += '<thead ><tr><td>Description</td><td>Value</td></tr></thead>'
	
	cHtml += '<tbody>'
	
	cHtml += '<tr><td>Version()</td><td>'			+ ::Version() + '</td>'
	cHtml += '<tr><td>cPath</td><td>' 				+ ::cPath + '</td>'
	cHtml += '<tr><td>cPathController</td><td>' 	+ ::cPathController + '</td>'
	cHtml += '<tr><td>cPathModel</td><td>' 		+ ::cPathModel + '</td>'
	cHtml += '<tr><td>cPathView</td><td>' 			+ ::cPathView + '</td>'
	cHtml += '<tr><td>cPathData</td><td>' 			+ ::cPathData + '</td>'	
	
	cHtml += '</tbody></table></pre><hr>'
	
	? cHtml

RETU ''

exit procedure App_End()

	LOCAL o 		:= TApp():New()
	LOCAL nTotal, nI
	
	IF o:lLog
	
		nTotal := len( o:aLog )
		//o:aLog[ 'time_end' ] := hb_milliseconds()
	
		//? '<h2>Log del sistema (' + o:cTitle + ')<hr></h2>'
		? '<h2>Log del sistema<hr></h2>'
		?? '<pre>'
		
		FOR nI := 1 TO nTotal 
			? o:aLog[nI] 
		NEXT
		
		?? '</pre>'
		
		o:aLog := array()
		o:lLog := .F.
	ENDIF

RETU 