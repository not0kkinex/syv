@echo off
cd /d "%~dp0.."
setlocal enabledelayedexpansion

set "G=[OK]"
set "R=[!!]"
set "Y=[..]"
set "W=[::]"

color 0B

cls
echo.
echo   +============================================+
echo   ^|         syv Installer v5.0                 ^|
echo   ^|  Zero-Dependency Optimization Daemon        ^|
echo   +============================================+
echo.

color 07

:check_python
echo %W% Checking Python...
python --version >nul 2>&1
if %errorlevel% neq 0 (
    color 0C
    echo %R% Python not found!
    echo %R% Please install Python 3.6+ from https://python.org
    echo.
    color 07
    pause
    exit /b 1
)
for /f "tokens=2" %%v in ('python --version 2^>^&1') do set pyver=%%v
color 0A
echo %G% Python %pyver% found.
color 07
echo.

:check_installed
set "target=%LOCALAPPDATA%\syv"
set "already=0"
echo %PATH% | find /i "%target%" >nul 2>&1
if %errorlevel% equ 0 set already=1

if %already% equ 1 (
    color 0E
    echo %Y% syv is already in PATH: %target%
    color 07
    choice /c YN /m "    Reinstall? [Y/N]"
    if errorlevel 2 exit /b 0
)
echo.

:install
echo %W% Target folder: %target%
if not exist "%target%" mkdir "%target%"
copy /y "syv" "%target%\syv" >nul
copy /y "syv.bat" "%target%\syv.bat" >nul
if %errorlevel% neq 0 (
    color 0C
    echo %R% Copy failed!
    color 07
    pause
    exit /b 1
)
color 0A
echo %G% Files copied.
color 07
echo.

:add_path
echo %W% Adding to PATH...
powershell -command "$t=[Environment]::GetFolderPath('LocalApplicationData')+'\syv';$p=[Environment]::GetEnvironmentVariable('PATH','User');[Environment]::SetEnvironmentVariable('PATH',$t+';'+$p,'User')"
if %errorlevel% neq 0 (
    color 0C
    echo %R% Failed to update PATH!
    color 07
    pause
    exit /b 1
)
color 0A
echo %G% PATH updated successfully.
color 07
echo.

:done
cls
color 0A
echo.
echo   +============================================+
echo   ^|        syv installed successfully!          ^|
echo   +============================================+
echo   ^| Folder: %target%
echo   ^| Usage:  syv help
echo   +============================================+
echo.
color 0E
echo   Close and reopen your terminal for PATH changes
echo   to take effect.
echo.
color 07
pause