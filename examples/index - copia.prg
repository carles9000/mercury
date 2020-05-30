//	------------------------------------------------------------------------------
//	Title......: HiApp !
//	Description: Example de web application with mercury...
//	Date.......: 29/04/2020
//	------------------------------------------------------------------------------
//	{% LoadHRB( '/lib/mercury/mercury.hrb' ) %}	//	Loading system MVC Mercury
//	------------------------------------------------------------------------------

#include {% MercuryInclude( 'lib/mercury' ) %}

#define FS_END             2           /* Seek from end of file */
#define FO_WRITE           1           /* File is opened for writing */


static nCount

function Main()

	local oApp 	

	//	Define App
	
		//DEFINE APP oApp TITLE 'Help modHarbour' 
		DEFINE APP oApp TITLE 'My web aplication...' ;
			ON INIT Config()							
		
		//	Config Routes		
		
			DEFINE ROUTE 'root' 		URL '/' 			CONTROLLER 'default@rootcontroller.prg' 	METHOD 'GET' OF oApp		
			DEFINE ROUTE 'search' 		URL 'search/(txt)'	CONTROLLER 'search@rootcontroller.prg'		METHOD 'GET' OF oApp		
			DEFINE ROUTE 'hello' 		URL 'hello'			CONTROLLER 'hello@rootcontroller.prg' 		METHOD 'GET' OF oApp		


	//	System init...
	
		INIT APP oApp	

retu nil

function AppPath(); 			RETU AP_GetEnv( "DOCUMENT_ROOT" ) + AP_GetEnv( "PATH_APP" )
function AppPathData() ; 		RETU AP_GetEnv( "DOCUMENT_ROOT" ) + AP_GetEnv( "PATH_DATA" )
function AppUrlImg() ;		RETU AP_GetEnv( "PATH_URL" ) + '/images/'
function AppUrlLib() ;		RETU AP_GetEnv( "PATH_URL" ) + '/lib/'
function AppUrlJs() ;			RETU AP_GetEnv( "PATH_URL" ) + '/js/'
function AppUrlDat() ;		RETU AP_GetEnv( "PATH_DATA" )
function AppFileVisits(); 	RETU AppPath() + '/visits.txt'
function AppFileTrace(); 		RETU AppPath() + '/log.txt'

function Config() 
	
	SET DATE FORMAT TO 'dd-mm-yyyy'	

	Visits()	
	Trace()		
	
retu nil 

function GetVisits() ; retu nCount
function Visits()
 
	nCount	:= val( memoread( AppFileVisits() ) )
	
	nCount++

	memowrit(  AppFileVisits(), ltrim(str(nCount)) )						

retu nil 

function Trace()

	LOCAL cFileName 		:= AppFileTrace()
 	LOCAL cNow 			:= DToC( Date() ) + " " + Time() 

	
		IF ! File( cFileName )
			fClose( FCreate( cFileName ) )	
		ENDIF

		IF ( ( hFile := FOpen( cFileName, FO_WRITE ) ) == -1 )
			RETU NIL
		ENDIF
		
	//	Log	
	
		cLine  	:= cNow + ' ' + AP_GETENV( 'REMOTE_ADDR' ) + Chr(13) + Chr(10)
			
		fSeek( hFile, 0, FS_END )
		fWrite( hFile, cLine, Len( cLine ) )		
	
	//	Close file log

		fClose( hFile )   
		
retu nil