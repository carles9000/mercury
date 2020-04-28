{% include( AP_GETENV( 'PATH_APP' ) + "/include/hbclass.ch" )  %}
{% include( AP_GETENV( 'PATH_APP' ) + "/include/hboo.ch" )  %}


CLASS TUsers 

	DATA oDb 

   METHOD  New() CONSTRUCTOR			
   
   METHOD  Get( n ) 

ENDCLASS

METHOD New() CLASS TUsers

	local	o := WDO():Dbf()
			o:cDefaultPath 	:= hb_getenv( 'PRGPATH' ) + '/data'				
			o:cDefaultRdd 	:= 'DBFCDX'	
	
	::oDb := WDO():Dbf( 'users.dbf', 'users.cdx' )


RETU Self

METHOD Get( n ) CLASS TUsers

	::oDb:Focus( 'ID' )
	::oDb:Seek( n )
	
RETU ::oDb:Load()

	

