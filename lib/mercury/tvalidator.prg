//	-----------------------------------------------------------	//


CLASS TValidator

	DATA hValidate				INIT {=>}
	DATA aErrorMessages			INIT {}	

	METHOD New() CONSTRUCTOR

	METHOD Run( hValidate )	
	
	METHOD EvalValue( cKey, cValue )				
	METHOD EvalFormat( cKey, cValue )	
	
	METHOD ErrorMessages()							INLINE ::aErrorMessages	
	METHOD ErrorString()							

ENDCLASS

METHOD New( hValidate ) CLASS TValidator

	::hValidate := hValidate
	
RETU Self

METHOD Run( hValidate, hFormat ) CLASS TValidator

	LOCAL lValidate := .T.
	LOCAL hMsg
	LOCAL a, n, aH, cKey, cValue

	
	IF ValType( hValidate ) == 'H'

		::hValidate := hValidate
		
		FOR n := 1 to len( ::hValidate )
		
			aH := hb_HPairAt( ::hValidate, n )
			
			cKey 	:= aH[1]
			cValue 	:= aH[2]
		
			hMsg := ::EvalValue( cKey, cValue )		
		
			IF hMsg[ 'success' ] == .F.
				
				Aadd( ::aErrorMessages, hMsg )
				
			ENDIF
		
		NEXT

		lValidate := len( ::aErrorMessages ) == 0
	
	ENDIF
	
	IF lValidate .AND. ValType( hFormat ) == 'H'
	
		FOR n := 1 to len( hFormat )
		
			aH := hb_HPairAt( hFormat, n )
			
			cKey 	:= aH[1]
			cValue 	:= aH[2]
		
			::EvalFormat( cKey, cValue )		
		
		NEXT				
	
	ENDIF
	

	//	xec ->getmessages()
	//	xec ->fails()	

RETU lValidate

METHOD ErrorString() CLASS TValidator
	
	LOCAL cError := '' 
	LOCAL nI 

	FOR nI := 1 TO len( ::aErrorMessages )
		cError += 'Field: ' + ::aErrorMessages[nI][ 'field' ] + ' ' + ::aErrorMessages[nI][ 'msg' ] + '<br>'	
	NEXT			

RETU cError


METHOD EvalValue( cKey, cValue ) CLASS TValidator

	LOCAL oReq 		:= App():oRequest     //::oRoute:oTRequest	
	LOCAL aRoles, n, nRoles, cRole
	LOCAL uValue 		
	LOCAL cargo
	LOCAL cMethod 	:= oReq:Method()
	
	__defaultNIL( @cValue, '' )
	
	DO CASE
		CASE cMethod == 'GET'	;	uValue := oReq:Get( cKey )
		CASE cMethod == 'POST'	;	uValue := oReq:Post( cKey )
		OTHERWISE
			uValue := oReq:hParam[ cKey ]
	ENDCASE	
	
	aRoles := HB_ATokens( cValue, '|' )
	nRoles := len( aRoles )	
	
	//	Aqui hemos de ponser todos los roles. Escalar !
	
	FOR n = 1 to nRoles
	
		cRole := alltrim(lower(aRoles[n]))
		
		DO CASE
			CASE cRole == 'required'
			
				IF empty( uValue )
					RETU { 'success' => .F., 'field' => cKey,  'msg' => 'Paràmetro requerido', 'value' => uValue }
					EXIT
				ENDIF
				
			CASE cRole == 'numeric'
	
				IF ! ISDIGIT( uValue )
					RETU { 'success' => .F., 'field' => cKey,   'msg' => 'Valor no numérico', 'value' => uValue }
					EXIT
				ENDIF

			CASE cRole == 'string'
	
				IF ! ISALPHA( uValue )
					RETU { 'success' => .F., 'field' => cKey,   'msg' => 'Valor no string', 'value' => uValue  }
					EXIT
				ENDIF

			CASE substr(cRole,1,4) == 'len:'

				cargo := Val(substr(cRole, 5 ))

				IF len( uValue ) > cargo	
					RETU { 'success' => .F., 'field' => cKey,   'msg' => 'Maxima longitud de ' + ltrim(str(cargo)), 'value' => uValue  }
					EXIT
				ENDIF
				
			CASE substr(cRole,1,4) == 'max:'

				cargo 	:= Val(substr(cRole, 5 ))
				uValue	:= IF( valtype( uValue ) == 'N', uValue, Val(uValue)) 

				IF  uValue > cargo	
					RETU { 'success' => .F., 'field' => cKey,   'msg' => 'Maxima longitud de ' + ltrim(str(cargo)), 'value' => uValue  }
					EXIT
				ENDIF				
				
		ENDCASE		
		
	NEXT								

RETU { 'success' => .T. }

METHOD EvalFormat( cKey, cValue ) CLASS TValidator

	LOCAL oReq 		:= App():oRequest     //::oRoute:oTRequest	
	LOCAL cMethod 		:= oReq:Method()
	LOCAL aRoles, n, nRoles, cRole
	LOCAL uValue 		
	LOCAL cargo
	
	__defaultNIL( @cValue, '' )
	
	DO CASE
		CASE cMethod == 'GET'	;	uValue := oReq:Get( cKey )
		CASE cMethod == 'POST'	;	uValue := oReq:Post( cKey )
		OTHERWISE
			uValue := oReq:hParam[ cKey ]
	ENDCASE	
	
	aRoles := HB_ATokens( cValue, '|' )
	nRoles := len( aRoles )	
	
	//	Aqui hemos de ponser todos los roles. Escalar !
	
	FOR n = 1 to nRoles
	
		cRole := alltrim(lower(aRoles[n]))
		
		DO CASE
			CASE cRole == 'upper'
			
				IF valtype( uValue ) == 'C'			
					uValue := Upper( uValue )						
				ENDIF
				
		ENDCASE		
		
	NEXT
	
	//	Devolvemos el campo formateado al Request...

	DO CASE
		CASE cMethod == 'GET'	;	oReq:SetGet( cKey, uValue )
		CASE cMethod == 'POST'	;	oReq:SetPost( cKey, uValue )
	ENDCASE		

RETU NIL