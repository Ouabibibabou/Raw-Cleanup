@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: =====================================================
:: RAW Photo Cleanup Tool - Delete RAW files with no matching final JPEG
:: Usage: place this script anywhere, run it and enter the paths when prompted
:: =====================================================

echo ==========================================
echo       RAW Photo Cleanup Tool v1.0
echo ==========================================
echo.
echo Description:
echo 1. Scans all JPEG files (jpg/jpeg) in the final-images folder
echo 2. Scans all RAW files in the RAW folder (common RAW formats supported)
echo 3. Deletes RAW files that have no matching final JPEG
echo.
echo Note: matching is based on file name (without extension)
echo.

:: Get the final JPEG folder path
:get_jpeg_folder
set "JPEG_FOLDER="
set /p "JPEG_FOLDER=Enter the final JPEG folder path (drag a folder here): "
if not defined JPEG_FOLDER goto get_jpeg_folder
set "JPEG_FOLDER=%JPEG_FOLDER:"=%"

:: Strip trailing backslash from the path
if "%JPEG_FOLDER:~-1%"=="\" set "JPEG_FOLDER=%JPEG_FOLDER:~0,-1%"

:: Check that the folder exists
if not exist "%JPEG_FOLDER%" (
    echo [ERROR] Final JPEG folder does not exist. Please try again.
    goto get_jpeg_folder
)

:: Get the RAW folder path
:get_raw_folder
set "RAW_FOLDER="
set /p "RAW_FOLDER=Enter the RAW folder path (drag a folder here): "
if not defined RAW_FOLDER goto get_raw_folder
set "RAW_FOLDER=%RAW_FOLDER:"=%"

if "%RAW_FOLDER:~-1%"=="\" set "RAW_FOLDER=%RAW_FOLDER:~0,-1%"

if not exist "%RAW_FOLDER%" (
    echo [ERROR] RAW folder does not exist. Please try again.
    goto get_raw_folder
)

echo.
echo ==========================================
echo Final JPEG folder: %JPEG_FOLDER%
echo RAW folder: %RAW_FOLDER%
echo ==========================================
echo.

:: Confirm before continuing
set "CONFIRM="
set /p "CONFIRM=Are these paths correct? (Y/N): "
if /i not "%CONFIRM%"=="Y" (
    echo Operation cancelled.
    pause
    exit /b 0
)

echo.
echo [SCAN] Reading the list of final JPEG file names...

:: Collect all JPEG file names (without extension)
set "JPEG_COUNT=0"
for %%f in ("%JPEG_FOLDER%\*.jpg" "%JPEG_FOLDER%\*.jpeg") do (
    if exist "%%f" (
        set /a JPEG_COUNT+=1
        set "JPEG_%%~nf=1"
    )
)

if %JPEG_COUNT% EQU 0 (
    echo [ERROR] No JPG/JPEG files were found in the final JPEG folder!
    pause
    exit /b 1
)

echo [SCAN] Found %JPEG_COUNT% final JPEG file(s).
echo [SCAN] Checking the RAW folder...

:: List of supported RAW formats (add or remove as needed)
set "RAW_EXTS=.arw .cr2 .cr3 .dng .nef .nrw .orf .raf .rw2 .pef .srw .xmp"

:: Walk the RAW folder and delete RAW files with no matching final JPEG
set "DELETED_COUNT=0"
set "KEPT_COUNT=0"
set "TOTAL_RAW=0"

for %%f in ("%RAW_FOLDER%\*") do (
    set "EXT=%%~xf"
    set "BASENAME=%%~nf"

    :: Check whether this is a supported RAW format (case-insensitive)
    call :is_raw_extension !EXT!
    if !IS_RAW! EQU 1 (
        set /a TOTAL_RAW+=1
        :: Check whether a matching final JPEG exists
        if defined JPEG_!BASENAME! (
            set /a KEPT_COUNT+=1
            echo [KEEP] !BASENAME!
        ) else (
            set /a DELETED_COUNT+=1
            echo [DELETE] !BASENAME!%%~xf
            del "%%f" 2>nul
            if errorlevel 1 (
                echo [WARNING] Failed to delete: %%f
            )
        )
    )
)

echo.
echo ==========================================
echo Done!
echo ------------------------------------------
echo Total RAW files: %TOTAL_RAW%
echo Kept (matching JPEG found): %KEPT_COUNT%
echo Deleted (no JPEG): %DELETED_COUNT%
echo ==========================================
echo.
pause
exit /b 0

:: =====================================================
:: Subroutine: check whether the extension is a supported RAW format
:: =====================================================
:is_raw_extension
set "IS_RAW=0"
set "EXT_TO_CHECK=%~1"
set "EXT_TO_CHECK=%EXT_TO_CHECK:.=%"
set "EXT_TO_CHECK=%EXT_TO_CHECK: =%"

:: Convert to lowercase for the comparison
for %%a in (arw cr2 cr3 dng nef nrw orf raf rw2 pef srw xmp) do (
    if /i "!EXT_TO_CHECK!"=="%%a" (
        set "IS_RAW=1"
        goto :eof
    )
)
goto :eof
