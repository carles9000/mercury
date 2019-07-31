@echo off
@cls
@set    path=c:\harbour\bin
@set include=c:\harbour\include

del core_lib.hrb


@echo =================
@echo Building Lib Core
@echo =================

harbour core_lib.prg /n /w /gh

pause