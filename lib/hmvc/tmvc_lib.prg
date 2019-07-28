/*	----------------------------------------------------------------------------
	Name:			LIB HMVC - Libreria Harbour MVC (Model/View/Controller 
	Description: 	Primera libreria para poder emular sistema MVC
	Autor:			Carles Aubia
	Date: 			19/06/19	
-------------------------------------------------------------------------------- */

/*	-----------------------------------------------------------------------------
	Si compilamos con harbour todos los módulos para generar el hrb, podemos ver
	los errores de compilación y asi poder solucionar y limpiar code. Una vez 
	tengamos la libreria generada, la tendremos de llamar desde el módulo principal
	con ...
-------------------------------------------------------------------------------- */	


//	Se han de definir estos comandos pues los usamos en algunos módulos...
#xcommand ? [<explist,...>] => AP_RPuts( '<br>' [,<explist>] )
#xcommand ?? [<explist,...>] => AP_RPuts( [<explist>] )
#xcommand TEMPLATE [ USING <x> ] [ PARAMS [<v1>] [,<vn>] ] => #pragma __cstream | AP_RPuts( InlinePrg( %s, [@<x>] [,<(v1)>][+","+<(vn)>] [, @<v1>][, @<vn>] ) )
//	-------------------------------------------------------------------------------- 


#include "hbclass.ch" 
#include "hboo.ch"   
#include "hbhash.ch" 

#include "tools.prg"   				//	Soporte...
#include "tapp.prg"   				//	Sistema TApp
#include "tview.prg"   				//	Sistema View
#include "troute.prg"   			//	Sistema Router
#include "trequest.prg"          	//	Sistema Request
#include "tresponse.prg"          	//	Sistema Response
#include "tcontroller.prg"   		//	Sistema Controller
#include "tmodel.prg"   			//	Sistema Model
#include "tvalidator.prg"   		//	Sistema Validator
#include "tmiddleware.prg"   		//	Sistema Middleware
#include "tdata.prg"   				//	Sistema TData
//	---------------------------------------------------------------------------- //