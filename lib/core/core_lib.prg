/*	----------------------------------------------------------------------------
	Name:			LIB Core - Libreria Harbour CORE (Funciones Internas)
	Description: 	Seguridad
	Autor:			Carles Aubia
	Date: 			11/07/06/19	
-------------------------------------------------------------------------------- */

//	Se han de definir estos comandos pues los usamos en algunos módulos...
#xcommand ? [<explist,...>] => AP_RPuts( '<br>' [,<explist>] )
#xcommand ?? [<explist,...>] => AP_RPuts( [<explist>] )
#xcommand TEMPLATE [ USING <x> ] [ PARAMS [<v1>] [,<vn>] ] => #pragma __cstream | AP_RPuts( InlinePrg( %s, [@<x>] [,<(v1)>][+","+<(vn)>] [, @<v1>][, @<vn>] ) )
//	-------------------------------------------------------------------------------- 



#include "hbclass.ch" 
#include "hboo.ch"   
#include "hbhash.ch"

#include "preapache.prg" 		//	Funciones test de apache.prg
#include "public.prg" 			//	Funciones Públicas
#include "jwt.prg" 				//	Soporte JWT
//	---------------------------------------------------------------------------- //
