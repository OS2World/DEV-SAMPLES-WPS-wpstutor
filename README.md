# wpstutor — WPS Tutorial Sample (C SOM), Open Watcom Port

OS/2 WorkPlace Shell tutorial sample demonstrating a `WPDataFile` subclass
with 54 overridden instance methods and 20 overridden class methods. Each
method override calls `DisplayMethodInfo()` to send the method ID through a
named pipe to `showdesc.exe`, which displays the method name and description
in a PM window. The object also reverses its title string on every `wpSetTitle`
call as a demonstration.

This project builds two targets:

| Target | Type | Description |
|---|---|---|
| `release\wpstutor.dll` | WPS SOM DLL | `WPSTutorial : WPDataFile` class |
| `release\showdesc.exe` | PM application | Displays WPS method descriptions via named pipe |

---

## Class Hierarchy

```
SOMObject
  └── WPObject
        └── WPFileSystem
              └── WPDataFile
                    └── WPSTutorial          (metaclass: M_WPSTutorial)
```

New instance method: `DisplayTitleInfo` — opens a tutorial view window.
New class method: `clsQueryModuleHandle` — returns the DLL module handle.

---

## Directory Layout

```
wpstutor/
├── idl/          wpstutor.idl     — SOM 2.x IDL source
├── h/            wpstutor.ih, wpstutor.h  (sc-generated; created by genbind.cmd)
├── src/          wpstutor.c, wpstutor.rc, wpstutor_res.h, wpstutor.def, wpstutor.ico
│                 showdesc.c, showdesc.h, showdesc.rc, showdesc.def, showdesc.ico
│                 methodid.h
├── doc/          (reserved)
├── release/      build output (dll, exe, obj, res, lib, map, log)
├── Makefile.wat  Open Watcom makefile (builds both targets)
├── mk.cmd        one-shot clean build
├── genbind.cmd   runs sc to generate h\wpstutor.ih and h\wpstutor.h
├── register.cmd  REXX: registers class and creates desktop object
└── deregister.cmd REXX: SysDeregisterObjectClass('WPSTutorial')
```

---

## Prerequisites

| Item | Path |
|---|---|
| Open Watcom 2.0 | `PATH` must include Watcom bin |
| OS/2 Toolkit 4.5 | `C:\os2tk45` |
| SOM runtime | `C:\OS2\DLL\som.dll` |
| PMWP (WPS shell) | `C:\OS2\DLL\pmwp.dll` |
| SOM compiler `sc` | on `PATH` (Toolkit) |

---

## Build

```
cd C:\Temporal\1.- OS2\SWtest\wps\wpstutor

rem First time (or after editing wpstutor.idl):
genbind.cmd

rem Then build:
wmake -f Makefile.wat
```

Or use the convenience wrapper:

```
mk.cmd
```

Output: `release\wpstutor.dll`, `release\showdesc.exe`

---

## Register / Test

Before registering, ensure `release\showdesc.exe` is on the `PATH` (or copy
it to a directory that is — `wpstutor.c` launches it by name via `DosExecPgm`):

```
register.cmd
```

This registers the `WPSTutorial` class and creates a desktop object
(`OBJECTID=WPSTUT001`). Double-clicking the object opens the Tutorial view
(title displayed backwards). Right-clicking shows the Open cascade. Each
method invocation sends its ID through `\\PIPE\\SHOWDESC\\NAME.QUE` to
`showdesc.exe`, which pops up the method description.

```
deregister.cmd
```

---

## Porting Notes (IBM C/C++ → Open Watcom)

| Item | Status |
|---|---|
| `wcc386` replaces IBM `icc` for both `.c` files | Done — C project |
| `sc -s"ih;h"` generates C bindings | `wpstutor.ih` and `wpstutor.h` moved to `h\` by `genbind.cmd` |
| `wpstutor.rc` `#include "wpstutor.ih"` replaced | `#include <os2.h>` + `#include "wpstutor_res.h"` |
| `src/wpstutor_res.h` created | `ID_ICON=101`, `ID_OPENMENU=0x6501`, `IDM_OPENTUT=0x6502` (from IDL passthru; `WPMENUID_USER=0x6500`) |
| `showdesc.rc` | Already uses `#include <os2.h>` — no change needed |
| `OPTION CASEEXACT` in `wpstutor.def` | Required for correct C symbol matching |
| Data symbol exports | Bare form — wcc386 32-bit flat model does not add `_` prefix |
| `showdesc.exe` — PM EXE | `SYSTEM OS2V2_PM`, `OP STACK=24576`; `main()` entry point |
| `WINDOWDATA` / `PWINDOWDATA` struct | Defined in IDL `passthru C_h_after` inside `#ifdef __PRIVATE__` — sc omits it from `wpstutor.h`; added directly to `wpstutor.c` after `#include "wpstutor.ih"` once WPS types are available |
| W107 in `wpstut_wpOpen` | Suppressed with `-wcd=107` — missing return in a code path; original IBM bug, not our issue |
| W106 / W201 in `showdesc.c` | Suppressed with `-wcd=106 -wcd=201` — int-to-short narrowing and unreachable code in original IBM source |
| `SOMInitModule` | Not needed; WPS calls `WPSTutorialNewClass` directly |
| `install.cmd` | Replaced by `register.cmd` / `deregister.cmd` using local `release\` paths |

---

## Changelog

### 1.0 — 2026-08-29
- Open Watcom port: `Makefile.wat`, `mk.cmd`, `genbind.cmd`
- Files reorganized into `idl/`, `h/`, `src/`, `doc/`, `release/`
- Created `src/wpstutor_res.h` (resource constants for wrc)
- Created `src/wpstutor.def` and `src/showdesc.def` (wlink-format)
- `src/wpstutor.rc` updated: `#include <os2.h>` replaces `#include "wpstutor.ih"`
- `src/wpstutor.c`: `WINDOWDATA`/`PWINDOWDATA` struct injected after `#include "wpstutor.ih"` (IDL `passthru C_h_after` is inside `#ifdef __PRIVATE__`, sc omits it without that flag)
- Added `-wcd=107/106/201` to suppress warnings in original IBM source
- Added `register.cmd` (registers class + creates desktop object), `deregister.cmd`, `.gitattributes`
- `release\wpstutor.dll` and `release\showdesc.exe` both build cleanly
