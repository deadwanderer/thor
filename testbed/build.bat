REM Build script for testbed
@echo off
SetLocal EnableDelayedExpansion

set assembly=testbed
set defines=-debug -define:THOR_IMPORT=true 
REM -define:THOR_PLATFORM_WINDOWS=true

echo Building %assembly%...
odin build . -out=../bin/%assembly%.exe -build-mode:exe %defines%