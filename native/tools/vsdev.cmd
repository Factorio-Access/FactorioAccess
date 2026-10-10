@echo off
rem Run a command inside the VS 2022 x64 developer environment. Finds any edition (Community, Professional,
rem Enterprise, Build Tools) through vswhere; a bare Build Tools install has no Common7\IDE\...\Ninja, so the
rem Ninja dir is only added when it exists (cmake then needs a ninja on PATH some other way).
setlocal
set "VSROOT="
set "VSWHERE=%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe"
if exist "%VSWHERE%" for /f "usebackq delims=" %%i in (`"%VSWHERE%" -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath`) do set "VSROOT=%%i"
if not defined VSROOT if exist "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat" set "VSROOT=C:\Program Files\Microsoft Visual Studio\2022\Community"
if not defined VSROOT if exist "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvars64.bat" set "VSROOT=C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools"
if not defined VSROOT echo vsdev: no Visual Studio 2022 with the C++ x64 tools found & exit /b 1
call "%VSROOT%\VC\Auxiliary\Build\vcvars64.bat" >nul 2>&1
if exist "%VSROOT%\Common7\IDE\CommonExtensions\Microsoft\CMake\Ninja\ninja.exe" set "PATH=%VSROOT%\Common7\IDE\CommonExtensions\Microsoft\CMake\Ninja;%PATH%"
%*
