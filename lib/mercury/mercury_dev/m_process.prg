#define VERSION 	'v0.2'

static aStr := {=>}

function main() 

	local hParam 	:= AP_PostPairs()
	local cMsg 		:= hb_urldecode( alltrim( HB_HGetDef( hParam, 'msg', '' ))) 
	local cLang		:= 'es' //	Funciona pero de momento fijo -> hb_urldecode( alltrim( HB_HGetDef( hParam, 'lang', 'es' ))) 
	local aParams, cKey
	
	LoadLang()

	if empty( cMsg )
		Send( _s('no message') )
		retu nil
	endif
	
	aParams  	:= hb_ATokens( cMsg  )	
	cKey 		:= lower( aParams[1] )
	aParams		:= hb_ADel( aParams, 1, .T. )
	cFirst		:= substr( cKey, 1, 1 )				
	
	do case
		case cKey == 'help' 		; Help( aParams )
		case cKey == '?' 			; Help( aParams )			
		
		case cKey == 'controller' 	; Controller( cKey, aParams  )
		case cKey == 'project'		; Project( cKey, aParams  )
		case cKey == 'hello' 		; Send( _s( 'hello', time() ) )
		case cKey == 'time' 		; Send( time() )
		case cKey == 'info' 		; Send( 'Information<hr>Developer Mercury. Version: ' + VERSION  + '<hr>')
		otherwise
			Send( _s( 'desconocido', cKey ), 'error' )
	endcase

retu nil

function Help( aParams )

	local cHtml 		:= ''
	local cTopic 		:= 'default'
	local cPathHelp 	:= HB_GetEnv( 'PRGPATH' ) + '/help' 
	local cFile 		:= 'default'
	
	if len(aParams) == 1
		cTopic := lower(alltrim(aParams[1]))
	endif	
	
	do case
		case cTopic == 'default' 	 	; cFile := 'default.html' 
		case cTopic == 'controller' 	; cFile := 'controller.html' 
		case cTopic == 'project' 		; cFile := 'project.html' 
		case cTopic == 'view' 			; cFile := 'view.html' 
		
		otherwise						
			Send( _s( "no help", cTopic) , 'alert' )
			retu nil
	endcase
	
	if file ( cPathHelp + '/' + cFile )
		cHtml := memoread( cPathHelp + '/' + cFile )
		Send( cHtml, 'normal' )
	else
		cHtml := 'Help file not found: ' + cFile 
		Send( cHtml, 'error' )		
	endif		


retu nil

function Send( cTxt, cType )

	local cIcon

	DEFAULT cType TO ''
	
	cType := lower(cType)
	
	DO CASE
		CASE cType == 'info' 	; cIcon := '<span style="color:#00d600;"><i class="fas fa-info-circle"></i></span>&nbsp;'
		CASE cType == 'alert' 	; cIcon := '<span style="color:yellow;"><i class="fas fa-exclamation-circle"></i></span>&nbsp;'
		CASE cType == 'error' 	; cIcon := '<span style="color:red;"><i class="fas fa-exclamation-triangle"></i></span>&nbsp;'
		CASE cType == 'normal' 				
			? '<div style="font-family: Verdana, Geneva, sans-serif;;font-size:1.3rem;">' 	 
			? cTxt
			? '</div>'
			retu nil
		OTHERWISE
			cIcon := '<span style="color:#00d600;"><i class="far fa-check-circle"></i></span>&nbsp;'
	ENDCASE		

	? cIcon + cTxt

retu nil

function _s( cKey, ... )

	local cTxt 	:= HB_HGetDef( aStr, cKey, '' )
	local nI 
	
	if !empty( cTxt )
	
		for nI := 2 to pcount()
		
			cTag := '%'  + ltrim(str(nI-1))
		
			cTxt := Strtran( cTxt, cTag, valtochar(pValue(nI)) )
		
		next
		
	else 
	
		cTxt := '??? [' + cKey + ']'
	
	endif

retu cTxt

#include "{% hb_getenv( 'prgpath' ) + '/m_lang.prg'%}" 
#include "{% hb_getenv( 'prgpath' ) + '/m_controller.prg'%}" 
#include "{% hb_getenv( 'prgpath' ) + '/m_project.prg'%}" 