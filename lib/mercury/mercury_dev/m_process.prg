#define VERSION 	'v0.2'

function main() 

	local hParam 	:= AP_PostPairs()
	local cMsg 	:= hb_urldecode( alltrim( HB_HGetDef( hParam, 'msg', '' ))) 
	local aParams, cKey
	
	if empty( cMsg )
		Send( 'No message...')
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
		case cKey == 'hello' 		; Send( 'Hello! Now is ' + time() )
		case cKey == 'time' 		; Send( time() )
		case cKey == 'info' 		; Send( 'Information<hr>Developer Mercury. Version: ' + VERSION  + '<hr>')
		otherwise
			Send( 'Unknown ' + cKey, 'error' )
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
		case cTopic == 'view' 			; cFile := 'view.html' 
		
		otherwise						
			Send( "Help don't exist " + cTopic, 'alert' )
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


#include "{% hb_getenv( 'prgpath' ) + '/m_controller.prg'%}" 
#include "{% hb_getenv( 'prgpath' ) + '/m_project.prg'%}" 