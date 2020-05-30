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
	//	new  <cDirTarget> 	[<cNameProject>]
	
	cAction 		:= lower( alltrim(aParams[1]) )	
	cDirTarget		:= If ( len( aParams ) > 1, alltrim(aParams[2]) , '' )
	cNameProject 	:= If ( len( aParams ) > 2, alltrim(aParams[3]) , 'default' )

	Send( AP_GetEnv( 'PATH_MERCURY' ) )
	
	//Send( 'Action: ' + cAction )
	//Send( 'Project: ' + cNameProject )
	//Send( 'Path: ' + cPathProject )
	
	do case
		case cAction == 'new' .or. cAction == 'renew'
			
			lRenew := ( cAction == 'renew' )							
			cFile 	:= cPathProject + '/' + cNameProject + '/files.txt'

			if file ( cFile )
				//PrjCopyFiles( cPathProject + '/' + cNameProject, cFile, lRenew  )				
				PrjNew( cDirTarget, cPathProject + '/' + cNameProject, cFile, lRenew  )				
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

static function PrjNew( cDirTarget , cPathSource, cFile, lRenew  )

	local cRealPath 	:= AP_GETENV( 'DOCUMENT_ROOT' ) + '/' + cDirTarget 
	local cTxt 		:= memoread( cFile )
    local nLines 		:= mlcount( cTxt )
	local aError		:= {}
	local lExiste, nError, nI, cLine

	DEFAULT cDirTarget TO '' 
	
	if empty( cDirTarget )
		Send( 'No specify Dir target', 'error' )
		retu nil
	endif	
	
	lExiste := IsDirectory( cRealPath )
	
	if lExiste .and. !lRenew 
		Send( 'Dir exist: ' + cRealPath, 'error' )
		retu nil
	endif
	
	if !lExiste
	
		nError := MakeDir( cRealPath ) 
		
		if nError == 0
			Send( 'Dir project created: ' + cDirTarget )	
		else
			Send( 'Error while created dir project ' + cDirTarget, 'error' )
			retu nil
		endif
	
	endif
	

		
	//	2ª Pass Execute operations	
	
		Send( 'Generating new Project<hr>', 'info' )
	
		aError := {}
	
		for nI = 1 TO nLines

			cLine := alltrim(memoline( cTxt, nil, nI ))
			
			if substr( cLine, 1, 1 ) <> '#'
			
				if right( cLine, 1 ) == '/'		//	Directory
				
					cLine := Substr( cLine, 1, len(cLine)-1 )
					
					if !IsDirectory( cRealPath + '/' + cLine )
					
						nError := MakeDir( cRealPath + '/' + cLine ) 
						
						if nError == 0
							Send( 'Dir created: ' + cRealPath + '/' + cLine )
						else
							Aadd( aError, 'Error creating dir: ' + cLine  + '   Error( ' + ltrim(str(nError)) + ')' )							
						endif
					
					endif

				else 
				
					cSource := cPathSource + '/' + cLine
					cTo 	 := cRealPath + '/' + cLine				
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

		else
		
			//	Creamos directory lib/mercury y copiamos libreria actualitzada
			
				Send( '-------------' )
				Send( cRealPath + '/lib' )
				Send( cRealPath + '/lib/mercury' )
			
				send( valtochar( MakeDir( cRealPath + '/lib' ) ))
				send( valtochar( MakeDir( cRealPath + '/lib/mercury' ) ))
			
				cOrigen := AP_GETENV( 'DOCUMENT_ROOT' ) + AP_GetEnv( 'PATH_MERCURY' ) 
				
				send( cOrigen )
				
				hb_FCopy( cOrigen + '/mercury.ch'  , cRealPath + '/lib/mercury/mercury.ch' )
				hb_FCopy( cOrigen + '/mercury.hrb' , cRealPath + '/lib/mercury/mercury.hrb' )
				
		
		
			//	Crearemos fichero .htaccess
			
			cHtaccess := BuildHtaccess( cDirTarget )
			
			Hb_Memowrit( cRealPath + '/.htaccess', cHtaccess )
			Send( '.htaccess created !' )
			
		endif		
		
		Send( '<hr>', 'normal' )			


retu nil 


function BuildHtaccess( cDirTarget ) 

	local cHtaccess := ''
	
	cDirTarget := '/' + cDirTarget
	
	TEXT TO cHtaccess 
# --------------------------------------------------------------------------
# CONFIGURACION RUTAS PROGRAMA  (Relative to DOCUMENT_ROOT)
# --------------------------------------------------------------------------
SetEnv APP_TITLE           "Mercury v1.0"
SetEnv PATH_URL            "<$PATH$>"
SetEnv PATH_APP            "<$PATH$>"
SetEnv PATH_DATA           "<$PATH$>/data/"


# --------------------------------------------------------------------------
# Impedir que lean los ficheros del directorio
# --------------------------------------------------------------------------
Options All -Indexes


# --------------------------------------------------------------------------
# Pagina por defectos
# --------------------------------------------------------------------------
DirectoryIndex index.prg main.prg

<IfModule mod_rewrite.c>
	RewriteEngine on
	RewriteCond %{REQUEST_FILENAME} !-f
	RewriteCond %{REQUEST_FILENAME} !-d
	RewriteRule ^(.*)$ index.prg/$1 [L]
</IfModule>		
	ENDTEXT
	
	cHtaccess := StrTran( cHtaccess, '<$PATH$>', cDirTarget )

retu cHtaccess


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
