@echo off
@cls
@set    path=c:\harbour\bin
@set include=c:\harbour\include

del mercury.hrb


@echo ========================
@echo Building Lib MVC Mercury
@echo ========================

harbour mercury.prg /n /w /gh

pause






