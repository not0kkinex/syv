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
echo %W% Python kontrol ediliyor...
python --version >nul 2>&1
if %errorlevel% neq 0 (
    color 0C
    echo %R% Python bulunamadi!
    echo %R% https://python.org adresinden Python 3.6+ yukleyin.
    echo.
    color 07
    pause
    exit /b 1
)
for /f "tokens=2" %%v in ('python --version 2^>^&1') do set pyver=%%v
color 0A
echo %G% Python %pyver% bulundu.
color 07
echo.

:check_installed
set "target=%LOCALAPPDATA%\syv"
set "already=0"
echo %PATH% | find /i "%target%" >nul 2>&1
if %errorlevel% equ 0 set already=1

if %already% equ 1 (
    color 0E
    echo %Y% syv zaten PATH'te: %target%
    color 07
    choice /c YN /m "    Tekrar yukle? [Y/N]"
    if errorlevel 2 exit /b 0
)
echo.

:install
echo %W% Hedef klasor: %target%
if not exist "%target%" mkdir "%target%"
copy /y "syv" "%target%\syv" >nul
copy /y "syv.bat" "%target%\syv.bat" >nul
if %errorlevel% neq 0 (
    color 0C
    echo %R% Kopyalama hatasi!
    color 07
    pause
    exit /b 1
)
color 0A
echo %G% Dosyalar kopyalandi.
color 07
echo.

:add_path
echo %W% PATH ekleniyor...
setx PATH "%target%;%PATH%" >nul 2>&1
if %errorlevel% neq 0 (
    color 0C
    echo %R% PATH eklenemedi! Yonetici olarak calistirin.
    color 07
    pause
    exit /b 1
)
color 0A
echo %G% PATH basariyla eklendi.
color 07
echo.

:done
cls
color 0A
echo.
echo   +============================================+
echo   ^|        syv basariyla yuklendi!              ^|
echo   +============================================+
echo   ^| Klasor: %target%
echo   ^| Komut:  syv help
echo   +============================================+
echo.
color 0E
echo   Yeni PATH'in aktiflesmesi icin terminali
echo   kapatip yeniden acin.
echo.
color 07
pause