@echo off
cd /d "%~dp0.."
setlocal enabledelayedexpansion

set "G=[OK]"
set "R=[!!]"
set "Y=[..]"
set "W=[::]"

color 0C

cls
echo.
echo   +============================================+
echo   ^|        syv Uninstaller v5.0                 ^|
echo   +============================================+
echo.

color 07

set "target=%LOCALAPPDATA%\syv"

:check_path
echo %W% Checking PATH for syv...
echo %PATH% | find /i "%target%" >nul 2>&1
if %errorlevel% neq 0 (
    color 0E
    echo %Y% syv not found in PATH.
    color 07
    goto :check_folder
)
color 0A
echo %G% Found in PATH: %target%
color 07

:remove_path
echo %W% Removing from PATH...
powershell -command "$t=[Environment]::GetFolderPath('LocalApplicationData')+'\syv';$p=[Environment]::GetEnvironmentVariable('PATH','User');$r='';foreach($i in $p.Split(';')){if($i -ne $t){if($r){$r+=';'+$i}else{$r=$i}}}[Environment]::SetEnvironmentVariable('PATH',$r,'User')"
if %errorlevel% neq 0 (
    color 0C
    echo %R% Failed to update PATH!
    color 07
) else (
    color 0A
    echo %G% Removed from PATH.
    color 07
)
echo.

:check_folder
if exist "%target%" (
    echo %W% Folder found: %target%
    choice /c YN /m "    Delete folder? [Y/N]"
    if errorlevel 1 (
        color 0E
        echo %W% Deleting folder...
        color 07
        rmdir /s /q "%target%" >nul 2>&1
        color 0A
        echo %G% Deleted.
        color 07
    )
) else (
    color 0E
    echo %Y% Folder does not exist.
    color 07
)
echo.

:done
cls
color 0A
echo.
echo   +============================================+
echo   ^|        syv uninstalled successfully!        ^|
echo   +============================================+
echo.
color 07
pause

