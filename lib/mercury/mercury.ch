#xcommand log <cText> => Aadd( TApp():aLog, <cText> )  //	Tracear el sistema


#xcommand DEFINE APP <oApp> [ TITLE <cTitle> ] [ ON INIT <uInit> ] ;
	[ CREDENTIALS <cPsw> [ COOKIE <cId_Cookie>] [ <time:LAPSUS, TIME> <nTime> ] ] ;
=> ;
	<oApp> := APP( [<cTitle>], [\{|oApp| <uInit>\}] , [ <cPsw> ], [<cId_Cookie>], [<nTime>]   )
	
#xcommand DEFINE ROUTE <cRoute> URL <cUrl> <type:CONTROLLER,VIEW> <cController> [ METHOD <cMethod> ] OF <oApp> ;
=> ;
	<oApp>:oRoute:Map( [<cMethod>], <cRoute>, <cUrl>, <cController> )

#xcommand INIT APP <oApp> => <oApp>:Init()

#xcommand AUTENTICATE CONTROLLER <oController> [ VIA <cType> ] [<err:ERROR ROUTE, DEFAULT> <cRoute>] ;
	[ <exc: EXCEPTION> <cMethod,...> ] [ <json:ERROR JSON> [<hError>]] ;
=> ;
	__lAutenticate := <oController>:Middleware( [<cType>], [<cRoute>], [\{<cMethod>\}], [<hError>], [<.json.>] )
	
	
//	Token JWT ---------------------------------------------------------------------
	
#xcommand DEFINE JWT OF <oController> [ WITH <hToken> ] => <oController>:oMiddleware:SetAutenticationJWT( [<hToken>] )
#xcommand CLOSE JWT OF <oController> => <oController>:oMiddleware:CloseJWT()
#xcommand GET JWT <hData> OF <oController> => <hData> := <oController>:oMiddleware:GetDataJWT()
#xcommand GET TOKEN <hData> OF <oController> => <hData> := <oController>:oMiddleware:GetDataToken()

