@echo off
:: Made by sstef
:: BatchGotAdmin
:-------------------------------------
REM  --> Check for permissions
    IF "%PROCESSOR_ARCHITECTURE%" EQU "amd64" (
>nul 2>&1 "%SYSTEMROOT%\SysWOW64\cacls.exe" "%SYSTEMROOT%\SysWOW64\config\system"
) ELSE (
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
)

REM --> If error flag set, we do not have admin.
if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    set params= %*
    echo UAC.ShellExecute "cmd.exe", "/c ""%~s0"" %params:"=""%", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    pushd "%CD%"
    CD /D "%~dp0"
:--------------------------------------    
echo Checking Windows Health
dism /online /cleanup-image /checkhealth

cls

echo Scanning Windows Health
Dism /Online /Cleanup-Image /ScanHealth

cls

echo Restoring Windows Health
dism /online /cleanup-image /restorehealth

cls

echo Scanning Integrity and Repairing system files
sfc /scannow

cls

echo Component Cleanup
dism /online /cleanup-image /startcomponentcleanup

cls

echo Component Cleanup - Base Reset
dism /online /cleanup-image /startcomponentcleanup /resetbase

cls

echo Starting w32time Service
net start w32time

cls

echo w32time Resync
w32tm/resync

cls

echo Updating Local Policy Settings
gpupdate /force

cls

echo Clearing all Temp/Cache files..
cd\
erase *.tmp /s
del /q/f/s %TEMP%
del /q/f/s c:\windows\temp

cls

echo Checking Disk Problems, Type "Y" to restart and start checking
chkdsk /f /r

cls

echo Restarting..
shutdown -r -t 0