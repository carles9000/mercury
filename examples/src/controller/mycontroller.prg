CLASS MyController

	METHOD New( oController )			CONSTRUCTOR

	METHOD Fruits( oController )
	METHOD IdZip( oController )
	
ENDCLASS   

//----------------------------------------------------------------------------//

METHOD New( oController ) CLASS MyController

RETU Self 


//----------------------------------------------------------------------------//

METHOD Fruits( oController ) CLASS MyController 

	local aFruits := { 'Banana', 'Apple', 'Pear', 'Cherry' }	
	

	oController:View( 'fruits.view', aFruits )

RETU nil

//----------------------------------------------------------------------------//

METHOD IdZip( oController ) CLASS MyController 

	local oTest	:= TestModel():New()
	local hRow		:= oTest:GetZip( '66205-6335' )		

	oController:View( 'user.view', hRow )

RETU nil

//----------------------------------------------------------------------------//
{% LoadFile( "/src/model/test.prg" ) %}
