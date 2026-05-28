@echo off
cd /d "%~dp0.."
setlocal enabledelayedexpansion
set "ESC="
set "G=%ESC%[32m"
set "R=%ESC%[31m"
set "Y=%ESC%[33m"
set "C=%ESC%[36m"
set "B=%ESC%[1m"
set "N=%ESC%[0m"

cls
echo.
echo  %B%%R%  +============================================+%N%
echo  %B%%R%  ^|        syv Uninstaller v5.0                 ^|%N%
echo  %B%%R%  +============================================+%N%
echo.

set "target=%LOCALAPPDATA%\syv"

:check_path
echo  %Y%[*] Checking PATH for syv...%N%
echo %PATH% | find /i "%target%" >nul 2>&1
if %errorlevel% neq 0 (
    echo  %Y%[!] syv not found in PATH.%N%
    goto :check_folder
)
echo  %G%[+] Found in PATH: %target%%N%

:remove_path
echo  %Y%[*] Removing from PATH...%N%
powershell -command "$t=[Environment]::GetFolderPath('LocalApplicationData')+'\syv';$p=[Environment]::GetEnvironmentVariable('PATH','User');$r='';foreach($i in $p.Split(';')){if($i -ne $t){if($r){$r+=';'+$i}else{$r=$i}}}[Environment]::SetEnvironmentVariable('PATH',$r,'User')"
if %errorlevel% neq 0 (
    echo  %R%[!] Failed to update PATH!%N%
) else (
    echo  %G%[+] Removed from PATH.%N%
)
echo.

:check_folder
if exist "%target%" (
    echo  %Y%[*] Folder found: %target%%N%
    choice /c YN /m "    Delete folder? [Y/N]"
    if errorlevel 1 (
        echo  %Y%[*] Deleting folder...%N%
        rmdir /s /q "%target%" >nul 2>&1
        echo  %G%[+] Deleted.%N%
    )
) else (
    echo  %Y%[-] Folder does not exist.%N%
)
echo.

:done
cls
echo.
echo  %B%%G%  +============================================+%N%
echo  %B%%G%  ^|        syv uninstalled successfully!        ^|%N%
echo  %B%%G%  +============================================+%N%
echo.
pause