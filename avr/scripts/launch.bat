@echo off
setlocal EnableExtensions

REM Parameters
REM %1 = build.source.path
REM %2 = build.mcu
REM %3 = debug.executable
REM %4 = debug.toolchain.path
REM %5 = runtime.tools.avr-gcc.path
REM %6 = build.f_cpu
REM %7 = prelaunch1
REM %8 = prelaunch2

set "V1=%~1"
set "P1=%V1:\=\\%"
set "V2=%~2"
set "P2=%V2:\=\\%"
set "V3=%~3"
set "P3=%V3:\=\\%"
set "V4=%~4"
set "P4=%V4:\=\\%"
set "V5=%~5"
set "P5=%V5:\=\\%"
set "V6=%~6"
set "P6=%V6:\=\\%"
set "V7=%~7"
set "P7=%V7:\=\\%"
set "V8=%~8"
set "P8=%V8:\=\\%"

set "LAUNCH=%P1%\\.vscode\\launch.json"

REM check for .vscode
if not exist "%P1%\.vscode\" (
    echo No .vscode folder
    exit /b 0
)

REM check if already there (same mcu, mcu clock, and same prelaunch commands)
if exist "%LAUNCH%" (
    findstr /C:"\"--device=%P2%\"" "%LAUNCH%" >nul 2>nul
    if %ERRORLEVEL%==0 (
        findstr /C:"\"--F_CPU=%P6%\"" "%LAUNCH%" >nul 2>nul
        if %ERRORLEVEL%==0 (
            set "OK8=1"
            if not "%P8%"=="" (
                findstr /C:"%P8%" "%LAUNCH%" >nul 2>nul
                if not %ERRORLEVEL%==0 set "OK8=0"
            )
            if "%OK8%"=="1" (
               set "OK7=1"
               if not "%P7%"=="" (
                   findstr /C:"%P7%" "%LAUNCH%" >nul 2>nul
                   if not %ERRORLEVEL%==0 set "OK7=0"
               )     
               if "%OK7%"=="1" (
                  echo launch.json already exists
                  exit /b 0
               )
            )
        )
    )
)

REM write JSON base + first config start
> "%LAUNCH%" (
    echo {
    echo     "version": "0.2.0",
    echo     "configurations": [
    echo         {
    echo             "name": "Arduino Debug %P2%",
    echo             "cwd": "${workspaceRoot}",
    echo             "request": "launch",
    echo             "type": "cortex-debug",
    echo             "executable": "%P3%",
    echo             "svdFile": "%P4%\\pyavrocd-util\\svd\\%P2%.svd",
    echo             "gdbPath": "%P4%\\avr-gdb.exe",
    echo             "objdumpPath": "%P5%\\bin\\avr-objdump.exe",
    echo             "overrideGDBServerStartedRegex": "Listening on port \\d+ for gdb connection",
    echo             "runToEntryPoint": "main",
    echo             "serverArgs": [
    echo                 "--start=nop",
    echo                 "--device=%P2%",
    echo                 "--manage=all",
    echo                 "--F_CPU=%P6%",
    echo                 "--prog-clock=2000"
    echo             ],
    echo             "serverpath": "%P4%\\pyavrocd.exe",
    echo             "servertype": "openocd",
    echo             "armToolchainPath": "%P4%",
    echo             "configFiles": [
    echo                 "nix"
    echo             ]
)

REM optional preLaunchCommands for first config
if not "%P8%"=="" (
    >> "%LAUNCH%" (
        echo             ,
        echo             "preLaunchCommands": [
        echo                 "%P7%",
        echo                 "%P8%"
        echo             ]
    )
) else if not "%P7%"=="" (
    >> "%LAUNCH%" (
        echo             ,
        echo             "preLaunchCommands": [
        echo                 "%P7%"
        echo             ]
    )
)

REM close first config, open second config
>> "%LAUNCH%" (
    echo         },
    echo         {
    echo             "name": "Simavr %P2%",
    echo             "cwd": "${workspaceRoot}",
    echo             "request": "launch",
    echo             "type": "cortex-debug",
    echo             "executable": "%P3%",
    echo             "svdFile": "%P4%\\pyavrocd-util\\svd\\%P2%.svd",
    echo             "gdbPath": "%P4%\\avr-gdb.exe",
    echo             "objdumpPath": "%P5%\\bin\\avr-objdump.exe",
    echo             "overrideGDBServerStartedRegex": "Listening on port \\d+ for gdb connection",
    echo             "runToEntryPoint": "main",
    echo             "serverArgs": [
    echo                 "--start=%P4%\\bin\\simavr.exe",
    echo                 "--device=%P2%",
    echo                 "--manage=all",
    echo                 "--F_CPU=%P6%",
    echo                 "--prog-clock=2000"
    echo             ],
    echo             "serverpath": "%P4%\\pyavrocd.exe",
    echo             "servertype": "openocd",
    echo             "armToolchainPath": "%P4%",
    echo             "configFiles": [
    echo                 "nix"
    echo             ]
)

REM optional preLaunchCommands for second config
if not "%P8%"=="" (
    >> "%LAUNCH%" (
        echo             ,
        echo             "preLaunchCommands": [
        echo                 "%P7%",
        echo                 "%P8%"
        echo             ]
    )
) else if not "%P7%"=="" (
    >> "%LAUNCH%" (
        echo             ,
        echo             "preLaunchCommands": [
        echo                 "%P7%"
        echo             ]
    )
)

REM close second config and file
>> "%LAUNCH%" (
    echo         }
    echo     ]
    echo }
)

exit /b 0