@echo off

%windir%\System32\inetsrv\appcmd.exe set config  -section:system.applicationHost/sites /[name='CoreApp'].[path='/'].[path='/'].userName:"PROD-PLAT\ccgsconfig" /[name='CoreApp'].[path='/'].[path='/'].password:"jXG7v:yG/&"  /commit:apphost
%windir%\System32\inetsrv\appcmd.exe set config  -section:system.applicationHost/sites /[name='Services'].[path='/'].[path='/'].userName:"PROD-PLAT\ccgsconfig" /[name='Services'].[path='/'].[path='/'].password:"jXG7v:yG/&"  /commit:apphost
%windir%\System32\inetsrv\appcmd.exe set config  -section:system.applicationHost/sites /[name='WebServer'].[path='/'].[path='/'].userName:"PROD-PLAT\ccgsconfig" /[name='WebServer'].[path='/'].[path='/'].password:"jXG7v:yG/&"  /commit:apphost
%windir%\System32\inetsrv\appcmd.exe set config  -section:system.applicationHost/sites /[name='CoreCredit'].[path='/'].[path='/'].userName:"PROD-PLAT\ccgsconfig" /[name='CoreCredit'].[path='/'].[path='/'].password:"jXG7v:yG/&"  /commit:apphost

Pause
