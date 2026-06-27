@echo off
cls
echo ====================================================
echo   MIT Motorsports Model Year 27 Software Installer
echo ====================================================
echo.

:: Check for Administrator privileges
fltmc >nul 2>&1
if %errorlevel% equ 0 (
    echo [SUCCESS] Running with Administrator privileges.
) else (
    echo [ERROR] This script must be run as Administrator!
    echo.
    pause
    exit /b
)

:: Storage space warning
echo.
echo NOTE: If you are low on disk space, close this window
echo and manually uninstall old versions of NX or Teamcenter
echo from Windows Settings first. Any existing files will NOT be deleted.
echo.
pause

:: Force variables to expand at execution time
setlocal enabledelayedexpansion

:: Software installation menu
:MENU
cls
set "choices="
echo =============================================================
echo                   Select Software to Install
echo =============================================================
echo  [1] Teamcenter
echo  [2] NX
echo  [3] Femap
echo  [4] STAR-CCM+
echo  [5] Visualization
echo  [6] HEEDS
echo  [7] Exit
echo =============================================================
echo  Enter choices separated by commas or spaces [Default: 1, 2]
echo =============================================================
echo.

:: Get user input
set /p choices="Your selections (Just press enter for default): "

:: If user presses Enter without typing, apply the default selection
if "!choices!"=="" set "choices=1, 2"
set "clean_choices="

:: Check if every entered character corresponds to a valid menu option
for %%i in (%choices%) do (
    set "valid=0"
    if "%%i"=="1" set "valid=1"
    if "%%i"=="2" set "valid=1"
    if "%%i"=="3" set "valid=1"
    if "%%i"=="4" set "valid=1"
    if "%%i"=="5" set "valid=1"
    if "%%i"=="6" set "valid=1"
    if "%%i"=="7" (
        choice /n /m "Are you sure you want to exit? [Y/N] "
        if errorlevel 2 (
            for /L %%j in (1,1,6) do set "chosen_%%j=0"
            goto MENU
        ) else (
            goto QUIT
        )
    )

    if "!valid!"=="0" (
        echo.
        echo [ERROR] "%%i" is not a valid selection.
        echo Please choose only numbers from 1 to 7.
        echo.
        pause
        for /L %%j in (1,1,6) do set "chosen_%%j=0"
        goto MENU
    )

    :: Remove duplicates from the selection list
    if not "!chosen_%%i!"=="1" (
        set "chosen_%%i=1"
        set "clean_choices=!clean_choices! %%i"
    )
)

:: Confirm selections
echo.
echo You selected the following tasks:
echo.

for %%i in (%clean_choices%) do (
    set "chosen_%%i=0"
    if "%%i"=="1" echo  - [1] Teamcenter
    if "%%i"=="2" echo  - [2] NX
    if "%%i"=="3" echo  - [3] Femap
    if "%%i"=="4" echo  - [4] STAR-CCM+
    if "%%i"=="5" echo  - [5] Visualization
    if "%%i"=="6" echo  - [6] HEEDS
)
echo.

set "confirm="
set /p confirm="Is this correct? (Y/N): "

if /i not "%confirm%"=="Y" (
    goto MENU
)

:QUIT
echo.
echo Exiting installer. Goodbye!
timeout /t 2 >nul
exit /b
