/*	----------------------------------------------------------------------------------
	Sistema de Template.
	---------------------------------------------------------------------------------- */

CLASS TTemplate

	DATA cHtml							INIT ''	
	DATA lLoad							INIT .F.
	
	METHOD New() 						CONSTRUCTOR	
	
	METHOD Section( cSection, cHtml ) 
	METHOD Code()						
	
ENDCLASS 

METHOD New( cTemplate ) CLASS TTemplate

	LOCAL cTpl	:= hb_getenv( 'PRGPATH' ) + '/src/view/' + cTemplate

	IF file( cTpl )	
		::cHtml 	:= memoread( cTpl )	
		::lLoad 	:= .t.
	ENDIF

RETU Self

METHOD Section( cSection, cCode ) CLASS TTemplate

	LOCAL nPos 		:= 0
	LOCAL cBlock1, cBlock2

	IF ::lLoad .AND. !empty( cCode )
	
		nPos  := At( cSection, ::cHtml )
		
		IF nPos > 0
		
			cBlock1 	:=	Substr( ::cHtml, 1, nPos-1 )
			cBlock2 	:=	Substr( ::cHtml, nPos + (len( cSection)) )
			::cHtml 	:=  cBlock1 + cCode + cBlock2				
			
		ENDIF
		
	ENDIF

RETU NIL


METHOD Code() CLASS TTemplate

	LOCAL cCode := ::cHtml
	LOCAL oInfo := { 'file' => 'xxx' }
	
	zReplaceBlocks( @cCode, '{{', '}}', oInfo )	
	

RETU cCode