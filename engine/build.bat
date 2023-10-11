REM Build script for engine
@echo off
SetLocal EnableDelayedExpansion

set assembly=engine
set defines=-debug -define:THOR_EXPORT=true

echo Building %assembly%...
odin build . -out=../bin/%assembly%.dll -build-mode:shared %defines%