function Project( cMsg, aParams ) 

	local cNameProject		:= ''
	local cAction			:= ''
	local cPathProject	 	:= HB_GetEnv( 'PRGPATH' ) + '/projects' 
	
	local cTemplate 		:= ''
	local cRealPath 		:= AP_GETENV( 'DOCUMENT_ROOT' ) + AP_GETENV( 'PATH_APP' ) + '/src/controller'
	local lRenew 			:= .F.

	if len( aParams ) == 0
		Send( 'Project wrong. See => help project  or  /project ', 'error' )
		retu nil
	endif		
	
	//	Parameters	---------------------------------------------
	//	new 	[<cNameController>] 	[<cOthertemplate>]
	
	cAction 		:= lower( alltrim(aParams[1]) )	
	cNameProject 	:= If ( len( aParams ) > 1, alltrim(aParams[2]) , 'default' )
	
	//Send( 'Action: ' + cAction )
	//Send( 'Project: ' + cNameProject )
	//Send( 'Path: ' + cPathProject )
	
	do case
		case cAction == 'new' .or. cAction == 'renew'
			
			lRenew 	:= ( cAction == 'renew' )							
			cFile 	:= cPathProject + '/' + cNameProject + '/files.txt'

			if file ( cFile )
				PrjCopyFiles( cPathProject + '/' + cNameProject, cFile, lRenew  )				
			else
				Send( 'Template file not found: ' + cFile  )		
			endif	
			retu nil
			
		case cAction == 'list'		
			
			ListProject( cPathProject )			
			
			retu nil			
			
		otherwise
		
			Send( 'Unknown parameter ' +  aParams[1] , 'error' )		
			retu nil				
			
	endcase

retu nil 

static function PrjCopyFiles( cPathSource, cFile, lRenew  )

	local cPath 	:= AP_GETENV( 'DOCUMENT_ROOT' ) + AP_GETENV( 'PATH_APP' )
	local cTxt 		:= memoread( cFile )
    local nLines 	:= mlcount( cTxt )
	local nI, cLine
	local aError	:= {}
	
	//Send( 'PATH: ' + cPath )
	//Send( 'RENEW: ' + valtochar(lRenew) )
	
	//	1ª Pasada. Chequear si existe algun contenido
	
		for nI = 1 TO nLines

			cLine := alltrim(memoline( cTxt, nil, nI ))
			
			if substr( cLine, 1, 1 ) <> '#'
			
				if right( cLine, 1 ) == '/'		//	Directory
				
					cLine := Substr( cLine, 1, len(cLine)-1 )
					
					if ! IsDirectory( cPath + '/' + cLine )
					//	Send( 'Creare Dir: ' + cPath + '/' + cLine )
					endif
				else 
					if file( cPath + '/' + cLine )
						Aadd( aError, 'File exist: ' + cLine )	
					endif
				endif
			
			endif        
			
		next
	
		if len( aError ) > 0 .and. !lRenew 	
			Send( 'Atention !. Exist elements. If you want overwrite, please put -renew- command', 'error')
			for nI := 1 to len( aError )
				Send( aError[nI], 'info')
			next
			retu nil
		endif
	
	//	2ª Pass Execute operations

		Send( 'Generating new Project<hr>', 'info' )
	
		aError := {}
	
		for nI = 1 TO nLines

			cLine := alltrim(memoline( cTxt, nil, nI ))
			
			if substr( cLine, 1, 1 ) <> '#'
			
				if right( cLine, 1 ) == '/'		//	Directory
				
					cLine := Substr( cLine, 1, len(cLine)-1 )
					
					if !IsDirectory( cPath + '/' + cLine )
					
						nError := MakeDir( cPath + '/' + cLine ) 
						
						if nError == 0
							Send( 'Dir created: ' + cPath + '/' + cLine )
						else
							Aadd( aError, 'Error creating dir: ' + cLine  + '   Error( ' + ltrim(str(nError)) + ')' )							
						endif
					
					endif

				else 
				
					cSource := cPathSource + '/' + cLine
					cTo 	:= cPath + '/' + cLine				
				//send( cSource )
					if file( cSource )
						nError := hb_FCopy( cSource, cTo )
						
						if nError == 0
							Send( 'Created file: ' + cline  )	
						else
							Aadd( aError, "Error creating file: " + cLine + '   Error( ' + ltrim(str(nError)) + ')' )
						
						endif
					else
						Aadd( aError, "Source file doesn't exist: " + cLine )
					endif
				endif
				
			else	
			
				Send( 'Coment: ' + cLine, 'info' )
			
			endif        
			
		next
		
	//	Report status
	
		if len( aError ) > 0 
			Send( 'Error process!', 'error')
			for nI := 1 to len( aError )
				Send( aError[nI], 'info')
			next			
		endif		
		
		Send( '<hr>', 'normal' )		

retu nil


function ListProject( cPath )

	local cTxt	:= '<h3>Project List</h3><hr>'	
	local aDir 	:= Directory( cPath + '/*.*', 'DHS' )
	local nI, cNameDir
	
	for nI := 1 To len(aDir)
	
		if aDir[nI][1] == '.' .or. aDir[nI][1] == '..'
		
		else
		
			if aDir[nI][ 5 ] == 'D'

				cNameDir 	:= aDir[nI][1]			
				cTxt 		+=  '&nbsp;<i class="far fa-folder-open"></i>&nbsp;' + cNameDir + '<br>'	

			endif		
		
		endif
		
	next
	
	cTxt += '<hr>'

	Send( cTxt, 'normal' )	
			
retu nil 
