# Makefile.wat - Open Watcom makefile for wpstutor.dll and showdesc.exe
#
# Build with:  wmake -f Makefile.wat
# Or use:      mk.cmd

SOMINC = C:\os2tk45\som\include
WPSINC = C:\os2tk45\h

SOMDLL  = C:\OS2\DLL\som.dll
SOMLIB  = release\som.lib
PMWPDLL = C:\OS2\DLL\pmwp.dll
PMWPLIB = release\pmwp.lib

CC    = wcc386
LINK  = wlink
RC    = wrc
WLIB  = wlib

# DLL flags (wpstutor.dll)
# -wcd=726:  suppress W726 "unused formal parameter" in SOM toolkit headers
# -wcd=136:  suppress W136 "conversion between different pointer types"
# -wcd=1177: suppress W1177 "Modifier repeated in declaration" in sombtype.h
# -wcd=107:  suppress W107 "missing return value" in wpstut_wpOpen (original IBM bug)
CFLAGS_DLL = -bd -bt=os2 -zq -wx -wcd=726 -wcd=136 -wcd=1177 -wcd=107 -d1
INCL_DLL   = -Ih -Isrc -I$(SOMINC) -I$(WPSINC)

# EXE flags (showdesc.exe) - no -bd, no SOM includes needed
# -wcd=106: suppress W106 "constant out of range" int-to-short in original IBM source
# -wcd=201: suppress W201 "unreachable code" in original IBM source
CFLAGS_EXE = -bt=os2 -zq -wx -wcd=106 -wcd=201 -d1
INCL_EXE   = -Isrc -I$(WPSINC)

# wpstutor.dll exports
# Data exports: wcc386 32-bit flat model does not add _ prefix to C data symbols
EXPS_DLL = &
    EXP WPSTutorialNewClass &
    EXP M_WPSTutorialNewClass &
    EXP WPSTutorialClassData &
    EXP WPSTutorialCClassData &
    EXP M_WPSTutorialClassData &
    EXP M_WPSTutorialCClassData

LFLAGS_DLL = SYSTEM OS2V2_DLL &
             NAME release\wpstutor.dll &
             OP MAP=release\wpstutor.map &
             @src\wpstutor.def &
             LIBF $(SOMLIB),$(PMWPLIB) &
             $(EXPS_DLL)

LFLAGS_EXE = SYSTEM OS2V2_PM &
             NAME release\showdesc.exe &
             OP MAP=release\showdesc.map &
             OP STACK=24576 &
             @src\showdesc.def

all : release\wpstutor.dll release\showdesc.exe .SYMBOLIC

# ---- wpstutor.dll ----

release\wpstutor.dll : release\wpstutor.obj release\wpstutor.res $(SOMLIB) $(PMWPLIB)
	$(LINK) $(LFLAGS_DLL) FIL release\wpstutor.obj
	$(RC) release\wpstutor.res $@

release\wpstutor.obj : src\wpstutor.c h\wpstutor.ih h\wpstutor.h
	$(CC) $(CFLAGS_DLL) $(INCL_DLL) src\wpstutor.c -fo=$@

release\wpstutor.res : src\wpstutor.rc src\wpstutor_res.h src\wpstutor.ico
	$(RC) -r -i=src -i=h -i=$(SOMINC) -i=$(WPSINC) src\wpstutor.rc
	copy src\wpstutor.res release
	del src\wpstutor.res

# ---- showdesc.exe ----

release\showdesc.exe : release\showdesc.obj release\showdesc.res
	$(LINK) $(LFLAGS_EXE) FIL release\showdesc.obj
	$(RC) release\showdesc.res $@

release\showdesc.obj : src\showdesc.c src\showdesc.h src\methodid.h
	$(CC) $(CFLAGS_EXE) $(INCL_EXE) src\showdesc.c -fo=$@

release\showdesc.res : src\showdesc.rc src\showdesc.h src\methodid.h src\showdesc.ico
	$(RC) -r -i=src -i=$(WPSINC) src\showdesc.rc
	copy src\showdesc.res release
	del src\showdesc.res

# ---- shared libs ----

release\som.lib : $(SOMDLL)
	$(WLIB) -n -b -q $@ +$(SOMDLL)

release\pmwp.lib : $(PMWPDLL)
	$(WLIB) -n -b -q $@ +$(PMWPDLL)

clean : .SYMBOLIC
	@if exist release\*.obj del release\*.obj
	@if exist release\*.res del release\*.res
	@if exist release\*.lib del release\*.lib
	@if exist release\*.dll del release\*.dll
	@if exist release\*.exe del release\*.exe
	@if exist release\*.map del release\*.map
	@if exist release\*.err del release\*.err
