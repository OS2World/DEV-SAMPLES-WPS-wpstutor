/* deregister.cmd - Deregister WPSTutorial WPS class */
call RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
call SysLoadFuncs

if SysDeregisterObjectClass('WPSTutorial') then
    say 'WPSTutorial deregistered successfully.'
else
    say 'ERROR: SysDeregisterObjectClass failed.'
