FUNCTION SetValue( cKey, uValue ) 

RETU App():oData:Set( cKey, uValue )	


FUNCTION GetValue( cKey ) 	

RETU App():oData:Get( cKey )	


FUNCTION GetValueAll() 	

RETU App():oData:aVar	


CLASS TData

   DATA aVar 							INIT {=>}

   METHOD  New() CONSTRUCTOR
   
   METHOD  Set( cKey, uValue ) 		INLINE ::aVar[ lower(cKey) ] := uValue 
   METHOD  Get( cKey ) 				
   METHOD  show() 						INLINE ::aVar

ENDCLASS

METHOD New() CLASS TData

RETU Self

METHOD  Get( cKey ) CLASS TData

	LOCAL uValue := ''

	// HB_HGetDef( ::aVar, lower(cKey), '' ) 
	
	IF hb_HHasKey( ::aVar, cKey )	
	
		uValue := ::aVar[ cKey ]
		
	ELSE
	
		IF App():lShowError	
			App():ShowError( "Var doesn't exist: " + cKey, 'Error _Get()' )	
		ENDIF
	
	ENDIF		

RETU uValue