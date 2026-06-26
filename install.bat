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

:: Default installation selections
set "choices=1, 2"
set "clean_choices=1, 2"

:: Software installation menu
:MENU
cls
echo ============================================================
echo                  Select Software to Install
echo ============================================================
echo  [1] Teamcenter
echo  [2] NX
echo  [3] Femap
echo  [4] STAR-CCM+
echo  [5] Visualization
echo  [6] HEEDS
echo  [7] Exit
echo ============================================================
echo  Enter choices separated by commas or spaces (Default: 1, 2)
echo ============================================================
echo.

:: Get user input
set /p choices="Your selections [Current selections: %clean_choices%]: "

:: If user presses Enter without typing, apply the default selection
if "%choices%"=="" set "choices=1, 2"
set "clean_choices="

:: STEP 1: VALIDATION LOOP
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
            goto MENU
        ) else (
            goto QUIT
        )
    )

    if "!valid!"=="0" (
        echo.
        echo [ERROR] "%%i" is not a valid selection.
        echo Please choose only numbers from 1 to 6 or only 7 to exit.
        echo.
        set "clean_choices=1, 2"
        pause
        goto MENU
    )

    :: Remove duplicates from the selection list
    if not "!chosen_%%i!"=="1" (
        set "chosen_%%i=1"
        set "clean_choices=!clean_choices! %%i"
    )
)

:: STEP 2: CONFIRMATION SCREEN
echo.
echo You selected the following tasks:
echo.

:: Loop through again just to display friendly names to the user
for %%i in (%clean_choices%) do (
    if "%%i"=="1" echo  - [1] Teamcenter
    if "%%i"=="2" echo  - [2] NX
    if "%%i"=="3" echo  - [3] Femap
    if "%%i"=="4" echo  - [4] STAR-CCM+
    if "%%i"=="5" echo  - [5] Visualization
    if "%%i"=="6" echo  - [6] HEEDS
)
echo.

:: Ask the user to verify choices
set "confirm="
set /p confirm="Is this correct? (Y/N): "

:: If they type 'N', hit 'n', or type gibberish, kick them back to the menu
if /i not "%confirm%"=="Y" (
    goto MENU
)

:QUIT
echo Exiting installer. Goodbye!
timeout /t 2 >nul
exit /b
