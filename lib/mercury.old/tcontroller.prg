
//	-----------------------------------------------------------	//

CLASS TController

	DATA oRequest	
	DATA oResponse	
	DATA oMiddleware
	DATA oView
	DATA cAction 				INIT ''
	DATA hParam					INIT {=>}
	DATA aRouteSelect			INIT {=>}
	
	CLASSDATA oRoute					
	
	METHOD New( cAction, hPar ) CONSTRUCTOR
	METHOD InitView()
	METHOD View( cFile, ... ) 					
	METHOD ListController()
	METHOD ListRoute()										INLINE ::oRoute:ListRoute()
	
	METHOD RequestValue 	( cKey, cDefault, cType )			INLINE ::oRequest:Request( cKey, cDefault, cType )
	METHOD GetValue		( cKey, cDefault, cType )			INLINE ::oRequest:Get	 	( cKey, cDefault, cType )
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

	DEFAULT cType		:= ''
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
	::oView:oResponse	:= ::oResponse
	
RETU NIL

METHOD View( cFile, ... ) CLASS TController

	::oView:Exec( cFile, ... )

RETU ''

METHOD Redirect( cRoute ) CLASS TController

	local aMap 	:= ::oRoute:GetMapSort()
	local cMethod 	:= ::oRequest:Method()
	local nPos, cController, aRouteSelect, hParam
	
	? 'Ep Redirect'
	retu

	
	//	Buscaremos la ruta en el mapa (index.prg)	
	
		nPos := Ascan( aMap, {|x,n| lower(x[ MAP_ID ] ) == lower( cRoute ) .AND. x[ MAP_METHOD ] == cMethod }) 
		
	//	Si existe, Volvemos a ejecutar el método execute del TRoute, para REDIRECCIONAR la peticion...
	
		IF nPos > 0
					
			aRouteSelect 	:= aMap[nPos]
			cController  	:= aRouteSelect[ MAP_CONTROLLER ]
			hParam			:= ::oRequest:RequestAll()
			
			::oRoute:Execute( cController, hParam, aRouteSelect )								
			
		ENDIF

RETU NIL

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