@echo off

echo.
echo BackUpSD  -  by Kazkaaz (github.com/Kazkaaz)

rem ----- SET THESE VARIABLES YOURSELF -----
set "ROOT=C:\Users\urname\OneDrive\Pictures\Camera"
set "SRC=D:\DCIM\100MSDCF"

rem ----- Get current date as yyyy‑mm‑dd -----
for /f "tokens=1-3 delims=/- " %%a in ("%date%") do (
    if "%%a" geq "2000" (
        set "YYYY=%%a" & set "MM=%%b" & set "DD=%%c"
    ) else if "%%b" geq "2000" (
        set "YYYY=%%b" & set "MM=%%a" & set "DD=%%c"
    ) else (
        set "YYYY=%%c" & set "MM=%%a" & set "DD=%%b"
    )
)
set "BASE=%YYYY%-%MM%-%DD%"

rem ----- Determine a unique destination folder -----
set "DEST=%ROOT%\%BASE%"
if exist "%DEST%" (
    set /a idx=1
    :find_next
    set "DEST=%ROOT%\%BASE% (%idx%)"
    if exist "%DEST%" (
        set /a idx+=1
        goto :find_next
    )
)

rem ----- Show what will happen and ask for confirmation -----
echo.
echo About to copy files from:
echo   "%SRC%"
echo to destination folder:
echo   "%DEST%"
echo.
choice /c YN /m "Proceed with the copy?"
if errorlevel 2 (
    echo Operation cancelled by user.
    pause
    exit /b
)

rem ----- Create the destination root folder -----
md "%DEST%"

rem ----- Copy files and sort them by extension -----
for /r "%SRC%" %%F in (*) do (
    set "ext=%%~xF"
    setlocal enabledelayedexpansion
    set "ext=!ext:~1!"               rem remove leading dot
    if not exist "%DEST%\!ext!" md "%DEST%\!ext!"
    copy "%%F" "%DEST%\!ext!\" >nul
    endlocal
)

echo.
echo All files have been copied and sorted by extension.
echo Destination folder: "%DEST%"

rem ----- Ask whether to empty the source folder -----
choice /c YN /m "Do you want to delete the original files from %SRC% (empty the SD card)?"
if errorlevel 2 (
    echo Source files left untouched.
) else (
    echo Deleting source files...
    rem /S processes subfolders, /Q suppresses prompts, /F forces deletion of read‑only files
    del /S /Q /F "%SRC%\*"
    rem Remove empty subfolders
    for /f "delims=" %%D in ('dir "%SRC%" /ad /b /s') do rd "%%D" 2>nul
    echo Source folder emptied.
)

pause
