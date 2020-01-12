::v0.2.2, 01.october.2015, N!NiX and Jeremy Grossmann
@ECHO OFF&SETLOCAL

TITLE Loopback NICs manager for Windows - v0.2.2
SET PASS=0&SET N=0&SET CLI=

ECHO 1^) Checking Windows version... & REM http://en.wikipedia.org/wiki/Ver_(command)
FOR /F "usebackq tokens=2,3 delims=. " %%G IN (`@FOR /F "tokens=2 delims=[]" %%L IN ^('@VER'^) DO @ECHO %%L`) DO (
	IF %%G LSS 5               GOTO ERROR_OLD_OS
	IF %%G EQU 5 IF %%H LSS 1  GOTO ERROR_OLD_OS
	SET PASS=1
)
IF "%PASS%" == "0"            (GOTO ERROR_OLD_OS) ELSE (SETLOCAL ENABLEEXTENSIONS)

:: Try to do something that is off limits if not elevated privilege
ECHO.&ECHO 2^) Checking script privileges...
REG QUERY "HKU\S-1-5-19" >NUL 2>&1 || GOTO ERROR_NOT_ADMIN

CLS
CD /D "%~dp0"

SET DEVCON=devcon.exe

:CHOOSE
SET Q=&SET /A N+=1
IF NOT "%~1"=="" (
	SET Q=%~1
	SET CLI=1
	SHIFT
) ELSE (
	IF %N%==1 (
		CALL :MENU
		ECHO.&SET /P Q="Choose a option: "
	) ELSE (
		ECHO.&SET /P Q="Choose a option: "
	)
)
IF "%Q%"=="1"  (CALL :LIST        & IF NOT DEFINED CLI (GOTO CHOOSE) ELSE (GOTO :EOF))
IF "%Q%"=="2"  (CALL :INSTALL     & IF NOT DEFINED CLI (GOTO CHOOSE) ELSE (GOTO :EOF))
IF "%Q%"=="3"  (CALL :REMOVE_MENU & IF NOT DEFINED CLI (GOTO CHOOSE) ELSE (GOTO :EOF))
IF "%Q%"=="4"  (CALL :REMOVE_ALL  & IF NOT DEFINED CLI (GOTO CHOOSE) ELSE (GOTO :EOF))
IF "%Q%"=="5"   GOTO REBOOT
IF "%Q%"=="6"   GOTO :EOF
IF "%Q%"=="?"  (CALL :MENU        & IF NOT DEFINED CLI (GOTO CHOOSE) ELSE (GOTO :EOF))
IF "%Q%"=="/?" (CALL :MENU        & IF NOT DEFINED CLI (GOTO CHOOSE) ELSE (GOTO :EOF))
IF "%Q%"=="-h" (CALL :MENU        & IF NOT DEFINED CLI (GOTO CHOOSE) ELSE (GOTO :EOF))
ECHO Incorect option!             & IF NOT DEFINED CLI (GOTO CHOOSE) ELSE (ECHO.&ECHO ^[Available options^]&GOTO MENU)

:LIST
ECHO.&ECHO Installed Loopback interfaces:
%DEVCON% find *MSLOOP
GOTO :EOF

:INSTALL
ECHO.&ECHO Installing a new Loopback interface (Takes about 30s)...
%DEVCON% install %WINDIR%\inf\netloop.inf *MSLOOP
ECHO.&ECHO Warning: To make this interface available&ECHO          you have to reboot your computer!
GOTO :EOF

:REMOVE_MENU
SET LNR=0
ECHO.&ECHO Installed Loopback interfaces:
SETLOCAL ENABLEDELAYEDEXPANSION
FOR /F "tokens=1 delims= " %%G IN ('%DEVCON% find *MSLOOP ^| FIND "ROOT"') DO (
	SET /A LNR+=1
	ECHO !LNR!^) - '%%G'
)
ECHO.&SET QNR=&SET /P QNR="Please select the interface number: "
SET LNR=0
FOR /F "tokens=1 delims= " %%G IN ('%DEVCON% find *MSLOOP ^| FIND "ROOT"') DO (
	SET /A LNR+=1
	IF !LNR!.==%QNR%. (
		ECHO Removing interface '%%G'...
		%DEVCON% remove @%%G
		SETLOCAL DISABLEDELAYEDEXPANSION
		GOTO :EOF
	)
)
SETLOCAL DISABLEDELAYEDEXPANSION
ECHO Incorrect interface number!
GOTO :EOF

:REMOVE_ALL
ECHO.&ECHO Remove all Loopback interfaces from this system...
%DEVCON% remove *MSLOOP
GOTO :EOF

:MENU
ECHO.
ECHO 1^) List all installed Loopback interfaces
ECHO 2^) Install a new Loopback interface (reboot required)
ECHO 3^) Remove a Loopback interface
ECHO 4^) Remove all Loopback interfaces
ECHO 5^) Reboot PC
ECHO 6^) Quit
ECHO ?^) This Menu
GOTO :EOF

:ERROR_OLD_OS
ECHO.
ECHO This script is not for Windows 95, 98 or ME.
ECHO.
PAUSE >NUL
GOTO :EOF

:ERROR_NOT_ADMIN
ECHO.
ECHO This script is not running with sufficient privileges.
ECHO.
ECHO Under Windows Vista and later Windows versions, you should launch this 
ECHO script by right-clicking and choosing Run As Administrator.
ECHO.
PAUSE >NUL
GOTO :EOF

:REBOOT
ECHO.&ECHO This computer is restarting now! &MSG "%USERNAME%" "This computer is restarting now!"
SHUTDOWN -r -t 0
PAUSE >NUL
GOTO :EOF
