@ECHO OFF&SETLOCAL

TITLE Dynamips Hypervisor - Cisco Router Simulation Platform

REM Temporary add GNS3 folder to the system PATH, so "dynamips.exe" will load its .dll files from there
SET PATH=%~dp0\dynamips;%PATH%

REM Change the working directory to temporary folder...
CD /D "%TEMP%"

REM Launch a local copy of dynamips...
START /B /WAIT /BELOWNORMAL "" "%~dp0\dynamips\dynamips.exe" -H 7200
PAUSE
