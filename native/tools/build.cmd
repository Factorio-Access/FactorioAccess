@echo off
rem Configure (first time) and build the native code. Safe to run from anywhere.
cd /d "%~dp0.."
if not exist build\ninja\build.ninja (
  call tools\vsdev.cmd cmake -S . -B build\ninja -G Ninja -DCMAKE_BUILD_TYPE=RelWithDebInfo || exit /b 1
)
call tools\vsdev.cmd cmake --build build\ninja --parallel
