/* register.cmd - Register WPSTutorial WPS class */
call RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
call SysLoadFuncs

parse source . . me
dll = filespec('drive', me) || filespec('path', me) || 'release\wpstutor.dll'

if SysRegisterObjectClass('WPSTutorial', dll) then
    say 'WPSTutorial class registered successfully.'
else
    say 'ERROR: SysRegisterObjectClass failed.'

if SysCreateObject('WPSTutorial', 'WPSTutorial', '<WP_DESKTOP>',,
                   'OBJECTID=WPSTUT001', 'U') then
    say 'WPSTutorial desktop object created (or updated).'
else
    say 'ERROR: SysCreateObject failed.'
