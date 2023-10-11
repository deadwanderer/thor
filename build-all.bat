@echo off
REM Build everything

echo Building everything...

pushd engine
call build.bat
popd
if %ERRORLEVEL% neq 0 (echo Error:%ERRORLEVEL% && exit)

pushd testbed
call build.bat
popd
if %ERRORLEVEL% neq 0 (echo Error:%ERRORLEVEL% && exit)

echo All assemblies built successfully
@REM pushd bin
@REM call .\testbed.exe
@REM popd
@REM if %ERRORLEVEL% neq 0 (echo Error:%ERRORLEVEL% && exit)