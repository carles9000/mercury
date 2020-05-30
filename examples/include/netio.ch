#xtranslate net:<!func!>( [<params,...>] ) => ;
			netio_FuncExec( #<func> [,<params>] )
#xtranslate net:[<server>]:<!func!>( [<params,...>] ) => ;
			netio_FuncExec( [ #<server> + ] ":" + #<func> [,<params>] )
#xtranslate net:[<server>]:<port>:<!func!>( [<params,...>] ) => ;
			netio_FuncExec( [ #<server> + ] ":" + #<port> + ":" + #<func> ;
							[,<params>] )

#xtranslate net:exists:<!func!> => ;
			netio_ProcExists( #<func> )
#xtranslate net:exists:[<server>]:<!func!> => ;
			netio_ProcExists( [ #<server> + ] ":" + #<func> )
#xtranslate net:exists:[<server>]:<port>:<!func!> => ;
			netio_ProcExists( [ #<server> + ] ":" + #<port> + ":" + #<func> )