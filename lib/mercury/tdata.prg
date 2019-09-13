FUNCTION SetValue( cKey, uValue ) 

RETU App():oData:Set( cKey, uValue )	


FUNCTION GetValue( cKey, uKey ) 	

RETU App():oData:Get( cKey, uKey  )	


FUNCTION GetValueAll() 	

RETU App():oData:aVar	


CLASS TData

   DATA aVar 							INIT {=>}

   METHOD  New() CONSTRUCTOR
   
   METHOD  Set( cKey, uValue ) 			INLINE ::aVar[ lower(cKey) ] := uValue 
   METHOD  Get( cKey, uKey ) 				
   METHOD  show() 						INLINE ::aVar

ENDCLASS

METHOD New() CLASS TData

RETU Self

METHOD  Get( cKey, uKey ) CLASS TData

	LOCAL uValue := ''

	// HB_HGetDef( ::aVar, lower(cKey), '' ) 
	
	IF hb_HHasKey( ::aVar, cKey )	
	
		uValue := ::aVar[ cKey ]
		
		IF Valtype( uKey ) <> 'U' .AND. ( ValType( uValue ) == 'A' .OR. ValType( uValue ) == 'H' )
		
			uValue := uValue[ uKey ]
			
		ENDIF				
		
	ELSE
	
		/*
		IF App():lShowError	
			App():ShowError( "Var doesn't exist: " + cKey, 'Error _Get()' )	
		ENDIF
		*/
	
	ENDIF		

RETU uValue