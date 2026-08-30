@echo off
rem mk.cmd - Clean build of wpstutor.dll and showdesc.exe using Open Watcom
rem Usage: mk.cmd [nobind]
rem   nobind  skip genbind.cmd (use existing h\wpstutor.ih / h\wpstutor.h)

if not exist release md release
set MK_LOG=release\mk.log

if "x%1"=="xnobind" goto skipbind
call genbind.cmd
:skipbind

echo ====== wmake clean ======
wmake -f Makefile.wat clean 2>&1 | tee %MK_LOG%

echo ====== wmake all ======
wmake -f Makefile.wat all 2>&1 | tee -a %MK_LOG%
