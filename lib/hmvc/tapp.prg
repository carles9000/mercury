#define MVC_VERSION 	'MVC v0.45'
#xcommand log <cText> => Aadd( TApp():aLog, <cText> )  //	Tracear el sistema

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
   
   //DATA bError							INIT {|cError, cTitle| ::ShowError( cError, cTitle ) }							
   
   //CLASSDATA cPath							INIT AP_GETENV( 'PATH_APP' )
   CLASSDATA cPath							INIT AP_GETENV( 'DOCUMENT_ROOT' ) + AP_GETENV( 'PATH_APP' )
   CLASSDATA cUrl							INIT AP_GETENV( 'PATH_URL' )
   CLASSDATA cPathView						INIT '/src/view/'
   CLASSDATA cPathController				INIT '/src/controller/'
   CLASSDATA cPathModel					INIT '/src/model/'
   CLASSDATA cPathData						INIT AP_GETENV( 'DOCUMENT_ROOT' ) + AP_GETENV( 'PATH_DATA' )
   CLASSDATA cTitle						INIT 'App'
   CLASSDATA cFileLog						INIT AP_GETENV( 'DOCUMENT_ROOT' ) + AP_GETENV( 'PATH_DATA' ) + '/logview.txt'
   CLASSDATA lLog							INIT .F.
   CLASSDATA aLog							INIT {}							
   CLASSDATA aSys							INIT {=>}							


   METHOD New() CONSTRUCTOR

   METHOD Version() 							INLINE MVC_VERSION
   METHOD Path() 								INLINE ::cPath
   METHOD Url() 								INLINE ::cUrl
   METHOD Init() 
   METHOD Config() 
   METHOD ListApp() 
   
   METHOD ShowError( cError, cTitle )		   
   //METHOD Error( cError, cTitle )			INLINE Eval( ::bError, cError, cTitle )
   
ENDCLASS

METHOD New() CLASS TApp

	::oRequest 	:= TRequest():New()	
	::oResponse 	:= TResponse():New()	
	::oMiddleware 	:= TMiddleware():New()	
	::oRoute 		:= TRoute():New( SELF )
	::oData 		:= TData():New()

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
	
	?? '<h2>' + cTitle + '<hr></h2>'
	
	?? '<h3>' + cError + '</h3>'


RETU NIL

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


exit procedure Close()

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
		
	ENDIF

RETU 




