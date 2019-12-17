/*	--------------------------------------------
	Autor		: Carles Aubia
	Data		: 11/09/2019
	Descripcion : Propósito general
	-------------------------------------------- */

function InitLog( cFile ) {

	cFile = ( typeof cFile == 'string' ) ? cFile : 'log.txt' ;

	var div 		= document.createElement( "div" );
	div.id 			= "_log";												
	div.innerHTML 	= "<span class='_log'>Log</span>";				

	document.body.appendChild( div );
	
	$('#_log').on( 'click', function(){										
		
		var d = new Date();
		
		cFile = cFile + '?' + d.getTime();		
		
		$.get( cFile, function(data) {		
			
			data = nl2br( data )

			//data = $('<div/>').html(data).text();		//Decode
			//data = $('<div/>').text(data).html()		//Encode
			
			MsgLog( data, 'Log' );

		})				
	})
}

function loadCSS(href) {

	  var cssLink = $("<link>");
	  $("head").append(cssLink); //IE hack: append before setting href

	  cssLink.attr({
		rel:  "stylesheet",
		type: "text/css",
		href: href
	  });

};		
/*
Pendent de xequejar aquest codi quan fem la crida a mSglog

			var fn = window[oObj.cFuncLenChanged];

			if (typeof fn === "function") {				
				var fnparams = [ args ] ;
				fn.apply(null, fnparams );								
			}
			
*/

function MsgLog( cMsg, cTitle ) {

	if ( !jQuery.ui) {

		console.log( 'Loading jquery-ui...' )

		loadCSS( "https://code.jquery.com/ui/1.12.1/themes/base/jquery-ui.css" );
		loadCSS( "{{ App():Url() + '/lib/bootstrap-modal.css'}}" );

		$.ajax({
			url: "https://code.jquery.com/ui/1.12.1/jquery-ui.js",
			dataType: 'script',
			async: true,
			success: function( script, textStatus ) {
				console.log( 'jquery-ui js loaded !' )
				MsgLog( cMsg, cTitle )
			},
			error: function( a, b, c ) {
				console.error( 'Error loading jquery-ui' );
			}
		});					

		return null
	}

	cTitle = ( typeof cTitle == 'string' ) ? cTitle : 'Information' ;

	var div 		= document.createElement( "div" );
	div.id 			= "_dlglog";
	div.title 		= cTitle;								
	div.innerHTML 	= cMsg;								
   
	document.body.appendChild( div );

	$( "#_dlglog" ).dialog( { modal: true, width: 'auto', height: "auto", maxHeight: '90%',	
								position: 'center',											
								open:function(event, ui){
									$(this).css("max-width"	, $(window).width() * 0.9);
									$(this).css("max-height"	, $(window).height() * 0.6);
									$(this).dialog('widget').position({ my: "center", at: "center", of: window });
								},
								close: function() {$( "#_dlglog" ).remove();},
								buttons: { 'Exit': function() { $( "#_dlglog" ).dialog( "close" ); } } 
							});
							
	/*					
    var $dialog = $(".ui-dialog");
    $dialog.addClass("modal-content");
    $dialog.find(".ui-dialog-titlebar").addClass("modal-header").find(".ui-button").addClass("close").text("x");
    $dialog.find(".ui-dialog-content").addClass("modal-body");
*/	
	

}	

function nl2br(u){ return u.replace(/(\r\n|\n\r|\r|\n)/g, "<br>"); }