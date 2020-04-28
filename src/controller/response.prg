CLASS Response

	DATA cDef		INIT 'Dummy text of Response...'

	METHOD New() 	CONSTRUCTOR
	
	METHOD json() 
	METHOD xml() 
	METHOD html() 
	METHOD redirect() 				
	METHOD error401() 				
   
ENDCLASS

METHOD New( o ) CLASS Response	

RETU SELF

METHOD json( o ) CLASS Response

	LOCAL hResponse := { 'id' => 123, 'name' => 'James Bond', 'last' => date() }

	o:oResponse:sendjson( hResponse )
	
RETU NIL

METHOD xml( o ) CLASS Response

	LOCAL cXml := '<?xml version="1.0" encoding="UTF-8"?>'	
	
	cXml += '<user>'
	cXml += '<id>123</id>'
	cXml += '<name>Maria de la O</name>'
	cXml += '<phone>+34696948909</phone>'
	cXml += '<dpt>TIC</dpt>'
	cXml += '</user>'
	
	o:oResponse:sendxml( cXml )
	
RETU NIL	

METHOD html( o ) CLASS Response

	LOCAL cHtml

TEMPLATE PARAMS cHtml

<!DOCTYPE html>
<html lang="en">
<head>
  <title>Bootstrap Example</title>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.4.0/css/bootstrap.min.css">
  <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.4.1/jquery.min.js"></script>
  <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.4.0/js/bootstrap.min.js"></script>
</head>
<body>
  
<div class="container">
  <h1>My First Bootstrap Page</h1>
  <p>This part is inside a .container class.</p> 
  <p>The .container class provides a responsive fixed width container.</p>           
</div>

</body>
</html>

ENDTEXT
	
	o:oResponse:sendhtml( cHtml )
	
RETU NIL	

METHOD redirect( o ) CLASS Response

	o:oResponse:redirect(  Route( 'my_new' ) )

RETU NIL

METHOD Error401( o ) CLASS Response

	o:oResponse:sendcode( 401 )

RETU NIL
	
	
