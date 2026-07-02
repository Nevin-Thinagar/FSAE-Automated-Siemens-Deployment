@echo off
setlocal EnableDelayedExpansion

cls
echo ==============================================================
echo        MIT Motorsports Model Year 27 Software Installer
echo ==============================================================
echo             [1;30m______________  [1;31m______________  [1;37m______________
echo            [1;30m/             / [1;31m/             / [1;37m/             /
echo           [1;30m/             / [1;31m/             / [1;37m/             /
echo          [1;30m/             / [1;31m/             / [1;37m/             /
echo         [1;30m/             / [1;31m/             / [1;37m/             /
echo        [1;30m/             / [1;31m/             / [1;37m/             /
echo       [1;30m/             / [1;31m/             / [1;37m/             /
echo      [1;30m/             / [1;31m/             / [1;37m/             /
echo     [1;30m/             / [1;31m/             / [1;37m/             /
echo    [1;30m/_____________/ [1;31m/_____________/ [1;37m/_____________/[0m
echo.

:: ========= CONFIG =========
rem Set VFS paths for software download
set "MODEL_YEAR=MY27"
set "VFS_PATH=http://fsae-supercomputer:80/vfs/%MODEL_YEAR%/"
set "VFS_TEST_PATH=vfs_test.txt"

set "NX_PATH=SiemensNX-2506.8901_wntx64.zip"
set "NX_DIR=SiemensNX-2506.8901_wntx64"

set "TC_PATH=tc2606_wntx64.zip"
set "TC_DIR=tc2606_wntx64"

set "JAVA_PATH=OpenJDK21U-jdk_x64_windows_hotspot_21.0.3_9.zip"
set "JAVA_DIR=jdk-21.0.3+9"

set "FEMAP_PATH=FEMAP_2606.zip"
set "FEMAP_DIR=FEMAP_2606"

rem Make sure to remove the'+' from the STAR-CCM+ filename on the VFS server, as it can cause issues with URL encoding
set "STARCCM_PATH=Simcenter_STAR-CCM_2602.0001-Windows-x64-double.zip"
set "STARCCM_DIR=starccm+_21.02.008"

set "VIS_PATH=TcVis_2606_win64.zip"
set "VIS_DIR=TcVis_2606_2026051400_win64"

set "HEEDS_PATH=Simcenter_HEEDS-2604.0001-win64.exe"

set "INSTALL_DIR=C:\Program Files\Siemens\%MODEL_YEAR%"

:: ========== CHECKS ==========
rem Check for Administrator privileges
fltmc >nul 2>&1
if %errorlevel% equ 0 (
    echo [32m[SUCCESS][0m Running with Administrator privileges.
) else (
    echo [31m[ERROR][0m This script must be run as Administrator!
    echo.
    pause
    goto QUIT
)

rem Check for connection to fsae-supercomputer VFS
curl.exe -s -f -I "%VFS_PATH%%VFS_TEST_PATH%" >nul 2>&1
if %errorlevel% equ 0 (
    echo [32m[SUCCESS][0m Connection to fsae-supercomputer verified.
) else (
    echo [31m[ERROR][0m Cannot connect to fsae-supercomputer.
    echo.
    echo Please ensure you are connected to MIT Wi-Fi and the
    echo MIT VPN if you are off campus. If this error persists,
    echo please ping @server-help on Slack for assistance.
    echo.
    pause
    goto QUIT
)

rem Storage space warning
echo.
echo NOTE: If you are low on disk space, close this window
echo and manually uninstall old versions of NX or Teamcenter first.
echo Check %INSTALL_DIR%. Existing files will NOT be deleted.
echo.

choice /n /m "Go to Skip point? (For development only) [Y/N] "
if errorlevel 2 (
    echo Continuing with installation...
) else (
    set "clean_choices=1 2 3 4 5 6"
    set "JAVA_PATH=%JAVA_DIR%"
    set "NX_PATH=%NX_DIR%"
    set "TC_PATH=%TC_DIR%"
    set "FEMAP_PATH=%FEMAP_DIR%"
    set "STARCCM_PATH=%STARCCM_DIR%"
    set "VIS_PATH=%VIS_DIR%"
    goto SKIP
)

:: ========== ADVANCED/DEFAULT SELECTION ==========
choice /n /m "Perform default installation? (NX and Teamcenter only) [Y/N] "
if errorlevel 2 (
    goto MENU
) else (
    set "clean_choices=1 2"
    goto FETCH
)

:: ========== ADVANCED INSTALLATION MENU ==========
:MENU
set "choices="
set "clean_choices="

cls
echo =============================================================
echo                   Select Software to Install
echo =============================================================
echo  [1] NX
echo  [2] Teamcenter
echo  [3] Femap
echo  [4] STAR-CCM+
echo  [5] Visualization
echo  [6] HEEDS
echo  [7] All of the above
echo  [8] Exit
echo =============================================================
echo  Enter choices separated by commas or spaces [Default: 1, 2]
echo =============================================================
echo.

rem Get user input
set /p choices="Your selections (Press enter for default): "

rem If user presses Enter without typing, apply the default selection
if "!choices!"=="" set "choices=1, 2"


rem Check if every entered character corresponds to a valid menu option
for %%i in (%choices%) do (
    set "valid=0"
    if "%%i"=="1" set "valid=1"
    if "%%i"=="2" set "valid=1"
    if "%%i"=="3" set "valid=1"
    if "%%i"=="4" set "valid=1"
    if "%%i"=="5" set "valid=1"
    if "%%i"=="6" set "valid=1"
    if "%%i"=="7" (
        set "valid=1"
        set "choices=1 2 3 4 5 6"
    )
    if "%%i"=="8" (
        choice /n /m "Are you sure you want to exit? [Y/N] "
        if errorlevel 2 (
            for /L %%j in (1,1,7) do set "chosen_%%j=0"
            goto MENU
        ) else (
            goto QUIT
        )
    )

    if "!valid!"=="0" (
        echo.
        echo [ERROR] "%%i" is not a valid selection.
        echo Please choose only numbers from 1 to 8.
        echo.
        pause
        for /L %%j in (1,1,7) do set "chosen_%%j=0"
        goto MENU
    )
)

rem Clean and sort inputted choices
for /L %%i in (1,1,6) do (
    if not "!choices:%%i=!"=="!choices!" (
        set "clean_choices=!clean_choices! %%i"
    )
)

rem Confirm selections
echo.
echo You selected the following tasks:
echo.

for %%i in (%clean_choices%) do (
    set "chosen_%%i=0"
    if "%%i"=="1" echo  - [1] NX
    if "%%i"=="2" echo  - [2] Teamcenter
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

:: ========= FETCH ==========
:FETCH
cls
echo Fetching installation files and preparing to install selected software...
echo This may take a while depending on your internet connection and the size of the selected software packages.

rem Make temporary directory for staging files
mkdir "C:\Siemens_Temp" >NUL 2>&1
set "CURL_ARGS="

rem All software installations require Java
call :downloadAndExtract "%JAVA_PATH%"
if not JAVA_PATH=="" (
    set "JAVA_PATH=%JAVA_DIR%"
)

if not "!clean_choices:1=!"=="!clean_choices!" (
    call :DownloadAndExtract "%NX_PATH%"
    if not NX_PATH=="" (
        set "NX_PATH=%NX_DIR%"
    )
)

if not "!clean_choices:2=!"=="!clean_choices!" (
    call :DownloadAndExtract "%TC_PATH%"
    if not TC_PATH=="" (
        set "TC_PATH=%TC_DIR%"
    )
)

if not "!clean_choices:3=!"=="!clean_choices!" (
    call :DownloadAndExtract "%FEMAP_PATH%"
    if not FEMAP_PATH=="" (
        set "FEMAP_PATH=%FEMAP_DIR%"
    )
)

if not "!clean_choices:4=!"=="!clean_choices!" (
    call :DownloadAndExtract "%STARCCM_PATH%"
    if not STARCCM_PATH=="" (
        set "STARCCM_PATH=%STARCCM_DIR%"
    )
)

if not "!clean_choices:5=!"=="!clean_choices!" (
    call :DownloadAndExtract "%VIS_PATH%"
    if not VIS_PATH=="" (
        set "VIS_PATH=%VIS_DIR%"
    )
)

if not "!clean_choices:6=!"=="!clean_choices!" (
    call :DownloadAndExtract "%HEEDS_PATH%"
)

:SKIP

:: ========= INSTALLATION ==========
:INSTALL
echo.
echo Installing software that was fetched successfully...
echo Creating installation directory at "%INSTALL_DIR%"...
mkdir "%INSTALL_DIR%" >NUL 2>&1

call :InstallJava
pause

rem Exit installer
:QUIT

cls
echo Exiting installer. Thank you for using the MIT Motorsports MY27 Software Installer
echo              [1;30m______________  [1;31m______________  [1;37m______________
echo             [1;30m/             / [1;31m/             / [1;37m/             /
echo            [1;30m/  ___        / [1;31m/             / [1;37m/  ____       /
echo           [1;30m/  ^|   ^|      / [1;31m/  \     /    / [1;37m/  ^|          /
echo          [1;30m/   ^|   ^|     / [1;31m/    \   /    / [1;37m/   ^|         /
echo         [1;30m/    ^|--^<     / [1;31m/      \ /    / [1;37m/    ^|----    /
echo        [1;30m/     ^|   ^|   / [1;31m/        ^|    / [1;37m/     ^|       /
echo       [1;30m/      ^|___^|  / [1;31m/         ^|   / [1;37m/      ^|____  /
echo      [1;30m/             / [1;31m/             / [1;37m/             /
echo     [1;30m/_____________/ [1;31m/_____________/ [1;37m/_____________/[0m
timeout /t 2 >nul
exit /b

:: ========== Functions ==========

:DownloadAndExtract
rem Usage: call :DownloadAndExtract <ArchivePath>
set "ArchivePath=%~1"
echo.
echo Fetching %ArchivePath%...

curl -f -L "%VFS_PATH%%ArchivePath%" -o "%TEMP%\%ArchivePath%"
if errorlevel 1 (
    echo [31m[ERROR][0m Failed to fetch %ArchivePath%.
    echo Skipping installation of this software.
    echo.
    timeout /t 2 >nul

    set "%~1="
    goto :eof
) else (
    echo [32m[SUCCESS][0m Fetched %ArchivePath%.
)

if /i "%ArchivePath:~-4%"==".zip" (
    echo Extracting %ArchivePath%...
    tar -xf "%TEMP%\%ArchivePath%" -C "C:\Siemens_Temp" >NUL 2>&1
    if errorlevel 1 (
        echo [31m[ERROR][0m Failed to extract %ArchivePath%.
        echo Skipping installation of this software.
        echo.
        timeout /t 2 >nul

        set "%~1="
    ) else (
        echo [32m[SUCCESS][0m Extracted %ArchivePath%.
    )
) else if /i "%ArchivePath:~-4%"==".exe" (
    echo Moving %ArchivePath% to C:\Siemens_Temp...
    move "%TEMP%\%ArchivePath%" "C:\Siemens_Temp\%ArchivePath%" >NUL 2>&1
    if errorlevel 1 (
        echo.
        echo [31m[ERROR][0m Failed to move %ArchivePath%.
        echo Skipping installation of this software.
        echo.
        timeout /t 1 >nul
        set "%~1="
    ) else (
        echo [32m[SUCCESS][0m Moved %ArchivePath%.
    )
) else (
    echo [31m[ERROR][0m Unsupported archive format for %ArchivePath%.
    echo Skipping installation of this software.
    echo.
    timeout /t 1 >nul
    set "%~1="
)

goto :eof

:InstallJava
rem Usage: call :InstallJava
echo.
echo Installing Java...
if %JAVA_PATH%=="" (
    echo [31m[ERROR][0m Java installation path is not set. Skipping Java installation.
    goto :eof
)

echo Copying %JAVA_PATH% to %INSTALL_DIR%...
robocopy "C:\Siemens_Temp\%JAVA_PATH%" "%INSTALL_DIR%\%JAVA_PATH%" /mir >NUL 2>&1
if errorlevel 3 (
    echo.
    echo [31m[ERROR][0m Failed to copy C:\Siemens_Temp\%JAVA_PATH% to %INSTALL_DIR%
    echo Skipping installation of this software.
    echo.
    timeout /t 1 >nul
    goto :eof
) else (
    echo [32m[SUCCESS][0m Copied C:\Siemens_Temp\%JAVA_PATH% to %INSTALL_DIR%
)

echo Setting UGII_JAVA_HOME environment variable...
set "UGII_JAVA_HOME=%INSTALL_DIR%\%JAVA_PATH%" >NUL 2>&1
setx UGII_JAVA_HOME "%INSTALL_DIR%\%JAVA_PATH%" /M >NUL 2>&1
if defined UGII_JAVA_HOME (
    echo [32m[SUCCESS][0m UGII_JAVA_HOME environment variable set to %INSTALL_DIR%\%JAVA_PATH%.
) else (
    echo [31m[ERROR][0m Failed to set UGII_JAVA_HOME environment variable.
    echo Please set it manually to %INSTALL_DIR%\%JAVA_PATH%.
)

goto :eof

:InstallNX
rem Usage: call :InstallNX
echo.
if %NX_PATH%=="" (
    echo [31m[ERROR][0m NX installation path is not set. Skipping NX installation.
    goto :eof
)



goto :eof

:InstallTeamcenter
rem Usage: call :InstallTeamcenter
echo.
if %TC_PATH%=="" (
    echo [31m[ERROR][0m Teamcenter installation path is not set. Skipping Teamcenter installation.
    goto :eof
)



goto :eof

:InstallFemap
rem Usage: call :InstallFemap
echo.
if %FEMAP_PATH%=="" (
    echo [31m[ERROR][0m Femap installation path is not set. Skipping Femap installation.
    goto :eof
)



goto :eof

:InstallSTARCCM
rem Usage: call :InstallSTARCCM
echo.
if %STARCCM_PATH%=="" (
    echo [31m[ERROR][0m STAR-CCM+ installation path is not set. Skipping STAR-CCM+ installation.
    goto :eof
)



goto :eof

:InstallVisualization
rem Usage: call :InstallVisualization
echo.
if %VISUALIZATION_PATH%=="" (
    echo [31m[ERROR][0m Visualization installation path is not set. Skipping Visualization installation.
    goto :eof
)



goto :eof

:InstallHEEDS
rem Usage: call :InstallHEEDS
echo.
if %HEEDS_PATH%=="" (
    echo [31m[ERROR][0m HEEDS installation path is not set. Skipping HEEDS installation.
    goto :eof
)



goto :eof
