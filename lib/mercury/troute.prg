//	-----------------------------------------------------------	//

CLASS TRoute

	DATA oApp
	DATA oRequest
	DATA oResponse
	DATA bLog

	
	CLASSDATA aMap											INIT {}	

	METHOD New() 											CONSTRUCTOR
	
	METHOD Map( cMethod, cId, cRoute, cController ) 
	METHOD Get( cId, cRoute, cController ) 				INLINE ::Map( 'GET' , cId, cRoute, cController )
	METHOD Post( cId, cRoute, cController ) 			INLINE ::Map( 'POST', cId, cRoute, cController )
	METHOD ListRoute()
	METHOD Listen()
	METHOD Execute()
	METHOD ShowError( cError )							INLINE ::oApp:ShowError( cError, 'Route Error! ')
	
	METHOD GetMapSort()

ENDCLASS

METHOD New( oApp ) CLASS TRoute

	::oApp 		:= oApp
	::oRequest 	:= oApp:oRequest
	::oResponse := oApp:oResponse
	
	
RETU Self


METHOD Map( cMethod, cId, cRoute, cController ) CLASS TRoute

	LOCAL aMethod
	LOCAL nI
	
	DEFAULT cMethod := 'GET,POST'

	IF At( ',', cMethod ) > 0

		aMethod := HB_ATokens( cMethod, ',' )
		
		FOR nI := 1 TO len( aMethod )

			Aadd( ::aMap, { alltrim(aMethod[nI]), cId, cRoute, cController, '', '', '' } )		
			
			::aMap[ len( ::aMap ) ][ MAP_ORDER ] := len( ::aMap )	
		NEXT
		
	ELSE

		Aadd( ::aMap, { cMethod, cId, cRoute, cController, '', '', '' } )
		
		::aMap[ len( ::aMap ) ][ MAP_ORDER ] := len( ::aMap )	
		
	ENDIF
	

RETU NIL

METHOD GetMapSort() CLASS TRoute
	LOCAL aMapSort :=  AClone( ::aMap )
	
	ASort( aMapSort,,,{|x,y| x[ MAP_ORDER ] < y[ MAP_ORDER ]} )
	
RETU aMapSort

METHOD ListRoute() CLASS TRoute

	LOCAl cHtml
	LOCAL aMapSort :=  AClone( ::aMap )
	LOCAL n, nLen  := len( ::aMap )
	
	ASort( aMapSort,,,{|x,y| x[ MAP_ORDER ] < y[ MAP_ORDER ]} )	
	
	?? '<h3>ListRoute()</h3>'	
	
	cHtml := '<style>'
	cHtml += '#routes tr:hover {background-color: #ddd;}'
	cHtml += '#routes tr:nth-child(even){background-color: #e0e6ff;}'
	cHtml += '#routes { font-family: "Trebuchet MS", Arial, Helvetica, sans-serif;border-collapse: collapse; width: 100%; }'
	cHtml += '#routes thead { background-color: #425ecf;color: white;}'
	cHtml += '</style>'
	cHtml += '<table id="routes" border="1" cellpadding="3" >'
	cHtml += '<thead ><tr><td align="center">Order</td><td align="center">Metodo</td><td>Id</td><td>Route</td><td>Controller</td><td>Query</td><td>Parameters</td></tr></thead>'
	cHtml += '<tbody >'
	
	FOR n := 1 TO nLen 		
		cHtml += '<tr>'
		cHtml += '<td align="center">' + ltrim(str(aMapSort[n][ MAP_ORDER ])) + '</td>'
		cHtml += '<td align="center">' + aMapSort[n][ MAP_METHOD ] + '</td>'
		cHtml += '<td>' + aMapSort[n][ MAP_ID ] + '</td>'
		cHtml += '<td>' + aMapSort[n][ MAP_ROUTE ] + '</td>'
		cHtml += '<td>' + aMapSort[n][ MAP_CONTROLLER ] + '</td>'
		cHtml += '<td>' + aMapSort[n][ MAP_QUERY ] + '</td>'
		cHtml += '<td>' + valtochar(aMapSort[n][ MAP_PARAMS ]) + '</td>'
		cHtml += '</tr>'
	NEXT		
	
	cHtml += '</tbody></table><hr>'
	
	?? cHtml
	
RETU ''

METHOD Listen() CLASS TRoute

	LOCAL n, nLen 			:= len( ::aMap )
	LOCAL cMethod 			:= ::oRequest:Method()
	LOCAL cRoute, aRoute
	LOCAL cURLQuery 		:= ::oRequest:GetQuery()
	LOCAL cURLFriendly 		:= ::oRequest:GetUrlFriendly()
	LOCAL nMask, nOptional, nPosParam, nPosMapingQuery
	LOCAL cParamsMap, aParamsMap, nParamsMap, aParamsQuery, cParamURL, aParamsURL, cParamsInQuery, nParamsQuery
	LOCAL uController 		:= ''
	LOCAL nJ, nPar
	LOCAL hParameters 		:= {=>}
	LOCAL cParamName
	LOCAL aRouteSelect 		:= {}
	LOCAL lFound 			:= .F.
	LOCAL cMap, nIni, nFin, bSort
	LOCAL cUrlDev
	
	if substr(lower( cUrlQuery ), 1, 7 ) == 'mercury' 

		cUrlDev := TApp():cUrl + '/lib/mercury/mercury_dev/'
				
		AP_HeadersOutSet( "Location", cUrlDev + 'm_main'  )
		ErrorLevel( 302 ) 	//	REDIRECTION 
		QUIT					

	endif
	
	
	//	Buscamos en la lista de Maps, cualquier RUTA que coincida
	//	con la Query que nos han pasado. Tambien ha de coincidir
	//	con el method llamado, que en principio sera GET/POST 
	
	LOG ' '
	LOG 'TRoute:Listen()'
	LOG '==============='
	LOG 'METHOD: ' + cMethod		
	LOG 'Query URL: ' + cUrlQuery		
	LOG 'Friendly URL: ' + cUrlFriendly		
	
	//	Analizamos todas las rutas. Inicialmente solo se analizaban las del mismo método
	//	pero se ha detectado que en una vista se puede pedir Route() de otros metodo.
	
	//_GTrace( 'Listen Ini' )
	
	if nLen == 0	//No Routes...
		quit
	endif


	FOR n := 1 TO nLen 
	
		aRoute 		:= ::aMap[n]			
	
		cRoute 		:= aRoute[ MAP_ROUTE ]										
		
		nMask 		:= At( '(', cRoute )
		nOptional 	:= At( '[', cRoute )
		nPosParam	:= Min( nMask, nOptional )
		
		IF ( nMask > 0 .AND. nOptional > 0 )
			nPosParam := Min( nMask, nOptional )
		ELSE
			nPosParam := Max( nMask, nOptional )			
		ENDIF
		
		IF nPosParam > 0 		
			cMap 		:= Substr( cRoute, 1, nPosParam-2 )
			cParamsMap 	:= Substr( cRoute, nPosParam )
			aParamsMap  := HB_ATokens( cParamsMap, '/' )
		ELSE				
			cMap 		:= cRoute
			cParamsMap 	:= ''
			aParamsMap  := {}				
		ENDIF
		
		nParamsMap	:= len( aParamsMap )
		
		//	Extraemos los nombres de campos
		
			FOR nJ := 1 TO nParamsMap
			
				//	Extraer valor de los campos entre ( ... )
				
				nIni := At( '(', aParamsMap[nJ] )
				nFin := At( ')', aParamsMap[nJ] )
				
				IF ( nIni > 0 .and. ( nFin > nIni ) )
				
					cParamName := Alltrim(Substr( aParamsMap[nJ] , nIni + 1, nFin - nIni - 1 ))
					
					aParamsMap[nJ] := cParamName 						
				
				ENDIF
				
			NEXT

		//	------------------------------------------------------------
		
		::aMap[n][ MAP_QUERY ] := alltrim(cMap)
		::aMap[n][ MAP_PARAMS] := aParamsMap		
		
	NEXT
	
	//	Ordenamos primero las URLS largas por si coinciden parte de ellas
	//	con cortas..
	//	Si tenemos estos 2 maps:
	//	compras/customer/
	//	compras/customer/view/(id?)
	//
	//	y en la url ponemos -> http://localhost/hweb/apps/shop/compras/customer/view 
	//	coincidiria el primer map, por esos chequearemos primero las mas largas

	bSort := {| x, y | lower(x[ MAP_QUERY ]) >= lower(y[ MAP_QUERY ]) }
	
	ASort( ::aMap,nil,nil, bSort )	
	
	nLen := len( ::aMap )
	
	FOR n := 1 TO nLen 	
		
		//	Tratamos elemento Map
		
			aRoute 		:= ::aMap[n]
			cMap 		:= aRoute[ MAP_QUERY ]	


			IF  aRoute[ MAP_METHOD ] == cMethod

				//	Buscaremos que el map exista en la query, p.e.
				//	Si tenemos oRoute:Map( 'GET', 'compras/customer/(999)', 'edit@compras.prg' )	
				//	buscaremos 'compras/customer' si se encuentra en la URL .
				//	Si se encuentra será a partir de la posicion 1
				
					nPosMapingQuery := At( cMap, cUrlFriendly )
					
				//	URL 	=>  response/jsonyy/56
				//	cMap 	=>	response/json
				
				
				IF nPosMapingQuery == 1 .and. ( (len( cUrlFriendly ) == len( cMap )) .OR. ( len( cUrlFriendly ) > len( cMap ) .and. substr( cUrlFriendly, len(cMap)+1, 1 ) == '/' ))	//	Existe
				
		
					LOG 'MAPPING MATCHING ==> ' + cMap 
				
					DO CASE
					
						CASE cMethod == 'GET'
				
							aParamsMap 	:= aRoute[ MAP_PARAMS ]				
							nParamsMap	:= len( aParamsMap )
							
							LOG 'Total Param Maps: ' + ltrim(str(nParamsMap))
							LOG 'Parameters Map: ' + ValtoChar( aParamsMap )

							//LOG 'Map Params: ' + cParamsMap						
							
							//	Trataremos los parámetros a ver si cumplen el formato...

								
								//	Se habria de validar estos parámetros que si hay algun opcional, 
								//	despues no puede haber uno obligatorio
								//	(999)/[(a-z)]/(aa)   -> NO (El 2 es opcional y hay un 3 param
								
								
								//	---------------------------
								
							//	Parámetros de la URL
							
								cParamsInQuery 	:= Substr( cUrlFriendly, len(cMap)+2 )
								
								IF !empty( cParamsInQuery )							
									aParamsQuery	:= HB_ATokens( cParamsInQuery, '/' )
									nParamsQuery	:= len( aParamsQuery )
								ELSE
									aParamsQuery	:= {}
									nParamsQuery	:= 0					
								ENDIF
								
								LOG 'Total Params URL: ' + cParamsInQuery
								LOG 'aParam URL: ' + ValToChar( aParamsQuery )											
							
							
							
							//	Se habra de mirar si matching parmaetros URL con parametros Mapping
							//	Condiciones
							//	Si hay definidos en el Mapping 3 parámetros, se habran de cumplir los 3.
							//	Si uno de ellos es opcional, los que le preceden han de ser opcionales...
							//	p.e.:
							//	(999)/(a-z)/[(u)]
							//	Como minimo ha de haber los mismos parametros en la url que el map. (puede
							//	haber algun param del map que sea opcional
							//	---------------------------------------------------------------------------
					
								IF nParamsQuery == nParamsMap

									hParameters := {=>}
								
									FOR nJ := 1 TO nParamsMap
				
									
										cParamName := aParamsMap[nJ] 
										
										hParameters[ cParamName ] := aParamsQuery[ nJ ]													
										
										//	Al final del proceso de recogida de parámeros, los pondremos dentro
										//	del objeto oRequest:hGet. Asi si se desea se podran recuperar desde
										//	otro punto del programa
										
											::oRequest:hGet := hParameters
										
									NEXT									
				
									//	Si tenemos formateos se habrian de validar
									//	Si el parámetro cumple la condicion de formateo..., p.e.
									//	Si (999) el parametro solo ha de tener numeros y no mas 3
									
									//	...
								
									//	Si tenemos todos los parametros correctos y cumplen el mapeo, 
									//	gestionamos el controlador a ejecutar...
									
									//	Cojeremos el 5 parámetro del mapeo. Podrá ser un puntero a 
									//	función o un controlador. El formato del controlador será
									// at the moment "metodo@fichero" p.e. -> edit@compras_controller.prg
									
										uController 	:= aRoute[ MAP_CONTROLLER ]								
										aRouteSelect 	:= aRoute	

										lFound 			:= .T.
									
									//	En este punto ya no habria de mirar ningun posible Map mas...
									
									EXIT
									
								ELSE 
								
									LOG 'Parámetros URL <> Mapp'
								
								ENDIF
								
						CASE cMethod == 'POST'

							hParameters 	:= ::oRequest:PostAll()
							uController 	:= aRoute[ MAP_CONTROLLER ]
							aRouteSelect 	:= aRoute
							lFound 			:= .T.
							
							//	En este punto ya no habria de mirar ningun posible Map mas...
							
							EXIT
						
						ENDCASE
					
				ELSE
				
				
				ENDIF	
			
			ENDIF									
		
	NEXT
	
	//	Si existe un controlador lo ejecutaremos		
	
	IF lFound 
	
		IF !empty( uController )	
		
			LOG 'Controlador : '	+ valtochar( uController )	
			LOG 'Parameters: ' 	+ valtochar( hParameters )		
			LOG 'Call :Execute() '
			
			//	En este punto tenemos los parametros GET (inyectados) y/o POST
			//	Actualizaremos el REQUEST
			
				::oRequest:LoadRequest()
				
			//	-----------------------------
			//_GTrace( 'Listen Found: ' + valtochar( uController)  )
			
			::Execute( uController, hParameters, aRouteSelect )
			
		ELSE		
			::ShowError( 'No se ha especificado controller en ID => ' + aRouteSelect[ MAP_ID ] )
		ENDIF
		
	ELSE	

		LOG 'No existe ruta => ' + cUrlFriendly + ', method: ' + cMethod
	
		IF App():lLog == .F.
			::oResponse:SendCode( 404 )
		ENDIF
		
		QUIT
	
	
	ENDIF		

RETU NIL

//	En principio TRouter se ejecuta desde la raiz del programa...
//	En lugar de cojer ap_getenv( path prog), podemos cojer el path del cgi script_filename

METHOD Execute( cController, hParam, aRouteSelect, lTEST, oNewRequest, oNewResponse ) CLASS TRoute

	//	Por defecto la carpeta de los controladores estara en srv/controller
	
	LOCAL cPath := App():cPath + App():cPathController
	LOCAL oTController, oView
	LOCAL cProg, cCode, cFile, cNameClass
	LOCAL cAction := ''
	LOCAL nPos
	LOCAL nPosFunc
	LOCAL cType		:= ''
	LOCAL oInfo := {=>}
	LOCAL oExecute
    LOCAL cHBheaders1 := "~/harbour/include"
    LOCAL cHBheaders2 := App():Path() + "/include"
	LOCAL z
	
	DEFAULT lTEST := .F.

	LOG ' '
	LOG 'TRoute():Execute()'
	LOG '=================='
	LOG 'Headers: ' + cHBheaders2
	
	LOG 'Exec: ' + cController

	//	Chequeamos de que tipo es el controller
	//	tipo clase -> @
	//	tipo function -> ()
	//	Por defecto sera function
	
		nPos := At( '@', cController )
		
		IF ( nPos >  0 )
			
			cAction := alltrim( Substr( cController, 1, nPos-1) )
			cFile 	:= alltrim( Substr( cController, nPos+1 ) )
			cType	:= 'class'
		
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
	
	//	Si es una View la ejecutamos y salimos...
	
		IF cType == 'view' 
			LOG 'EJECUTO VIEW -> ' + cController
			oView := TView():New()
			oView:Exec( cController )
			RETU nil
		ENDIF
		
	//	Si es una clase o function....

	cProg := cPath + cFile
	
	
	LOG 'Program: ' + cProg	
	LOG 'Tipo Controller: ' +  cType	
	LOG 'Action: ' + cAction	
	LOG 'Exist file ? : ' + ValToChar(file( cProg ))
	
	IF File ( cProg )	
	
		IF cType == 'class'			

				cNameClass := cFileNoExt( cFileNoPath( cFile ) )

			//	Opcion acceso Controller via Clases
			
				cCode := "#include 'hbclass.ch'" + HB_OsNewLine()
				cCode += "#include 'hboo.ch' " + HB_OsNewLine()  
				
				cCode += "STATIC __lAutenticate" + HB_OsNewLine()
				cCode += "FUNCTION __RunController( o )" + HB_OsNewLine()  
				cCode += "	LOCAL oC"  + HB_OsNewLine() 
				cCode += "	__lAutenticate := .T." + HB_OsNewLine()  
				cCode += "	oC := " + cNameClass + "():New( o )" + HB_OsNewLine() 
				
				IF !Empty( cAction )				
			
					cCode += "	IF __objHasMethod( oC, '" + cAction + "' ) "  + HB_OsNewLine() 
					cCode += "		IF __lAutenticate" + + HB_OsNewLine() 
					cCode += "		    oC:" + cAction + "(o) "  + HB_OsNewLine() 
					cCode += "		ENDIF" + HB_OsNewLine() 
					cCode += "	ELSE "  + HB_OsNewLine() 
					cCode += "		App():ShowError( 'Method <b>" + cAction  + "()</b> not defined in " + cFile + " controller.', 'Controller Error!' ) "  + HB_OsNewLine() 				
					//cCode += "		QUIT "  + HB_OsNewLine() 				
					cCode += "	ENDIF "  + HB_OsNewLine() 
				
				ENDIF
				
				cCode += "RETU NIL" + HB_OsNewLine() + memoread( cProg )

		ELSE

				cCode := memoread( cProg )

		ENDIF
		
		//	-----------------------------------

		oTController 						:= TController():New( cAction, hParam )
		oTController:oRoute  				:= SELF
		oTController:oRequest  			:= ::oRequest
		oTController:oResponse 			:= App():oResponse 		
		oTController:oMiddleware		:= App():oMiddleware
		oTController:aRouteSelect  		:= aRouteSelect	
		
		App():oRequest := ::oRequest	//	Si no, TValidator no captura bien el App():oRequest
		
		oTController:InitView()
			
			IF valtype( ::bLog ) == 'B'
				Eval( ::bLog, oTController, cAction )
			ENDIF		
		
		
		LOG 'Exec :Controller() ' + cController
		LOG 'Code : ' + cCode
		

		oInfo[ 'file' ] := cFile
		oInfo[ 'code' ] := cCode
		
		
		
		WHILE zReplaceBlocks( @cCode, ("{"+"%"), ("%"+"}"), oInfo, oTController )	
	
		END						

		IF lTEST

		ELSE

			zExecute( cCode, oInfo, oTController )
		ENDIF

	ELSE
	
		::ShowError( "Doesn't exist controller ==> <strong> " + cFile + '</strong>' )
		LOG 'Error: No existe Controller: ' + cFile 
	
	ENDIF

RETU NIL


FUNCTION App_Url()

	LOCAL cPath := AP_GETENV( 'PATH_URL' )
	
	IF empty( cPath )
		cPath := AP_GETENV( 'REQUEST_URI' )
		cPath := _cFilePath( cPath )
		cPath := Substr( cPath, 1, len(cPath)-1 ) 		//	Remove last '/'
	ENDIF

retu cPath

FUNCTION  Route( cRoute, aParams ) 

	LOCAL aRoute
	LOCAL aDefParams, nDefParams, cDefParam
	LOCAL cUrl 	:= ''
	LOCAL aMap 	:= App():oRoute:aMap
	LOCAL lError 	:= .F.
	LOCAL lFound	:= .F.
	LOCAL hError 	:= {=>}
	LOCAL nI
	
	__defaultNIL( @cRoute, '' )
	__defaultNIL( @aParams, {=>} )
	
	FOR EACH aRoute IN aMap
	
		IF aRoute[ MAP_ID ] == cRoute
		
			lFound := .T.
		
			//	URL Base
			
				IF aRoute[ MAP_QUERY ] <> '/' 	//	Default page		
					cUrl := App_Url() + '/' + aRoute[ MAP_QUERY ]
				ELSE
					cUrl := App_Url() + '/' 
				ENDIF
	
			// 	Cuantos parámetros tiene la Ruta
			
				aDefParams := aRoute[ MAP_PARAMS ]
				nDefParams := len( aParams )
	
				
			// 	Si los parámetros definidos == parametros recibidos -> OK
			
				IF nDefParams == len( aParams )
				
						FOR nI := 1 TO nDefParams

							cDefParam := aDefParams[nI]
							
							IF HB_HHasKey( aParams, cDefParam )

								cUrl += '/'
								cUrl += ValToChar( aParams[ cDefParam ] ) 								
								
							ELSE	
							
								//	Generamos ERROR ?	=> Yo diria que si
								
								lError 	:= .T.
								
								hError[ 'id' ]		    := cRoute
								hError[ 'define' ]		:= aRoute[ MAP_ROUTE ]
								hError[ 'descripcion' ]	:= 'Parámetro definido<strong> ' + cDefParam + ' </strong>no existe'
							
							ENDIF						
						
						NEXT				
				
				ENDIF
				
			//	Salir...
				exit
			
	
		ENDIF
		
	NEXT	
	
	//	Si NO tenemos ningun error devolvemos la URL
	
		IF lFound .AND. !lError			
			RETU cUrl
		ELSEIF !lFound .AND. lError
			RouteError( hError )
		ENDIF	
	
	
RETU ''

FUNCTION RouteError( hError )
	LOCAL nI
	LOCAL cHtml := ''

	cHtml := '<meta charset="utf-8">'
	cHtml += '<body style="background-color: #ececec;">'
	cHtml += '<h2>Route Error !<hr></h2>'	
	cHtml += '<table border="1" style="background-color: white;">'	
	
	FOR nI := 1 TO len( hError )
	
		cHtml += '<tr>'
		cHtml += '<td><b>' + hb_HPairAt( hError, nI )[1] + '</b></td>'
		cHtml += '<td>' + hb_HPairAt( hError, nI )[2] + '</td>'
		cHtml += '</tr>'
		
	NEXT

	cHtml += '</table>' 	
	cHtml += '</body>' 
	
	?? cHtml
	

	//? procname(2) 
	//? procline(2)
	
	QUIT
	
RETU NIL

static function M_Menu() 

	local c := ''

	
	TEXT TO  c 

		<h1>Mercury assitance...</h1><hr>
		<ul style="list-style-type:disc;">
			<li><a href="mercury_init" >Mercury Init</a></li>
			<li><a href="#t1">Test 1</a></li>
			<li><a href="#t3">Test 3</a></li>
		</ul>
		
		<script>
			function t2() {
				alert('ep')
			}
		</script>
		
		
	ENDTEXT
	
	?? c

retu nil

static function M_Test() 

	local c := ''

	
	TEXT TO  c 

		<h1>Mercury assitance...</h1><hr>
		Test !

	ENDTEXT
	
	?? c

retu nil
