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

set "LICENSE_SERVER=29000@FSAE-SUPERCOMPUTER.MIT.EDU"

set "NX_PATH=SiemensNX-2506.8901_wntx64.zip"
set "NX_DIR=SiemensNX-2506.8901_wntx64"
set "NX_DEFAULTS_PATH=NX_user.dpv"
set "NX_USER_MTX=user.mtx"
set "NX_USER_PREFERENCES=UserPreferences.txt"
set "NX_USER_PROFILE=UserProfile.dat"
set "NX_USER_TOGGLES=feature_toggle_user.fcg"
set "NX_USER_DIALOGS=DialogMemory.dlx"
set "NX_USER_LOAD_OPTIONS=load_options.def"

set "TC_PATH=tc2506_my27.zip"
set "TC_DIR=tc2506_my27"
set "TC_PATCH_PATH=tc2506.0009_wntx64.zip"
set "TC_PATCH_DIR=wntx64"

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

set "TEMP_DIR=C:\Siemens_Temp"
set "INSTALL_DIR=C:\Siemens\%MODEL_YEAR%"
set "NX_INSTALL_DIR=%INSTALL_DIR%"

rem Do not include spaces as this will prevent the NX installer from running
set "NX_FEATURES=ALL"

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
echo Check your past installation directory. Existing files will NOT be deleted.
echo.

choice /n /m "Go to Skip point? (For development only) [Y/N] "
if errorlevel 2 (
    echo Continuing with installation...
) else (
    set "KEEP_NX_DEFAULTS=false"
    goto SKIP
)

:: ========== ADVANCED/DEFAULT SELECTION ==========
choice /n /m "Perform default installation? (NX and Teamcenter only) [Y/N] "
if errorlevel 2 (
    goto MENU
) else (
    set "clean_choices=1 2"
    goto NX_DEFAULTS
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

:: ========= NX DEFAULTS OVERWRITE ==========
:NX_DEFAULTS
set "KEEP_NX_DEFAULTS=true"
if not "!clean_choices:1=!"=="!clean_choices!" (
    choice /n /m "Do you want to overwrite NX default settings? [Y/N] "
    if errorlevel 1 (
        set "KEEP_NX_DEFAULTS=false"
    )
)

:: ========= FETCH ==========
:FETCH
cls
echo Fetching installation files and preparing to install selected software...
echo This may take a while depending on your internet connection and the size of the selected software packages.

rem Make temporary directory for staging files
mkdir "%TEMP_DIR%" >NUL 2>&1
set "CURL_ARGS="

rem All software installations require Java
call :downloadAndExtract "%JAVA_PATH%"
if not JAVA_PATH=="" (
    set "JAVA_PATH=%JAVA_DIR%"
)

if not "!clean_choices:1=!"=="!clean_choices!" (
    call :DownloadAndExtract "%NX_PATH%"
    call :DownloadAndExtract "%NX_DEFAULTS_PATH%"
    call :DownloadAndExtract "%NX_USER_MTX%"
    call :DownloadAndExtract "%NX_USER_PREFERENCES%"
    call :DownloadAndExtract "%NX_USER_PROFILE%"
    call :DownloadAndExtract "%NX_USER_TOGGLES%"
    call :DownloadAndExtract "%NX_USER_DIALOGS%"
    call :DownloadAndExtract "%NX_USER_LOAD_OPTIONS%"
    if not NX_PATH=="" (
        set "NX_PATH=%NX_DIR%"
    )
)

if not "!clean_choices:2=!"=="!clean_choices!" (
    call :DownloadAndExtract "%TC_PATH%"
    if not TC_PATH=="" (
        set "TC_PATH=%TC_DIR%"
    )

    call :DownloadAndExtract "%TC_PATCH_PATH%"
    if not TC_PATCH_PATH=="" (
        set "TC_PATCH_PATH=%TC_PATCH_DIR%"
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

:: ========= INSTALLATION ==========
:INSTALL
echo.
echo Installing software that was fetched successfully...
echo Creating installation directory at "%INSTALL_DIR%"...
mkdir "%INSTALL_DIR%" >NUL 2>&1
echo Setting permissions for installation directory...
takeown /f "%INSTALL_DIR%" /r /d y >NUL 2>&1
icacls "%INSTALL_DIR%" /grant *S-1-1-0:(OI)(CI)F /t /c /q >NUL 2>&1

call :InstallJava

if not "!clean_choices:1=!"=="!clean_choices!" (
    call :InstallNX
)

if not "!clean_choices:2=!"=="!clean_choices!" (
    call :InstallTeamcenter
)

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
:: 1. Formulate the full URL and local destination path
set "FULL_URL=%VFS_PATH%%ArchivePath%"
set "LOCAL_DEST=%TEMP_DIR%\%ArchivePath%"

:: 2. Use PowerShell BITS to download with robust retries
powershell -Command "Start-BitsTransfer -Source '%FULL_URL%' -Destination '%LOCAL_DEST%' -RetryInterval 60 -RetryTimeout 300 -ErrorAction Stop"

if %ERRORLEVEL% NEQ 0 (
    echo [31m[ERROR][0m Failed to fetch %ArchivePath%.
    echo Skipping installation of this software.
    echo.
    timeout /t 2 >nul

    set "%~1="
    goto :eof
) else (
    echo [32m[SUCCESS][0m Fetched %ArchivePath%.
)

if /i "%ArchivePath:~-4%"==".zip" set "ValidArchive=1"
if /i "%ArchivePath:~-3%"==".7z"  set "ValidArchive=1"
if /i "%ValidArchive%"=="1" (
    echo Extracting %ArchivePath%...
    tar -xf "%TEMP_DIR%\%ArchivePath%" -C "%TEMP_DIR%" >NUL 2>&1
    if errorlevel 1 (
        echo [31m[ERROR][0m Failed to extract %ArchivePath%.
        echo Skipping installation of this software.
        echo.
        timeout /t 2 >nul

        set "%~1="
    ) else (
        echo [32m[SUCCESS][0m Extracted %ArchivePath%.
    )
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

echo [Java: 1/2] Copying %JAVA_PATH% to %INSTALL_DIR%...
robocopy "%TEMP_DIR%\%JAVA_PATH%" "%INSTALL_DIR%\%JAVA_PATH%" /mir >NUL 2>&1
if errorlevel 3 (
    echo.
    echo [31m[ERROR][0m Failed to copy %TEMP_DIR%\%JAVA_PATH% to %INSTALL_DIR%
    echo Skipping installation of this software.
    echo.
    timeout /t 1 >nul
    goto :eof
) else (
    echo [32m[SUCCESS][0m Copied %TEMP_DIR%\%JAVA_PATH% to %INSTALL_DIR%
)

echo [Java: 2/2] Setting UGII_JAVA_HOME environment variable...
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
echo Installing NX...
if %NX_PATH%=="" (
    echo [31m[ERROR][0m NX installation path is not set. Skipping NX installation.
    goto :eof
)

echo [NX: 1/10] setting SPLM_LICENSE_SERVER environment variable...
set "SPLM_LICENSE_SERVER=%LICENSE_SERVER%" >NUL 2>&1
setx SPLM_LICENSE_SERVER "%LICENSE_SERVER%" /M >NUL 2>&1
if defined SPLM_LICENSE_SERVER (
    echo [32m[SUCCESS][0m SPLM_LICENSE_SERVER environment variable set to %SPLM_LICENSE_SERVER%.
) else (
    echo [31m[ERROR][0m Failed to set SPLM_LICENSE_SERVER environment variable.
    echo Please set it manually to %LICENSE_SERVER%.
)

echo [NX: 2/10] setting UGII_BASE_DIR environment variable...
if defined UGII_BASE_DIR (
    if "%UGII_BASE_DIR:NX2506=%"=="!UGII_BASE_DIR!" (
        set "UGII_BASE_DIR=%INSTALL_DIR%\NX2506" >NUL 2>&1
        setx UGII_BASE_DIR "%INSTALL_DIR%\NX2506" /M >NUL 2>&1
        if defined UGII_BASE_DIR (
            echo [32m[SUCCESS][0m UGII_BASE_DIR environment variable set to !UGII_BASE_DIR!.
        ) else (
            echo [31m[ERROR][0m Failed to set UGII_BASE_DIR environment variable.
            echo Please set it manually to %INSTALL_DIR%\NX2506.
        )
    ) else (
        echo [33m[WARN][0m UGII_BASE_DIR environment variable already set to %UGII_BASE_DIR%.
        echo This means NX 2506 is already installed. Only updating NX.
        set "NX_INSTALL_DIR=%UGII_BASE_DIR:\NX2506=%"
    )
) else (
    set "UGII_BASE_DIR=%INSTALL_DIR%\NX2506" >NUL 2>&1
    setx UGII_BASE_DIR "%INSTALL_DIR%\NX2506" /M >NUL 2>&1
    if defined UGII_BASE_DIR (
        echo [32m[SUCCESS][0m UGII_BASE_DIR environment variable set to !UGII_BASE_DIR!.
    ) else (
        echo [31m[ERROR][0m Failed to set UGII_BASE_DIR environment variable.
        echo Please set it manually to %INSTALL_DIR%\NX2506.
    )
)

echo [NX: 3/10] Running Setup.exe for NX installation, this may take a while...
%TEMP_DIR%\%NX_PATH%\nx\Setup.exe /s /w /v" /qn LICENSESERVER=%LICENSE_SERVER% INSTALLDIR=\"%INSTALL_DIR%\NX2506\" ADDLOCAL=\"%NX_FEATURES%\""
if exist "!NX_INSTALL_DIR!\NX2506\UGII\ugraf.exe" (
    echo [32m[SUCCESS][0m NX installation completed successfully.
) else (
    echo [31m[ERROR][0m NX installation failed. Please check the log files in %TEMP_DIR%\%NX_PATH%\nx\ for more details.
    goto :eof
)

echo [NX: 4/10] Setting UGII_UGMGR_HTTP_URL environment variable...
set "UGII_UGMGR_HTTP_URL=http://fsae-supercomputer:7001/tc" >NUL 2>&1
setx UGII_UGMGR_HTTP_URL "http://fsae-supercomputer:7001/tc" /M >NUL 2>&1
if defined UGII_UGMGR_HTTP_URL (
    echo [32m[SUCCESS][0m UGII_UGMGR_HTTP_URL environment variable set to !UGII_UGMGR_HTTP_URL!.
) else (
    echo [31m[ERROR][0m Failed to set UGII_UGMGR_HTTP_URL environment variable.
    echo Please set it manually to http://fsae-supercomputer:7001/tc.
)
pause

echo [NX: 5/10] Setting NX Bundles...
reg add "HKCU\Software\Siemens_PLM_Software\Common_Licensing" /v NX_BUNDLES /t REG_SZ /d "ACD11,ACD10,SCACAD100" /f >NUL 2>&1
for /f "tokens=2,*" %%A in ('reg query "HKCU\Software\Siemens_PLM_Software\Common_Licensing" /v "NX_BUNDLES" 2^>nul') do (
    set "REG_VALUE=%%B"
)
if "!REG_VALUE!"=="ACD11,ACD10,SCACAD100" (
    echo [32m[SUCCESS][0m NX_BUNDLES registry key set successfully.
) else (
    echo [31m[ERROR][0m Failed to set NX_BUNDLES registry key. Please apply bundles manually in NX or by using the Licensing Tool.
)
:SKIP2
if "%KEEP_NX_DEFAULTS%"=="false" (
    echo [NX: 6/10] Overwriting NX default settings...
    robocopy "%TEMP_DIR%" "%USERPROFILE%\AppData\Local\Siemens\NX2506" "%NX_DEFAULTS_PATH%" /copyall >NUL 2>&1
    if errorlevel 3 (
        echo [31m[ERROR][0m Failed to overwrite NX default settings.
        echo Please apply defaults manually in NX or by using the Licensing Tool.
    ) else (
        echo [32m[SUCCESS][0m NX default settings overwritten successfully.
    )
) else (
    echo [34m[INFO][0m [NX: 6/10] Keeping existing NX default settings.
)

echo [NX: 7/10] Applying FSAE role...
robocopy "%TEMP_DIR%" "%USERPROFILE%\AppData\Local\Siemens\NX2506" "%NX_USER_MTX%" "%NX_USER_PREFERENCES%" "%NX_USER_PROFILE%" /copyall >NUL 2>&1
if errorlevel 3 (
    echo [31m[ERROR][0m Failed to apply FSAE role.
    echo Please apply role manually in NX.
) else (
    echo [32m[SUCCESS][0m FSAE role applied successfully.
)

echo [NX: 8/10] Applying FSAE feature toggles...
robocopy "%TEMP_DIR%" "%USERPROFILE%\AppData\Local\Siemens\NX2506" "%NX_USER_TOGGLES%" /copyall >NUL 2>&1
if errorlevel 3 (
    echo [31m[ERROR][0m Failed to apply FSAE feature toggles.
    echo Please disable new sketch solver manually in NX.
) else (
    echo [32m[SUCCESS][0m FSAE feature toggles applied successfully.
)

echo [NX: 9/10] Applying FSAE dialog settings...
robocopy "%TEMP_DIR%" "%USERPROFILE%\AppData\Local\Siemens\NX2506" "%NX_USER_DIALOGS%" /copyall >NUL 2>&1
if errorlevel 3 (
    echo [31m[ERROR][0m Failed to apply FSAE dialog settings.
    echo Please got to "Assembly Load Options" and set "Load Behavior" to "Allow Replacement"
) else (
    echo [32m[SUCCESS][0m FSAE dialog settings applied successfully.
)

echo [NX: 10/10] Applying FSAE load options...
robocopy "%TEMP_DIR%" "%USERPROFILE%\AppData\Local\Siemens\NX2506" "%NX_USER_LOAD_OPTIONS%" /copyall >NUL 2>&1
if errorlevel 3 (
    echo [31m[ERROR][0m Failed to move FSAE load options.
    echo Please go to "Assembly Load Options" and set "Load Behavior" to "Allow Replacement"
) else (
    echo [32m[SUCCESS][0m FSAE load options moved successfully.
    set "UGII_LOAD_OPTIONS=%USERPROFILE%\AppData\Local\Siemens\NX2506\%NX_USER_LOAD_OPTIONS%"
    setx "UGII_LOAD_OPTIONS" "%USERPROFILE%\AppData\Local\Siemens\NX2506\%NX_USER_LOAD_OPTIONS%" /M >NUL 2>&1
    if defined UGII_LOAD_OPTIONS (
        echo [32m[SUCCESS][0m UGII_LOAD_OPTIONS environment variable set to !UGII_LOAD_OPTIONS!.
    ) else (
        echo [31m[ERROR][0m Failed to set UGII_LOAD_OPTIONS environment variable.
        echo Please set it manually to %USERPROFILE%\AppData\Local\Siemens\NX2506\%NX_USER_LOAD_OPTIONS%.
    )
)
pause
goto QUIT
goto :eof

:InstallTeamcenter
rem Usage: call :InstallTeamcenter
echo.
echo Installing Teamcenter...
if %TC_PATH%=="" (
    echo [31m[ERROR][0m Teamcenter installation path is not set. Skipping Teamcenter installation.
    goto :eof
)

echo [1/1] Running tem.bat for Teamcenter installation, this may take a while...
cd /d "%TEMP_DIR%\%TC_PATH%"
call tem.bat -jre %INSTALL_DIR%\%JAVA_PATH% -s silent.xml
cd /d "%~dp0"

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
