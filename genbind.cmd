@echo off
rem genbind.cmd - Run SOM compiler to generate C bindings for wpstutor.idl
rem Output: h\wpstutor.ih  h\wpstutor.h

if not exist release md release
set LOGFILE=release\genbind.log

echo Running sc to generate wpstutor.ih and wpstutor.h ... | tee -a %LOGFILE%

sc -s"ih;h" idl\wpstutor.idl >> %LOGFILE% 2>>&1

if not exist idl\wpstutor.ih goto noIh
move idl\wpstutor.ih h\wpstutor.ih >> %LOGFILE%
:noIh
if not exist idl\wpstutor.h goto noH
move idl\wpstutor.h h\wpstutor.h >> %LOGFILE%
:noH

echo . | tee -a %LOGFILE%
