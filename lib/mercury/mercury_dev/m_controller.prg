function Controller( cMsg, aParams ) 

	local cPathTemplate 	:= HB_GetEnv( 'PRGPATH' ) + '/templates' 
	local cRealPath 		:= AP_GETENV( 'DOCUMENT_ROOT' ) + AP_GETENV( 'PATH_APP' ) + '/src/controller'
	local cTemplate 		:= ''
	local cAction			:= ''
	local cNameController	:= ''
	local lRenew 			:= .F.

	if len( aParams ) == 0
		Send( _s('help controller error'), 'error' )
		retu nil
	endif		
	
	//	Parameters	---------------------------------------------
	//	new 	[<cNameController>] 	[<cOthertemplate>]
	
	cAction 			:= lower( alltrim(aParams[1]) )
	cNameController 	:= If ( len( aParams ) > 1, alltrim(aParams[2]) , '' )
	
	//	Validamos formato 
	
		if !empty( cNameController )
		
			if left( cNameController, 1 ) == '/' .or. left( cNameController, 1 ) == '\' 
				Send( _s('error /'), 'error' )
				retu nil
			endif
		
			if at( '.', cNameController ) > 0
				Send( _s( 'character error .'), 'error' )
				retu nil						
			endif					
		
		endif	

	//	----------------------------------------------------------
	

	do case
		case cAction == 'new' .or. cAction == 'renew'
	
			if empty( cNameController )
			
				Send( _s('controller name empty') )
				retu nil
				
			endif
			
			lRenew 		:= ( cAction == 'renew' )				
			
			cTemplate 	:= If ( len( aParams ) > 2, alltrim(aParams[3]) , 'controller.tpl' )
			

			if file ( cPathTemplate + '/' + cTemplate )
				cTemplate := memoread( cPathTemplate + '/' + cTemplate )				
				cTemplate := StrTran( cTemplate, '<$classname$>', cNameController )
			else
				Send( _s('template not found', cTemplate ) )		
				retu nil
			endif			
	
		case cAction == 'show'
		
			if empty( cNameController )
			
				Send( _s('controller name empty') )
				retu nil
				
			endif			
		
			cFile := cRealPath + '/' + cNameController + '.prg'

			if file ( cFile )
				cTemplate := memoread( cFile )											
			else
				Send( _s( 'controller not found', cNameController), 'error'  )		
				retu nil
			endif						

			c := StrTran( cTemplate, CRLF, '<br>' )			
			c := '<div class="code">' + c + '</div>'
			
			Send( _s( 'show controller' , cNameController, c ) )
			
			retu nil			
		
		case cAction == 'del'	
		
			if empty( cNameController )
			
				Send( _s('controller name empty') )
				retu nil
				
			endif			
		
			cFile := cRealPath + '/' + cNameController + '.prg'

			if file ( cFile )		
				if fErase( cFile ) == 0
					Send( _s( 'controller deleted' , cNameController ) )
				else
					Send( _s( 'controller deleted error', cNameController ), 'error' )
				endif
				
			else
			
				Send( _s( 'controller not found', cNameController), 'info'  )	
				
			endif
			
			retu nil
		
		case cAction == 'list'		
			
			ListController( cRealPath )			
			
			retu nil
		
		otherwise
		
			Send( _s( 'unknow parameter', aParams[1] ) , 'error' )		
			retu nil	
	endcase		

	
	//	Crearemos Controller !
	
	
	//	Chequear si existe Path Controller
	
		if ! IsDirectory( cRealPath )
		
			Send( _s( 'controller folder error'), 'error' )
			retu nil			
			
		endif
		
	//	Chequear si existe Path Virtual (por encima de /src/controller -> src/controller/clients/...
	
		CheckNameController( cRealPath, cNameController )	
	

	//	Chequear si existe el fichero controller
	
		cFile := cRealPath + '/' + cNameController + '.prg'
	
		if file( cFile ) .and. !lRenew
			Send( _s( 'controller exist renew', cNameController ), 'alert' )
			retu nil
		endif			
	
	//	Gravar Template		
	
		lSave := Memowrit( cFile, cTemplate )
		
	//	Resultado
	
		if lSave
			if lRenew
				Send( _s( 'controller recreated', cNameController ) )
			else
				Send( _s( 'controller created', cNameController ) )
			endif
		else
			Send( _s('controller created error')  )
		endif				

retu nil


function ListController( cPath )

	LOCAL cTxt		:= '<h3>Controller List</h3><hr>'	
	
	LoadDirectory( @cTxt, cPath + '/')
	
	cTxt += '<hr>'

	Send( cTxt, 'normal' )	
			
retu nil 

static function LoadDirectory( cTxt, cDir, cParent, nCount ) 

	LOCAL aDir 	:= Directory( cDir + '*.*', 'DHS' )
	LOCAL nI
	LOCAL cNameDir, cNameFile

	DEFAULT cParent 	TO '#'
	DEFAULT nCount 	TO 0

	ASort( aDir, ,, {|x,y| x[5] < y[5] } )
	
	nCount++
	
	for nI := 1 To len(aDir)
	
		if aDir[nI][1] == '.' .or. aDir[nI][1] == '..'
		
		else
		
			if aDir[nI][ 5 ] == 'D'

				cId 		:= nCount
				cNameDir 	:= aDir[ni][1]
			
				cTxt 		+= Replicate( '&nbsp;', nCount ) + '<i class="far fa-folder-open"></i>&nbsp;' + cNameDir + '<br>'

				LoadDirectory( @cTxt, cDir + cNameDir + '/', cId, nCount )
			
			else

				cNameFile 	:= aDir[ni][1]
				
				cTxt 		+= Replicate( '&nbsp;', nCount ) + '<i class="far fa-file-code"></i>&nbsp;' + cNameFile + '<br>'
			endif		
		
		endif
		
	next

retu nil

//	Chequeamos si se pasa un dir/dir/controller 

function CheckNameController( cRealPath, cNameController )

	local nI 
	local cDir  	
	
	//	Chequeamos si especificamos una barra al inicio --> /customer/users		
	
	aDirs := hb_ATokens( cNameController, '/' )	
	
	if len( aDirs ) == 1 
		retu nil
	endif
	
	cDir := cRealPath
	
	for nI := 1 To ( len( aDirs ) - 1 )
		
		cDir += '/' + aDirs[nI] 		
		
		if ! IsDirectory( cDir )
			if MakeDir( cDir ) == 0			
				Send( _s( 'dir create', aDirs[nI] ) )
			else
				Send( _s( 'dir create error', cDir ), 'error' )				
				quit
			endif
		else
			exit
		endif		
	
	next

retu nil

