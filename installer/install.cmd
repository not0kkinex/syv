@echo off
cd /d "%~dp0.."
setlocal enabledelayedexpansion

chcp 65001 >nul

:--------------------------------------------------------
:banner
cls
echo.
echo   ╔══════════════════════════════════════════════╗
echo   ║         ⚡ syv Installer v5.0               ║
echo   ║  Zero-Dependency Optimization Daemon         ║
echo   ╚══════════════════════════════════════════════╝
echo.
goto :check_python

:--------------------------------------------------------
:check_python
echo   [*] Python kontrol ediliyor...
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo   [!] Python bulunamadi!
    echo   [!] lutfen https://python.org adresinden Python 3.6+ yukleyin.
    echo.
    pause
    exit /b 1
)
for /f "tokens=2" %%v in ('python --version 2^>^&1') do set pyver=%%v
echo   [+] Python %pyver% bulundu.
echo.
goto :check_installed

:--------------------------------------------------------
:check_installed
set "target=%LOCALAPPDATA%\syv"
set "already=0"
echo %PATH% | find /i "%target%" >nul 2>&1
if %errorlevel% equ 0 set already=1

if %already% equ 1 (
    echo   [!] syv zaten PATH'te gorunuyor: %target%
    choice /c YN /m "   [?] Tekrar yukle?"
    if errorlevel 2 exit /b 0
)
echo.
goto :install

:--------------------------------------------------------
:install
echo   [*] Hedef klasor: %target%
if not exist "%target%" mkdir "%target%"
copy /y "syv" "%target%\syv" >nul
copy /y "syv.bat" "%target%\syv.bat" >nul
if %errorlevel% neq 0 (
    echo   [!] Kopyalama hatasi!
    pause
    exit /b 1
)
echo   [+] Dosyalar kopyalandi.
echo.
goto :add_path

:--------------------------------------------------------
:add_path
echo   [*] PATH ekleniyor...
setx PATH "%target%;%PATH%" >nul 2>&1
if %errorlevel% neq 0 (
    echo   [!] PATH eklenemedi! Yonetici olarak calistirin.
    pause
    exit /b 1
)
echo   [+] PATH basariyla eklendi.
echo.
goto :done

:--------------------------------------------------------
:done
cls
echo.
echo   ╔══════════════════════════════════════════════╗
echo   ║          ✅ syv basariyla yuklendi!          ║
echo   ╠══════════════════════════════════════════════╣
echo   ║  Klasor: %target%           ║
echo   ║  Komut:  syv help                            ║
echo   ╚══════════════════════════════════════════════╝
echo.
echo   Yeni PATH'in aktiflesmesi icin terminali
echo   kapatip yeniden acin.
echo.
pause
