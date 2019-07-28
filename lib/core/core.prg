/*	----------------------------------------------------------------------------
	Name:			LIB Core - Libreria Harbour CORE (Funciones Internas)
	Description: 	Seguridad
	Autor:			Carles Aubia
	Date: 			11/07/06/19	
-------------------------------------------------------------------------------- */

{% include( AP_GETENV( 'PATH_APP' ) + "/include/hbclass.ch" ) %}
{% include( AP_GETENV( 'PATH_APP' ) + "/include/hboo.ch" ) %}
{% include( AP_GETENV( 'PATH_APP' ) + "/include/hbhash.ch" ) %}

{% include( AP_GETENV( 'PATH_APP' ) + "/lib/core/preapache.prg" ) %}		//	Funciones test de apache.prg
{% include( AP_GETENV( 'PATH_APP' ) + "/lib/core/jwt.prg" ) %}				//	Soporte JWT
//	---------------------------------------------------------------------------- //
