@echo off
@cls
@set    path=c:\harbour\bin
@set include=c:\harbour\include

del tmvc_lib.hrb


@echo ========================
@echo Building Lib MVC Mercury
@echo ========================

harbour tmvc_lib.prg /n /w /gh

pause


