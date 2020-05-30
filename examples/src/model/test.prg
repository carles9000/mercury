
//----------------------------------------------------------------------------//

CLASS TestModel 

	DATA cAlias	

	METHOD New()             		CONSTRUCTOR

	METHOD GetZip( cId )
	
ENDCLASS

//----------------------------------------------------------------------------//

METHOD New() CLASS TestModel

	USE ( AppPathData() + 'test.dbf' ) SHARED NEW VIA 'DBFCDX'
	SET INDEX TO 'test.cdx'
	
	::cAlias := Alias()
	

RETU SELF

//	-----------------------------------------------

METHOD GetZip( cZip ) CLASS TestModel

	local hRow 	:= {=>}
	
	DEFAULT cZip TO  ''
	
	(::cAlias)->( OrdSetFocus( 'zip' ) )
	(::cAlias)->( DbSeek( cZip ) )
	
	if (::cAlias)->zip == cZip
		hRow := { 	'first' 	=> (::cAlias)->first,;
					'last' 		=> (::cAlias)->last,;
					'street'	=> (::cAlias)->street,;
					'city' 		=> (::cAlias)->city,;
					'zip' 		=> (::cAlias)->zip,; 
					'salary'	=> (::cAlias)->salary ;
				}
	endif

RETU hRow

//	-----------------------------------------------
