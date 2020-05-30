//
// defines for the ADO Stuff
//

// LockType
#define adLockUnspecified   -1
#define adLockReadOnly       1
#define adLockPessimistic    2
#define adLockOptimistic     3
#define adLockBatchOptimistic 4

// CursorType
#define adOpenUnspecified     1
#define adOpenForwardOnly     0
#define adOpenKeyset          1
#define adOpenDynamic         2
#define adOpenStatic          3

// userful for opening single records
#define adOpenAsync		0x1000
#define adDelayFetchStream	0x4000
#define adDelayFetchFields	0x8000
#define adOpenExecuteCommand	0x10000
#define adOpenOutput		0x800000


// Cursor Location
#define adUseClient           3
#define adUseServer           2

// Options
#define adCmdUnspecified     -1
#define adCmdUnknown          8
#define adCmdText             1
#define adCmdTable            2
#define adCmdStoredProc       4
#define adCmdFile           256
#define adCmdTableDirect    512

#define adHoldRecords       0x100
#define adMovePrevious      0x200
#define adAddNew            0x1000400
#define adDelete            0x1000800
#define adUpdate            0x1008000
#define adBookmark          0x2000
#define adApproxPosition    0x4000
#define adUpdateBatch       0x10000
#define adResync            0x20000
#define adNotify            0x40000
#define adFind              0x80000
#define adSeek              0x400000
#define adIndex             0x800000


*** Constant Group: ConnectModeEnum
#define adModeUnknown                                     0
#define adModeRead                                        1
#define adModeWrite                                       2
#define adModeReadWrite                                   3
#define adModeShareDenyRead                               4
#define adModeShareDenyWrite                              8
#define adModeShareExclusive                              12
#define adModeShareDenyNone                               16

*** Constant Group: PersistFormatEnum
#define adPersistADTG                                     0
#define adPersistXML                                      1


// DataType
#define adEmpty              0
#define adTinyInt           16
#define adSmallInt           2
#define adInteger            3
#define adBigInt            20
#define adUnsignedTinyInt   17
#define adUnsignedSmallInt  18
#define adUnsignedInt       19
#define adUnsignedBigInt    21
#define adSingle             4
#define adDouble             5
#define adCurrency           6
#define adDecimal           14
#define adNumeric          131
#define adBoolean           11
#define adError             10
#define adUserDefined      132
#define adVariant           12
#define adIDispatch          9
#define adIUnknown          13
#define adGUID              72
#define adDate               7
#define adDBDate           133
#define adDBTime           134
#define adDBTimeStamp      135
#define adBSTR               8
#define adChar             129
#define adVarChar          200
#define adLongVarChar      201
#define adWChar            130
#define adVarWChar         202
#define adLongVarWChar     203
#define adBinary           128
#define adVarBinary        204
#define adLongVarBinary    205
#define adChapter          136
#define adFileTime          64
#define adDBFileTime       137
#define adPropVariant      138
#define adVarNumeric       139

#define adArray 		0x2000

// BookMark
#define adBookmarkCurrent    0
#define adBookmarkFirst      1
#define adBookmarkLast       2

// Field attributes
//#define adFldMayBeNull	   0x40
#define adFldUnspecified                                -1
#define adFldMayDefer                                     2
#define adFldUpdatable                                    4
#define adFldUnknownUpdatable                             8
#define adFldFixed                                        16
#define adFldIsNullable                                   32
#define adFldMayBeNull                                    64
#define adFldLong                                         128
#define adFldRowID                                        256
#define adFldRowVersion                                   512
#define adFldCacheDeferred                                4096
#define adFldNegativeScale                                16384
#define adFldKeyColumn                                    32768


// Options
#define adOptionUnspecified	-1
#define adAsyncExecute		16
#define adAsyncFetch 		32
#define adAsyncFetchNonBlocking 64
#define adExecuteNoRecords 	128
#define adExecuteStream 	256
#define adExecuteRecord 	512

// Resync
// objRecordset:Resync( affectrecords,resyncvalues )

// affect records
#define adAffectCurrent 	1
#define adAffectGroup		2
#define adAffectAll 		3	// default (only inside filter)
#define adAffectAllChapters	4

// ResyncValues
#define adResyncAllValues		2 	// default
#define adResyncUnderlyingValues	1


// rs=objconn.OpenSchema(querytype,criteria,schemaid)
// ignore schemaid . provider specific

#define adSchemaTables 		20
#define adSchemaColumns 	4

// State constants

#define	adStateClosed 		0 	//The object is closed
#define adStateOpen		1 	//The object is open
#define adStateConnecting	2 	//The object is connecting
#define adStateExecuting	4	//The object is executing a command
#define adStateFetching		8 	//The rows of the object are being retrieved


// ErrorValue Constants

#define adErrInvalidArgument                              3001
#define adErrNoCurrentRecord                              3021
#define adErrIllegalOperation                             3219
#define adErrInTransaction                                3246
#define adErrFeatureNotAvailable                          3251
#define adErrItemNotFound                                 3265
#define adErrObjectInCollection                           3367
#define adErrObjectNotSet                                 3420
#define adErrDataConversion                               3421
#define adErrObjectClosed                                 3704
#define adErrObjectOpen                                   3705
#define adErrProviderNotFound                             3706
#define adErrBoundToCommand                               3707
#define adErrInvalidParamInfo                             3708
#define adErrInvalidConnection                            3709
#define adErrNotReentrant                                 3710
#define adErrStillExecuting                               3711
#define adErrOperationCancelled                           3712
#define adErrStillConnecting                              3713
#define adErrNotExecuting                                 3715
#define adErrUnsafeOperation                              3716

// Parameter Constants

#define adParamSigned                                     16
#define adParamNullable                                   64
#define adParamLong                                       128

#define adParamUnknown                                    0
#define adParamInput                                      1
#define adParamOutput                                     2
#define adParamInputOutput                                3
#define adParamReturnValue                                4

// RDBMS constants

#define RDBMS_ORACLE    1
#define RDBMS_MSSQL     2
#define RDBMS_ACCESS    3

#define DRVR_ORACLE     'MSDAORA.1'
#define DRVR_ACCESS     'Microsoft.Jet.OLEDB.4.0'

// SQL COMMAND SUPPORT

#include "fwsqlcmd.ch"


// eof: adodef.ch

