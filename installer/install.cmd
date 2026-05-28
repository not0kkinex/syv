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
echo  %B%%C%  +============================================+%N%
echo  %B%%C%  ^|         syv Installer v5.0                 ^|%N%
echo  %B%%C%  ^|  Zero-Dependency Optimization Daemon        ^|%N%
echo  %B%%C%  +============================================+%N%
echo.

:check_python
echo  %Y%[*] Checking Python...%N%
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo  %R%[!] Python not found!%N%
    echo  %R%[!] Please install Python 3.6+ from https://python.org%N%
    echo.
    pause
    exit /b 1
)
for /f "tokens=2" %%v in ('python --version 2^>^&1') do set pyver=%%v
echo  %G%[+] Python %pyver% found.%N%
echo.

:check_installed
set "target=%LOCALAPPDATA%\syv"
set "already=0"
echo %PATH% | find /i "%target%" >nul 2>&1
if %errorlevel% equ 0 set already=1
if %already% equ 1 (
    echo  %Y%[!] syv is already in PATH: %target%%N%
    choice /c YN /m "    Reinstall? [Y/N]"
    if errorlevel 2 exit /b 0
)
echo.

:install
echo  %Y%[*] Target folder:%N% %target%
if not exist "%target%" mkdir "%target%"
copy /y "syv" "%target%\syv" >nul
copy /y "syv.bat" "%target%\syv.bat" >nul
if %errorlevel% neq 0 (
    echo  %R%[!] Copy failed!%N%
    pause
    exit /b 1
)
echo  %G%[+] Files copied.%N%
echo.

:add_path
echo  %Y%[*] Adding to PATH...%N%
powershell -command "$t=[Environment]::GetFolderPath('LocalApplicationData')+'\syv';$p=[Environment]::GetEnvironmentVariable('PATH','User');[Environment]::SetEnvironmentVariable('PATH',$t+';'+$p,'User')"
if %errorlevel% neq 0 (
    echo  %R%[!] Failed to update PATH!%N%
    pause
    exit /b 1
)
echo  %G%[+] PATH updated successfully.%N%
echo.

:done
cls
echo.
echo  %B%%G%  +============================================+%N%
echo  %B%%G%  ^|        syv installed successfully!          ^|%N%
echo  %G%  +============================================+%N%
echo  %G%  ^| %N%%Y%Folder:%N% %target%%G%
echo  %G%  ^| %N%%Y%Usage: %N% syv help%G%
echo  %G%  +============================================+%N%
echo.
echo  %Y%Close and reopen your terminal for PATH changes%N%
echo  %Y%to take effect.%N%
echo.
pause