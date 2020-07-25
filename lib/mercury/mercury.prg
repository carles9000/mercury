/*	----------------------------------------------------------------------------
	Name:			LIB Mercury - Libreria Harbour MVC (Model/View/Controller 
	Description: 	Primera libreria para poder emular sistema MVC
	Autor:			Carles Aubia
	Date: 			19/06/19	
-------------------------------------------------------------------------------- */

#define MVC_VERSION 			'Mercury v1.08b'
#define MERCURY_PATH 			'lib/'
#define CRLF 					hb_OsNewLine()
	
#define MAP_METHOD 				1
#define MAP_ID 					2
#define MAP_ROUTE				3
#define MAP_CONTROLLER			4
#define MAP_QUERY				5
#define MAP_PARAMS				6
#define MAP_ORDER				7



/*	-----------------------------------------------------------------------------
	Si compilamos con harbour todos los módulos para generar el hrb, podemos ver
	los errores de compilación y asi poder solucionar y limpiar code. Una vez 
	tengamos la libreria generada, la tendremos de llamar desde el módulo principal
	con ...
-------------------------------------------------------------------------------- */	

thread static hKeySecure  := {=>}
thread static __hCargo 	:= {=>}
thread static __hFiles 	:= {=>}


//	Se han de definir estos comandos pues los usamos en algunos módulos...
#xcommand ? [<explist,...>] => AP_RPuts( '<br>' [,<explist>] )
#xcommand ?? [<explist,...>] => AP_RPuts( [<explist>] )
#xcommand TEMPLATE [ USING <x> ] [ PARAMS [<v1>] [,<vn>] ] => #pragma __cstream | AP_RPuts( InlinePrg( %s, [@<x>] [,<(v1)>][+","+<(vn)>] [, @<v1>][, @<vn>] ) )
#xcommand TEXT TO <var> [ PARAMS [<v1>] [,<vn>] ] ;
=> ;
	#pragma __cstream |<var> += InlinePrg( ReplaceBlocks( %s, '<$', "$>" [,<(v1)>][+","+<(vn)>] [, @<v1>][, @<vn>] ) )
#xcommand DEFAULT <uVar1> := <uVal1> ;
               [, <uVarN> := <uValN> ] => ;
                  If( <uVar1> == nil, <uVar1> := <uVal1>, ) ;;
                [ If( <uVarN> == nil, <uVarN> := <uValN>, ); ]
				
//	-------------------------------------------------------------------------------- 

#include "..\..\include\hbclass.ch" //	thread STATIC s_oClass Lin239
#include "hboo.ch"   
#include "common.ch" 
#include "hbhash.ch" 
#include "FileIO.ch"

#include 'mercury.ch'

#include "tapp.prg"   				//	Sistema TApp
#include "tview.prg"   				//	Sistema View
#include "troute.prg"   			//	Sistema Router
#include "trequest.prg"          	//	Sistema Request
#include "tresponse.prg"          	//	Sistema Response
#include "tcontroller.prg"   		//	Sistema Controller
#include "tvalidator.prg"   		//	Sistema Validator
#include "tmiddleware.prg"   		//	Sistema Middleware
#include "tdata.prg"   				//	Sistema TData
#include "ttemplate.prg"			//	Sistema Template

#include "jwt.prg"					//	Sistema JWT (Json Web Token)
#include "preapache.prg"			//	Funcs. mod harbour apache
#include "public.prg"				//	Funcs. public
#include "errorsys.prg"				//	Funcs. Error



//	---------------------------------------------------------------------------- //