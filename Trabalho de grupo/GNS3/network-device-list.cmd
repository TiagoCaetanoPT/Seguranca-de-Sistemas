@ECHO OFF&SETLOCAL ENABLEEXTENSIONS
TITLE Network adapters on this machine: [%COMPUTERNAME%]

REM Temporary add GNS3 folder to the system PATH, so "dynamips.exe" will load its .dll files from there
SET PATH=%~dp0\dynamips;%PATH%

REM Change the working directory to temporary folder...
CD /D "%TEMP%"

ECHO.&ECHO Network adapters on this machine:

FOR /F "usebackq tokens=2,4 delims=:/'" %%G IN (`dynamips.exe -e ^| FIND "rpcap"`) DO (
	ECHO.&ECHO NIO_gen_eth:%%~G
	IF "%%~G "=="\Device\NPF_GenericDialupAdapter" (
		ECHO  Description: %%~H
	) ELSE (
		SETLOCAL ENABLEDELAYEDEXPANSION
		SET KEY=%%~G
		FOR /F "usebackq tokens=1,2,* delims= " %%K IN (`REG QUERY "HKLM\SYSTEM\CurrentControlSet\Control\Network\{4D36E972-E325-11CE-BFC1-08002BE10318}\!KEY:~12,38!\Connection" /v Name^| FIND /I "Name"`) DO (
			ECHO  Name       : %%M
		)
		FOR /F "usebackq tokens=1,2,* delims= " %%K IN (`^(REG QUERY "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\!KEY:~12,38!" 2^>NUL ^|^| @ECHO IPAddress x DHCP^)^| FIND /I "IPAddress"`) DO (
			ECHO  IP Address : %%M
		)
		SETLOCAL DISABLEDELAYEDEXPANSION
		ECHO  Description: %%~H
	)
)

ECHO.&ECHO.
ECHO Use as follows:
ECHO  F0/0 = NIO_gen_eth:\Device\NPF_{...}
ECHO.&ECHO.
PAUSE
