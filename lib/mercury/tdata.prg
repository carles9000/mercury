FUNCTION _Set( cKey, uValue ) 

	App():oData:Set( cKey, uValue )
	
RETU NIL

FUNCTION _Get( cKey, cType ) 	

RETU App():oData:Get( cKey )	

FUNCTION _GetAll( cKey, cType ) 	
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