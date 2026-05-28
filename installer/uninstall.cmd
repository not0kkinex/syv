@echo off
cd /d "%~dp0.."
setlocal enabledelayedexpansion

chcp 65001 >nul

cls
echo.
echo   ╔══════════════════════════════════════════════╗
echo   ║        🗑️  syv Uninstaller v5.0             ║
echo   ╚══════════════════════════════════════════════╝
echo.

set "target=%LOCALAPPDATA%\syv"

:check_path
echo   [*] PATH'te syv araniyor...
echo %PATH% | find /i "%target%" >nul 2>&1
if %errorlevel% neq 0 (
    echo   [!] syv PATH'te bulunamadi.
    goto :check_folder
)
echo   [+] PATH'te bulundu: %target%
goto :remove_path

:remove_path
echo   [*] PATH'ten kaldiriliyor...
set "newpath="
call :strip_path "%PATH%"
setx PATH "%newpath%" >nul 2>&1
if %errorlevel% equ 0 (
    echo   [+] PATH'ten kaldirildi.
) else (
    echo   [!] PATH guncellenemedi! Yonetici olarak calistirin.
)
echo.
goto :check_folder

:strip_path
set "p=%*"
set "np="
:loop
for /f "delims=; tokens=1,*" %%a in ("%p%") do (
    if /i not "%%a"=="%target%" (
        if defined np (set "np=!np!;%%a") else (set "np=%%a")
    )
    set "p=%%b"
)
if defined p goto :loop
set "newpath=%np%"
goto :eof

:check_folder
if exist "%target%" (
    echo   [*] Klasor bulundu: %target%
    choice /c YN /m "   [?] Klasoru sil?"
    if errorlevel 1 (
        echo   [+] Klasor siliniyor...
        rmdir /s /q "%target%" >nul 2>&1
        echo   [+] Silindi.
    )
) else (
    echo   [-] Klasor zaten mevcut degil.
)
echo.

:done
cls
echo.
echo   ╔══════════════════════════════════════════════╗
echo   ║        ✅ syv basariyla kaldirildi!          ║
echo   ╚══════════════════════════════════════════════╝
echo.
pause
