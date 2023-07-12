xcopy D:\Installer\IIS %windir%\system32\inetsrv /O /X /E /H /K

%windir%\system32\inetsrv\appcmd.exe restore backup "PROD2WEB01"

Pause