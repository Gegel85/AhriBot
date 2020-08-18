@echo off
:start

luvit ahri.lua

if %ERRORLEVEL% == 0 goto start

pause

goto start