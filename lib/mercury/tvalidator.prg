//	-----------------------------------------------------------	//

CLASS TValidator

	DATA hValidate				INIT {=>}
	DATA aErrorMessages			INIT {}	

	METHOD New() CONSTRUCTOR

	METHOD Run( hValidate )	
	METHOD Formatter( hData, hFormat )	
	
	METHOD EvalValue( cKey, cValue )				
	
	
	METHOD ErrorMessages()							INLINE ::aErrorMessages	
	METHOD ErrorString()							

ENDCLASS

METHOD New( hValidate ) CLASS TValidator

	::hValidate := hValidate
	
RETU Self

METHOD Run( hValidate ) CLASS TValidator

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
					RETU { 'success' => .F., 'field' => cKey,  'msg' => 'Parámetro requerido', 'value' => uValue }
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

				IF len( uValue ) <> cargo	
					RETU { 'success' => .F., 'field' => cKey,   'msg' => 'Longitud ha de ser ' + ltrim(str(cargo)), 'value' => uValue  }
					EXIT
				ENDIF
				
			CASE substr(cRole,1,4) == 'max:'

				cargo 	:= Val(substr(cRole, 5 ))
				uValue	:= IF( valtype( uValue ) == 'N', uValue, Val(uValue)) 

				IF  uValue > cargo	
					RETU { 'success' => .F., 'field' => cKey,   'msg' => 'Maxima valor de ' + ltrim(str(cargo)), 'value' => uValue  }
					EXIT
				ENDIF			

			CASE substr(cRole,1,7) == 'maxlen:'

				cargo := Val(substr(cRole, 8 ))

				IF valtype( uValue ) == 'C' .AND. len(uValue) > cargo
					RETU { 'success' => .F., 'field' => cKey,   'msg' => 'Maxima longitud de ' + ltrim(str(cargo)), 'value' => uValue  }
					EXIT
				ENDIF	

			CASE substr(cRole,1,7) == 'minlen:'

				cargo := Val(substr(cRole, 8 ))

				IF valtype( uValue ) == 'C' .AND. len(uValue) < cargo
					RETU { 'success' => .F., 'field' => cKey,   'msg' => 'Minima longitud de ' + ltrim(str(cargo)), 'value' => uValue  }
					EXIT
				ENDIF					
				
		ENDCASE		
		
	NEXT								

RETU { 'success' => .T. }

METHOD Formatter( hData, hFormat ) CLASS TValidator

	LOCAL n, cField, cFormat, aH
	LOCAL aFormat, nFormat, cFunc, j
	LOCAL uValue
	
	HB_HCaseMatch( hData, .F. )
	
	FOR n := 1 to len( hFormat )
	
		aH := hb_HPairAt( hFormat, n )
		
		cField 		:= aH[1]
		cFormat 	:= aH[2]			

		IF HB_HHasKey( hData, cField ) 

			uValue 	:= hData[ cField ]

			IF !empty( uValue )

				aFormat := HB_ATokens( cFormat, '|' )
	
				nFormat := len( aFormat )			
				
				//	Aqui hemos de ponser todos los roles. Escalar !
				
				FOR j = 1 to nFormat
	
					cFunc := alltrim(lower(aFormat[j]))
		
					DO CASE
						CASE cFunc == 'upper'
						
							IF valtype( uValue ) == 'C' .and. !empty( uValue )			
								uValue := Upper( uValue )						
							ENDIF
							
						CASE cFunc == 'lower'
						
							IF valtype( uValue ) == 'C' .and. !empty( uValue )			
								uValue := Lower( uValue )						
							ENDIF						
							
					ENDCASE		
					
				NEXT
				
				hData[ cField ] := uValue 
			
			ENDIF
		
		ENDIF		
	
	NEXT				

RETU NIL
