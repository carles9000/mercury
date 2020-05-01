
//	-----------------------------------------------------------	//

CLASS TController

	DATA oRequest	
	DATA oResponse	
	DATA oMiddleware
	DATA oView
	DATA cAction 				INIT ''
	DATA hParam				INIT {=>}
	DATA aRouteSelect			INIT {=>}


	
	CLASSDATA oRoute					
	
	METHOD New( cAction, hPar ) CONSTRUCTOR
	METHOD InitView()
	METHOD View( cFile, ... ) 					
	METHOD ListController()
	METHOD ListRoute()											INLINE ::oRoute:ListRoute()
	
	METHOD RequestValue 	( cKey, cDefault, cType )			INLINE ::oRequest:Request( cKey, cDefault, cType )
	METHOD GetValue			( cKey, cDefault, cType )			INLINE ::oRequest:Get	 	( cKey, cDefault, cType )
	METHOD PostValue		( cKey, cDefault, cType )			INLINE ::oRequest:Post	( cKey, cDefault, cType )
	
	//	POdria ser algo mas como Autentica() ???
	METHOD Middleware		( cValid, cRoute )					

	METHOD Redirect		( cRoute )

	
ENDCLASS 

METHOD New( cAction, hPar  ) CLASS TController
		
	::cAction 			:= cAction
	::hParam 			:= hPar		

RETU Self

METHOD Middleware( cType, cRoute, cargo ) CLASS TController

	DEFAULT cType	:= ''
	DEFAULT cRoute 	:= ''
	DEFAULT cargo  	:= ''
	
	DO CASE
		CASE cType == 'jwt'
			retu ::oMiddleware:Exec( SELF, cType, cRoute )
	
		CASE cType == 'rool'				
		
	ENDCASE

RETU .F.




METHOD InitView( ) CLASS TController

	::oView 			:= TView():New()
	::oView:oRoute		:= ::oRoute					//	Xec oApp():oRoute !!!!
	::oView:oResponse	:= App():oResponse 			//::oResponse
	
RETU NIL

METHOD View( cFile, ... ) CLASS TController

	::oView:Exec( cFile, ... )

RETU ''

/*	
	Como mod harbour aun no podemos crear un redirect correctamente, simularemos de esta manera
	https://stackoverflow.com/questions/503093/how-do-i-redirect-to-another-webpage/506004#506004
*/

METHOD Redirect( cRoute ) CLASS TController

	local oResponse 	:= App():oResponse
	local cHtml := ''

	cHtml += '<script>'
	cHtml += "window.location.replace( '" + cRoute + "'); "
	cHtml += '</script>'
	
	//	Ejecutamos el metodo SendHtml y si hay alguna cookie la enviare previamente...
	
		oResponse:SendHtml( cHtml )	

RETU NIL

/*
	Habriamos de tener en cuenta que si venimos por ejemplo de un proces de autenticacion
	la llamada al controller seria de tipo POST y si una vez autenticado venimos a Redirect()
	y no le pasamo method cojera el del controller que es POST. Esto implica en q en este 
	caso deberiamos tener definido en el map una entrada para cRoute con POST	
*/

/* Version working...
METHOD Redirect( cRoute, cMethod ) CLASS TController

	local aMap 	:= ::oRoute:GetMapSort()
	local nPos, cController, aRouteSelect, hParam
	local cAction, cFile, cType, cCode, cPath, cProg, cNameClass		

	DEFAULT cMethod :=  ::oRequest:Method()
	
	//	Buscaremos la ruta en el mapa (index.prg)	

		nPos := Ascan( aMap, {|x,n| lower(x[ MAP_ID ] ) == lower( cRoute ) .AND. x[ MAP_METHOD ] == cMethod }) 	//	cMethod == GET ?
		
	//	Si existe, Volvemos a ejecutar el método execute del TRoute, para REDIRECCIONAR la peticion...
	
		IF nPos > 0			
		
			cPath 			:= App():cPath + App():cPathController
			aRouteSelect 	:= aMap[nPos]
			cController  	:= aRouteSelect[ MAP_CONTROLLER ]
			hParam			:= ::oRequest:RequestAll()
			
			//	Esta parte esta igual en el Route, pero la he querido aislar para pruebas
			//	independientes...
		
			//	Chequeamos de que tipo es el controller
			//	tipo clase -> @
			//	tipo function -> ()
			//	Por defecto sera function
			
				nPos := At( '@', cController )
				
				IF ( nPos >  0 )
					
					cAction 	:= alltrim( Substr( cController, 1, nPos-1) )
					cFile 		:= alltrim( Substr( cController, nPos+1 ) )
					cType		:= 'class'
				
				ELSEIF ( nPos := At( '()', cController ) ) > 0 

					cAction 	:= alltrim( Substr( cController, 1, nPos-1) )
					cFile 		:= alltrim( Substr( cController, nPos+2 ) )
					cType		:= 'func'		
					
				ELSEIF ( right( lower( cController ), 5 ) == '.view' ) 

					cType	 	:= 'view'				
				
				ELSE 
				
					cFile 	:= cController
					cType	:= 'func'					
				
				ENDIF

			//	------------------------------------------------------------			
			
			cProg := cPath + cFile
			
			IF File ( cProg )				
			
				IF cType == 'class'			

					cNameClass := cFileNoExt( cFileNoPath( cFile ) )

				//	Opcion acceso Controller via Clases
				
					cCode := "#include 'hbclass.ch'" + HB_OsNewLine()
					cCode += "#include 'hboo.ch' " + HB_OsNewLine()  
					
					cCode += "FUNCTION __RunController( o )" + HB_OsNewLine()  
					cCode += "	LOCAL oC := " + cNameClass + "():New( o )" + HB_OsNewLine() 
					
					IF !Empty( cAction )
					
						cCode += "	IF __objHasMethod( oC, '" + cAction + "' ) "  + HB_OsNewLine() 
						cCode += "		oC:" + cAction + "(o) "  + HB_OsNewLine() 
						cCode += "	ELSE "  + HB_OsNewLine() 
						cCode += "		App():ShowError( 'Método <b>" + cAction  + "()</b> no definido en el controller " + cFile + "', 'TController Error!' ) "  + HB_OsNewLine() 				
						cCode += "		QUIT "  + HB_OsNewLine() 				
						cCode += "	ENDIF "  + HB_OsNewLine() 
					
					ENDIF
					
					cCode += "RETU NIL" + HB_OsNewLine() + memoread( cProg )

				ELSE

					cCode := memoread( cProg )

				ENDIF								
			
			ENDIF			

			//oInfo[ 'file' ] := cFile
			//oInfo[ 'code' ] := cCode					
			
			//	Usareos el mismo oController, porque venimos de un Redirect y es posible 
			//	que hayamos hecho una respuesta de cookie -> oController:oResponse:SetCookie() y
			//  esta pendiente de salida. Con el nuevo execute, en este caso se generaria 
			//	la cookie + la salida
			
			//WHILE zReplaceBlocks( @cCode, ("{"+"%"), ("%"+"}"), oInfo, oController )	
			WHILE ReplaceBlocks( @cCode, ("{"+"%"), ("%"+"}"), SELF )		
			END							

			//zExecute( cCode, oInfo, oController )			
			Execute( @cCode, SELF )												
			
			QUIT
			
		ENDIF

RETU NIL
*/




METHOD ListController() CLASS TController

	LOCAL oThis := SELF		
	
	TEMPLATE PARAMS oThis
	
		<b>ListController</b><hr><pre>
		
		<table border="1" style="font-weight:bold;">
		
			<thead>
				<tr>
					<th>Description</th>
					<th>Parameter</th>
					<th>Value</th>							
				</tr>									
			</thead>
			
			<tbody>
			
				<tr>
					<td>ClassName Name</td>
					<td>ClassName()</td>
					<td><?prg retu oThis:ClassName() ?></td>
				</tr>
				
				<tr>
					<td>Action</td>
					<td>cAction</td>
					<td><?prg retu oThis:cAction ?></td>
				</tr>				
			
				<tr>
					<td>Parameters</td>
					<td>hParam</td>
					<td><?prg retu ValToChar( oThis:hParam ) ?></td>
				</tr>				
				
				<tr>
					<td>Method</td>
					<td>oRequest:method()</td>
					<td><?prg retu oThis:oRequest:method() ?></td>
				</tr>
				
				<tr>
					<td>Query</td>
					<td>oRequest:GetQuery()</td>
					<td><?prg retu oThis:oRequest:getquery() ?></td>
				</tr>				

				<tr>
					<td>Parameters GET</td>
					<td>oRequest:CountGet()</td>
					<td><?prg retu ValToChar(oThis:oRequest:countget()) ?></td>
				</tr>	

				<tr>
					<td>Value GET</td>
					<td>oRequest:Get( cKey )</td>
					<td><?prg retu ValToChar(oThis:oRequest:getall()) ?></td>
				</tr>

				<tr>
					<td>Parameters POST</td>
					<td>oRequest:CountPost()</td>
					<td><?prg retu ValToChar(oThis:oRequest:countpost()) ?></td>
				</tr>	

				<tr>
					<td>Value POST</td>
					<td>oRequest:Post( cKey )</td>
					<td><?prg retu ValToChar(oThis:oRequest:postall()) ?></td>
				</tr>	

				<tr>
					<td>Route Select</td>
					<td>aRouteSelect</td>
					<td><?prg retu ValToChar(oThis:aRouteSelect) ?></td>
				</tr>				
				
			
			</tbody>		
			
		</table>

		</pre>
		
   
   ENDTEXT

RETU ''

//	-----------------------------------------------------------	//