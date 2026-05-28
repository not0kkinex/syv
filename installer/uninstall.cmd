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
echo %W% PATH'te syv araniyor...
echo %PATH% | find /i "%target%" >nul 2>&1
if %errorlevel% neq 0 (
    color 0E
    echo %Y% syv PATH'te bulunamadi.
    color 07
    goto :check_folder
)
color 0A
echo %G% PATH'te bulundu: %target%
color 07

:remove_path
echo %W% PATH'ten kaldiriliyor...
set "newpath="
call :strip_path "%PATH%"
setx PATH "%newpath%" >nul 2>&1
if %errorlevel% equ 0 (
    color 0A
    echo %G% PATH'ten kaldirildi.
    color 07
) else (
    color 0C
    echo %R% PATH guncellenemedi! Yonetici olarak calistirin.
    color 07
)
echo.

:check_folder
if exist "%target%" (
    echo %W% Klasor bulundu: %target%
    choice /c YN /m "    Klasoru sil? [Y/N]"
    if errorlevel 1 (
        color 0E
        echo %W% Klasor siliniyor...
        color 07
        rmdir /s /q "%target%" >nul 2>&1
        color 0A
        echo %G% Silindi.
        color 07
    )
) else (
    color 0E
    echo %Y% Klasor zaten mevcut degil.
    color 07
)
echo.

:done
cls
color 0A
echo.
echo   +============================================+
echo   ^|        syv basariyla kaldirildi!            ^|
echo   +============================================+
echo.
color 07
pause

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