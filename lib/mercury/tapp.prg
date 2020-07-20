

FUNCTION MercuryVersion() ; RETU MVC_VERSION 

FUNCTION App( cTitle, uInit , cPsw, cId_Cookie, nTime  )
	
	thread STATIC oApp
	
	IF oApp == NIL
		//oApp := TApp():New()
		oApp := TApp():New( cTitle, uInit , cPsw, cId_Cookie, nTime )
	ENDIF

RETU oApp

CLASS TApp
	
   DATA oRequest					
   DATA oResponse				
   DATA oRoute					
   DATA oMiddleware
   DATA oData
   DATA lShowError									INIT .T.
   DATA cLastView									INIT ''
		
		
   //DATA bError									INIT {|cError, cTitle| ::ShowError( cError, cTitle ) }							
    DATA bInit										INIT NIL							
    DATA cPsw										INIT ''
    DATA cId_Cookie								INIT ''
    DATA nTime										INIT 3600
		
   //CLASSDATA cPath									INIT AP_GETENV( 'PATH_APP' )
   CLASSDATA cPath									INIT AP_GETENV( 'DOCUMENT_ROOT' ) + AP_GETENV( 'PATH_APP' )
   CLASSDATA cUrl									INIT AP_GETENV( 'PATH_URL' )
   CLASSDATA cPathDev								INIT '/lib/'
   CLASSDATA cPathCss								INIT '/css/'
   CLASSDATA cPathJs								INIT '/js/'
   CLASSDATA cPathView								INIT '/src/view/'
   CLASSDATA cPathController						INIT '/src/controller/'
   CLASSDATA cPathModel							INIT '/src/model/'
   CLASSDATA cPathData								INIT AP_GETENV( 'DOCUMENT_ROOT' ) + AP_GETENV( 'PATH_DATA' )
   CLASSDATA cTitle									INIT AP_GETENV( 'APP_TITLE' )
   CLASSDATA cFileLog								INIT AP_GETENV( 'DOCUMENT_ROOT' ) + AP_GETENV( 'PATH_DATA' ) + '/logview.txt'
   CLASSDATA lLog									INIT .F.
   CLASSDATA aLog									INIT {}							
   CLASSDATA aSys									INIT {=>}							


   METHOD New() CONSTRUCTOR

   METHOD Version()								INLINE MVC_VERSION
   METHOD Path() 									INLINE ::cPath
   METHOD Url() 									INLINE ::cUrl
   METHOD UrlCss() 								INLINE ::cUrl + ::cPathCss
   METHOD UrlJs() 									INLINE ::cUrl + ::cPathJs
   METHOD UrlLib() 								INLINE ::cUrl + ::cPathDev
   METHOD Route() 								
   METHOD Init() 
   METHOD Config() 
   METHOD ListApp() 
   
   METHOD Set( cKey, uValue ) 					INLINE ::oData:Set( cKey, uValue )	
   METHOD Get( cKey, uKey )						INLINE ::oData:Get( cKey, uKey  )	
   METHOD GetAll()									INLINE ::oData:GetAll()	
   
   METHOD ShowError( cError, cTitle )		   
   //METHOD Error( cError, cTitle )			INLINE Eval( ::bError, cError, cTitle )
   
   
   
ENDCLASS

METHOD New( cTitle , bInit, cPsw, cId_Cookie, nTime ) CLASS TApp

	DEFAULT cPsw 		:= ''
	DEFAULT cId_Cookie 	:= ''
	DEFAULT nTime 		:= 3600

	::cTitle 		:= IF( valtype( cTitle ) == 'C', cTitle, AP_GETENV( 'APP_TITLE' ) )

	::oRequest 		:= TRequest():New()	
	::oResponse 	:= TResponse():New()	
	::oMiddleware 	:= TMiddleware():New()	
	::oRoute 		:= TRoute():New( SELF )
	::oData 		:= TData():New()	
	
	::bInit 		:= bInit
	::cPsw			:= cPsw
	::cId_Cookie	:= cId_Cookie
	::nTime			:= nTime
		

	//	Chequeamos que se ha cargado las variables del .htaccess
	
		IF empty( AP_GETENV( 'PATH_APP' ) ) 
		
			::cPath					:= HB_GETENV( 'PRGPATH' ) 			//	AP_GETENV( 'DOCUMENT_ROOT' ) + AP_GETENV( 'PATH_APP' )				
		
		ENDIF
		
		IF empty( AP_GETENV( 'PATH_URL' ) ) 
		
			::cUrl					:= App_Url()		
		
		ENDIF
		
	//	------------------------------------------------------------------------------------
	


RETU Self


METHOD Init() CLASS TApp

	LOCAL oThis := SELF  

	::Config()	
	
	::aSys[ 'time_init' ]	:= hb_milliseconds()
	
	//	Middleware. Si hemos entrado un psw, inicializaremos middleware
	
		if !empty( ::cPsw )		
			::oMiddleware:Credentials( 'jwt', ::cId_Cookie, ::cPsw, ::nTime )		
		endif		
	
	//	-----------------------------------------------------------------

	IF Valtype( ::bInit ) == 'B'
		Eval( ::bInit, oThis )
	ENDIF	

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

	MercuryError( cError, cTitle )

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
								hError[ 'id' ]		    	:= cRoute
								hError[ 'define' ]		:= aRoute[ MAP_ROUTE ]
								hError[ 'descripcion' ]	:= 'Parámetro definido<strong> ' + cDefParam + ' </strong>no existe'
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
	cHtml += '<tr><td>cPathCss</td><td>' 			+ ::cPathCss + '</td>'
	cHtml += '<tr><td>cPathJs</td><td>' 			+ ::cPathJs + '</td>'
	cHtml += '<tr><td>cPathController</td><td>' 	+ ::cPathController + '</td>'
	cHtml += '<tr><td>cPathModel</td><td>' 			+ ::cPathModel + '</td>'
	cHtml += '<tr><td>cPathView</td><td>' 			+ ::cPathView + '</td>'
	cHtml += '<tr><td>cPathData</td><td>' 			+ ::cPathData + '</td>'	
	
	cHtml += '</tbody></table></pre><hr>'
	
	? cHtml

RETU ''

exit procedure App_End()

	LOCAL o 		:= TApp():New()
	LOCAL nTotal, nI
	
	retu 
	
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

//	Function for Trace lapsus

function _t( cTrace, cAction )

	thread static nPos := 0
	
	local nLen := 0
	local cLog := ''
	local nI
	
	
	DEFAULT cTrace  := ''
	DEFAULT cAction := ''
	
	if nPos == 0
		Aadd( M->getList, array(1) )
		nPos := len(M->getList)
		M->getList[nPos] := {}
		Aadd( M->getList[nPos] , { 'init', HB_MILLISECONDS() } )
	endif
	
	if !empty( cTrace )
		Aadd( M->getList[nPos] , { cTrace, HB_MILLISECONDS() - M->getList[nPos][1][2]} )	
	endif
			
	do case
	
		case cAction == 'show' 
		
			nLen := len(M->getList[nPos])
			cLog := chr(13) + chr(10) + Replicate( '-', 60 ) +  chr(13) + chr(10)
			
			for nI := 2 to nLen 
				cLog += M->getList[nPos][nI][1] + ': ' + ltrim(str(M->getList[nPos][nI][2])) + chr(13) + chr(10)
			next
			
			cLog += Replicate( '-', 60 )
			
			_l( cLog, '/trace.txt' )				
		
	endcase

retu M->getList[nPos]




//	-------------------------------------------------------------------

function _GTrace( cName )
	GTrace():New( cName )
RETU NIL

CLASS GTrace

	CLASSDATA	lInit				INIT .F.
	CLASSDATA	nIndex				INIT 0
	CLASSDATA	nPosGetList		INIT 0

	METHOD New()					CONSTRUCTOR
	METHOD GetLaps()				
	METHOD Total()				
	METHOD toLog()				

ENDCLASS 

METHOD New( cName ) CLASS GTrace

	LOCAL cInfo

	DEFAULT cName := ''

	IF !::lInit
		AAdd( M->getList, {} )
		::lInit := .T.
		::nIndex := 0
		::nPosGetList := len( M->getList )
	ENDIF
	
	IF !Empty( cName )
	
		::nIndex++
		
		cInfo   			:= procname(2) + '(' +  ltrim(str(procline( 2 ))) + ')'
	
		AAdd( M->getlist[::nPosGetList], { 'pos' => ::nIndex, 'info' => cInfo,  'trace' => cName, 'time' => hb_milliseconds() } )		
	
	ENDIF

RETU SELF

METHOD GetLaps CLASS GTrace
RETU M->Getlist[::nPosGetList]

METHOD Total CLASS GTrace

	LOCAL nStart 	:= Ascan( M->getlist[::nPosGetList],{ |a| a['trace'] == 'start' })
	LOCAL nEnd 	:= Ascan( M->getlist[::nPosGetList],{ |a| a['trace'] == 'end' })
	LOCAL nTotal := 0
	
	IF nStart > 0 .and. nEnd > 0
		nTotal := M->getlist[::nPosGetList][nEnd][ 'time' ] - M->getlist[::nPosGetList][nStart]['time']
	ENDIF
	
RETU nTotal

METHOD toLog() CLASS GTrace

	LOCAL cFileName 		:= hb_getenv( 'PRGPATH' ) + '/data/trace.txt'
	LOCAL nI, cLine, hFile
	LOCAL nLapsus := -1
	local nLast
	
	
	//	Abrimos fichero log
	
		IF ! File( cFileName )
			fClose( FCreate( cFileName ) )	
		ENDIF

		IF ( ( hFile := FOpen( cFileName, FO_WRITE ) ) == -1 )
			RETU NIL
		ENDIF
		
		
	FOR nI := 1 TO len(  M->getlist[::nPosGetList] ) 
	
		IF nI == 1	//	start
			nLapsus := 0			
		ELSE
			nLapsus := M->getlist[::nPosGetList][nI][ 'time' ] - M->getlist[::nPosGetList][nI-1][ 'time' ]  
		ENDIF
	
		cLine := M->getlist[::nPosGetList][nI][ 'info' ] + ' - ' + M->getlist[::nPosGetList][nI][ 'trace' ] + ' -> ' + ltrim(str(nLapsus)) + 'ms.' + Chr(13) + Chr(10)
		fSeek( hFile, 0, FS_END )
		fWrite( hFile, cLine, Len( cLine ) )			
		
	NEXT
	
		cLine  	:= '<EndProcess>  ' + ltrim(str(::Total())) + 'ms.' + Chr(13) + Chr(10)
		fSeek( hFile, 0, FS_END )
		fWrite( hFile, cLine, Len( cLine ) )		

		cLine := Replicate( '-',50) + Chr(13) + Chr(10)
		fSeek( hFile, 0, FS_END )
		fWrite( hFile, cLine, Len( cLine ) )	
	
	fClose( hFile )			
		

RETU NIL

	


