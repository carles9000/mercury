Versión modHarbour compatible con Mercury
=========================================

1.- Copy files

	copy mod_harbour.so to c:\xampp\apache\modules\
	copy libharbour.dll to c:\xampp\htdocs\

2.- Config c:\xampp\apache\conf\httpd.conf 

	LoadModule harbour_module modules/mod_harbour.so 

	SetEnv LIBHARBOUR "c:\xampp\htdocs\libharbour.dll"
	SetEnv LIBHRB     "c:\xampp\htdocs\libharbour.dll" 

	<FilesMatch "\.(prg|hrb)$">
		SetHandler harbour
	</FilesMatch>
	
	
Mas informacion en https://modharbour.app/compass/search/Instalacion
