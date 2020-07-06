#define REDIRECTION  	302

function main()
	local cHtml		:= ''
	local hParam 	:= ap_postpairs()
	local cCmd 		:= lower( HB_HGetDef( hParam, 'cmd', '' ) )

	DO CASE
		CASE cCmd == 'init'
			AP_HeadersOutSet( "Location", 'm_init'  )
			ErrorLevel( REDIRECTION ) 	
	ENDCASE
	
	
	TEXT TO cHtml 
	
<html lang="es">

   <head>  
		<meta charset="utf-8">
		<meta http-equiv="X-UA-Compatible" content="IE=edge">
		<meta name="viewport" content="width=device-width, initial-scale=1">
		<script  src="https://code.jquery.com/jquery-3.5.0.min.js"
			integrity="sha256-xNzN2a4ltkB44Mc/Jz3pT4iU1cmeR0FkXs4pru/JxaQ="
			crossorigin="anonymous"></script>		
		<link rel="stylesheet" href="lib/jstree/themes/default/style.min.css" />
		<script src="lib/jstree/jstree.js"></script>		
		<link rel="stylesheet" href="https://use.fontawesome.com/releases/v5.8.2/css/all.css" integrity="sha384-oS3vJWv+0UjzBfQzYUhtDYW+Pj2yciDJxpsK1OYPAYjqT085Qq/1cq5FLXAZQ7Ay" crossorigin="anonymous">			
		<link rel="stylesheet" type="text/css" href="https://fonts.googleapis.com/css?family=Architects+Daughter" />		
		<link rel="stylesheet" type="text/css" href="css/app.css" />		
   </head>

   <body>
		<div class="myhead">
			<img id="mylogo" src="images/mini_mercury.png">
			<span>Developer Site</span>			
			<hr>
		</div>
		
		<div id="content">			
			<img id="harbour" src="images/harbour.png"><br>
			<div id="log">
				<span style="color:#00d600;"><i class="fas fa-laptop-code"></i></span>&nbsp;System...			
			</div>
			
			<div id="entry">
				
				<input type="text" id="msg" placeholder="Write 'help' for suport..." >
				<button class='btn' onclick="validateCmd()" >Do it !</button>			
				
			</div>
			<!--<br><a href="https://fivetechsoft.github.io/mod_harbour/">modharbour.org</a>-->
		</div>
		
		<script>

			var aLog 		= []
			var aLogPoint	= -1
			
			$('#msg').keydown(function (e) {
			
				var arrow = { enter: 13 , up: 38 , down: 40 };
			
				console.log ( e.which )

				switch ( e.which ) {
				
					case arrow.enter :
						validateCmd()
						break;
						
					case arrow.up :					//	Up
						ShowUpLog()
						break;	

					case arrow.down :					//	Down
						ShowDownLog()
						break;						
			    }
			}); 			
			
			function ShowUpLog() {
				
				if ( aLog.length == 0 )
					return null
					
				if ( aLogPoint == -1 )
					aLogPoint = aLog.length - 1
				else
					aLogPoint--
				
				if ( aLogPoint == -1 ) {
					$('#msg').val('')
					return null
				}					
					
				$('#msg').val( aLog[aLogPoint] )					
			}
			
			function ShowDownLog() {
			
				if ( aLog.length == 0 )
					return null			
				
				if ( aLogPoint == -1 )
					aLogPoint = 0
				else
					aLogPoint++
				
				if ( aLogPoint >= aLog.length ) {
					$('#msg').val('')
					aLogPoint = -1
					return null
				}					
					
				$('#msg').val( aLog[aLogPoint] )					
			}			
		
			function validateCmd() {
			
				var cCmd = $( '#msg' ).val();
			 
				if ( cCmd == "") 
					return null;

				if ( cCmd.toLowerCase() == 'clean' || cCmd.toLowerCase() == 'cls' ) {
					$( '#log' ).html( '<span style="color:#00d600;"><i class="fas fa-laptop-code"></i>&nbsp;' + 'System...' )
					$( '#msg' ).val( '' )
					return null
				}
				
				aLog.push( cCmd )
				aLogPoint = -1				
				
				var o = new Object()
					o[ 'msg' ] 	= cCmd;
					o[ 'lang' ]	= 'es';

				console.log( 'PARAm', o )
				
				$( '#msg' ).val( '' );
				
				$.post( 'm_process', o )
					.done( function( dat ) { 					
						console.log( dat )
						$('#log').append( dat )
						$("#log").animate({ scrollTop: $('#log').prop("scrollHeight")}, 800);
					})
					.fail( function(dat) {
						console.log('ERROR', dat.responseText) 
					});		  			  
			}	
			
			
			$(document).ready(function () {
				$('#msg').focus()			
			})

		</script>

   </body>
</html>		
		
	ENDTEXT	

	?? cHtml
	
retu nil