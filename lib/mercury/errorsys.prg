function GetErrorInfo( oError, cCode, oInfo ) 

	local cCodeError 	:= ''
	local lShowCode 	:= HB_GetEnv( 'SET_ERRORLEVEL' ) <> '1'
	local cHtml 		:= DoHeadError()
	local aLines, nI , n, nLine
	
	
	//? 'Errorlevel', HB_GetEnv( 'SET_ERRORLEVEL' ), valtype(  HB_GetEnv( 'SET_ERRORLEVEL' ) )
	//? oError
	
	if oError:subsystem == 'COMPILER'
	
		aLines := hb_ATokens( cCode, Chr( 10 ) )
		nLine  := val( Substr(oError:operation,6) )
		
		if nLine > 0 .and. nLine <= len(aLines)
			cCodeError := aLines[ nLine ]
		endif 
	else
	
		if valtype( oInfo ) == 'H' 							
		
			//cCodeError := cCode
			
			cCodeError := UHtmlEncode( oInfo[ 'code' ] )
			cCodeError := StrTran( cCodeError, '\n', '<br>' )
			cCodeError := StrTran( cCodeError, '\t', ' ' )			
			
			
		endif
		
	endif	
	
		
	if valtype( oInfo ) == 'H'
	
		TEXT TO cHtml PARAMS oInfo
		
			<tr>
				<td class="errortype"><b>File Source</b></td>
				<td class="errortxt"><$ oInfo[ 'file' ] $></td>
			</tr>				
			
		ENDTEXT
	
	endif
	
	if lShowCode
	
		TEXT TO cHtml PARAMS oError, cCodeError
		
			<tr>
				<td class="errortype"><b>Code</b></td>
				<td class="errortxt"><pre><$ cCodeError $></pre></td>
			</tr>		
			
		ENDTEXT
	
	endif
		
	
	TEXT TO cHtml PARAMS oError
	
		<tr>
			<td class="errortype"><b>Description</b></td>
			<td class="errortxt"><$ oError:description $></td>
		</tr>

		<tr>
			<td class="errortype"><b>Operation</b></td>
			<td class="errortxt"><$ oError:operation $></td>
		</tr>

	ENDTEXT

	if !empty( oError:filename )
	
		TEXT TO cHtml PARAMS oError
		
			<tr>
				<td class="errortype"><b>File</b></td>
				<td class="errortxt"><$ oError:filename $></td>
			</tr>

		ENDTEXT			
		
	endif
	
	TEXT TO cHtml PARAMS oError
		<tr>
			<td class="errortype"><b>Subsytem</b></td>
			<td class="errortxt"><$ oError:subsystem $></td>
		</tr>			
		
	ENDTEXT	
	
	if oError:subsystem == 'COMPILER' .AND. lShowCode
	
		TEXT TO cHtml 
			<tr>
				<td class="errortype"><b>Code</b></td>
				<td class="errortxt">
					<pre>
		ENDTEXT
		
		for nI := 1 to len( aLines )
			if nI == nLine 
				cHtml += '<b><span class="code_error">'
			endif
			
			cHtml += '<br>' + StrZero( nI, 4 ) + ' ' + aLines[nI]
			
			if nI == nLine 
				cHtml += '</span></b>'
			endif		
		next 						
		
		TEXT TO cHtml 		
					</pre>
				</td>
			</tr>
		ENDTEXT

	endif		
	
	
	TEXT TO cHtml 
				</table>
			</div>
		</body>
	ENDTEXT 	
	
	?? cHtml

	
retu ''

function DoHeadError() 

	local cHtml := ''

	TEXT TO cHtml 
		<meta charset="utf-8">
		<body style="background-color: #ececec;">
		<style>
			table {
				border-collapse: collapse;
			}

			table, th, td {
				border: 1px solid black;
			}
			
			#myerror {
				font-family: "Trebuchet MS", Arial, Helvetica, sans-serif;
				border-collapse: collapse;
				width: 100%;
			}

			#myerror td, #myerror th {
				border: 1px solid #ddd;
				padding: 8px;
			}

			#myerror tr:nth-child(even){background-color: #f2f2f2;}

			#myerror th {
				padding-top: 12px;
				padding-bottom: 12px;
				text-align: left;
				background-color: #4CAF50;
				color: white;
			}			
			
		    .errortype {
			    text-align: right;
				padding: 5px;
				width:200px;
				
		    }
			
		    .errortxt {
				padding: 5px;
				
			}
		  
			.content_error {		    
				width: 100%;
				overflow: auto;
			}
			
			.code_error {
				color: white;
				background-color: red;
			}			
			
		</style>
		<h2>Mercury Error<hr></h2>
		<div class="content_error">
			<table id="myerror" >
			<tr>
				<th style="text-align: right;">Description</th>
				<th >Value</th>
			</tr>			
		
	ENDTEXT 

retu cHtml 


function SetMercuryError( oError ) 
	

retu nil

function MercuryError( cDescription, cTitle )

    local oError := ErrorNew()
	local cHtml  := DoHeadError()

	oError:Subsystem   := "Mercury"
	oError:Severity    := 2	//	ES_ERROR
	oError:Description := cDescription 
	
	//	De momento funciona perfectamente solo mostrando el Error
	
		TEXT TO cHtml PARAMS cDescription, cTitle
		
			<tr>
				<td class="errortype"><b>Error</b></td>
				<td class="errortxt"><$ cTitle $></td>
			</tr>	

			<tr>
				<td class="errortype"><b>Description</b></td>
				<td class="errortxt"><$ cDescription $></td>
			</tr>				
			
		ENDTEXT	
	
	?? cHtml	

retu ''

function DoError( cDescription, oInfo, cOperation )

	local oError := ErrorNew()
	
	DEFAULT cOperation := ''
	
	oError:Subsystem   := "Mercury"
	oError:Severity    := 2	//	ES_ERROR
	oError:Operation   := cOperation
	oError:Description := cDescription 
	
	Eval( ErrorBlock(), oError, '', oInfo )
		
retu nil