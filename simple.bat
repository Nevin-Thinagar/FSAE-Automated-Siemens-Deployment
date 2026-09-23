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

curl -f -L "%VFS_PATH%%ArchivePath%" -o "%TEMP_DIR%\%ArchivePath%"
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
