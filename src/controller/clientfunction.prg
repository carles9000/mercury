FUNCTION Contoller( o )

	?? '<h2>Controller Function() !</h2>'
	
	IF !empty( o:cAction )
		? 'Action: ',  o:cAction
	ENDIF
	
RETU NIL
