
//	-----------------------------------------------------------	//

CLASS TController

	DATA oRequest	
	DATA oResponse	
	DATA oMiddleware
	DATA oView
	DATA cAction 													INIT ''
	DATA hParam														INIT {=>}
	DATA aRouteSelect												INIT {=>}
	DATA lAutenticate												INIT .T.


	
	CLASSDATA oRoute					
	
	METHOD New( cAction, hPar ) 									CONSTRUCTOR
	METHOD InitView()
	METHOD View( cFile, ... ) 					
	METHOD ListController()
	METHOD ListRoute()											INLINE ::oRoute:ListRoute()
	
	METHOD RequestValue 	( cKey, cDefault, cType )				INLINE ::oRequest:Request( cKey, cDefault, cType )
	METHOD GetValue		( cKey, cDefault, cType )				INLINE ::oRequest:Get	 	( cKey, cDefault, cType )
	METHOD PostValue		( cKey, cDefault, cType )				INLINE ::oRequest:Post	( cKey, cDefault, cType )

	METHOD Middleware		( cType, cRoute, aExceptionMethods, hError  )					

	METHOD Redirect		( cRoute )

	
ENDCLASS 

METHOD New( cAction, hPar  ) CLASS TController
		
	::cAction 			:= cAction
	::hParam 			:= hPar		

RETU Self

METHOD Middleware( cType, cRoute, aExceptionMethods, hError, lJson ) CLASS TController

	local nPos := 0

	DEFAULT cType					:= 'jwt'
	DEFAULT cRoute 				:= ''
	DEFAULT aExceptionMethods  	:= array()
	DEFAULT hError  				:= { 'success' => .f., 'error' => 'Error autentication' }
	DEFAULT lJson  				:= .F.
	
	//	If exist some exception, don't autenticate

		nPos := Ascan( aExceptionMethods, {|x,y| lower(x) == lower( ::cAction )} )
		
		if nPos > 0
			retu .t.
		endif

	cType := lower( cType )
	
	//	Lo mismo 'jwt' que 'token', lo se, lo se...
	
	DO CASE
		CASE cType == 'jwt'
			retu ::lAutenticate := ::oMiddleware:Exec( SELF, cType, cRoute, hError, lJson )
			
		CASE cType == 'token'
			retu ::lAutenticate := ::oMiddleware:Exec( SELF, cType, cRoute, hError, lJson )			
	
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