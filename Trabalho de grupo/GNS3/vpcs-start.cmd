@ECHO OFF&SETLOCAL

TITLE Virtual PC Simulator

REM Temporary add GNS3 folder in system PATH, so "vpcs.exe" will load "cygwin1.dll" from that folder prior to any other location
SET PATH=%~dp0\vpcs;%PATH%

ECHO Setting working directory to: %TEMP%
CD /D %TEMP%

REM Launch a local copy of vpcs...
VPCS
PAUSE