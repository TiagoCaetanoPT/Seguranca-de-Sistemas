::v0.2, 21.July.2015, Jeremy Grossmann
@ECHO OFF&SETLOCAL ENABLEEXTENSIONS

TITLE VMnet Manager - v0.2 - [%COMPUTERNAME%]
SET PASS=0&SET N=0&SET CLI=

:: Try to do something that is off limits if not elevated privilege
ECHO.&ECHO 2^) Checking script privileges...
REG QUERY "HKU\S-1-5-19" >NUL 2>&1 || GOTO ERROR_NOT_ADMIN

CLS
CD /D "%~dp0"

FOR /F "usebackq tokens=1,2,* delims= " %%K IN (`REG QUERY "HKLM\SOFTWARE\Wow6432Node\VMware, Inc.\VMware Workstation" /V "InstallPath" 2^>NUL ^| FIND /I "InstallPath"`) DO (
	SET VMWARE_WS=%%M
)

FOR /F "usebackq tokens=1,2,* delims= " %%K IN (`REG QUERY "HKLM\SOFTWARE\Wow6432Node\VMware, Inc.\VMware Player" /V "InstallPath" 2^>NUL ^| FIND /I "InstallPath"`) DO (
	SET VMWARE_PLAYER=%%M
)

IF EXIST "%VMWARE_WS%" SET PATH=%PATH%;%VMWARE_WS%
IF EXIST "%VMWARE_PLAYER%" SET PATH=%PATH%;%VMWARE_PLAYER%

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
IF "%Q%"=="1"  (CALL :ADD        & IF NOT DEFINED CLI (GOTO CHOOSE) ELSE (GOTO :EOF))
IF "%Q%"=="2"  (CALL :REMOVE     & IF NOT DEFINED CLI (GOTO CHOOSE) ELSE (GOTO :EOF))
IF "%Q%"=="3"   GOTO :EOF
IF "%Q%"=="?"  (CALL :MENU        & IF NOT DEFINED CLI (GOTO CHOOSE) ELSE (GOTO :EOF))
IF "%Q%"=="/?" (CALL :MENU        & IF NOT DEFINED CLI (GOTO CHOOSE) ELSE (GOTO :EOF))
IF "%Q%"=="-h" (CALL :MENU        & IF NOT DEFINED CLI (GOTO CHOOSE) ELSE (GOTO :EOF))
ECHO Incorect option!             & IF NOT DEFINED CLI (GOTO CHOOSE) ELSE (ECHO.&ECHO ^[Available options^]&GOTO MENU)


:ADD

ECHO Adding VMnet interfaces...
vnetlib.exe 2> NUL
if %ERRORLEVEL%==9009 (
   ECHO ERROR: vnetlib.exe does not exist, please install VMware Workstation or Player.
   GOTO :EOF
) 
vnetlib.exe -- add adapter vmnet2
vnetlib.exe -- add adapter vmnet3
vnetlib.exe -- add adapter vmnet4
vnetlib.exe -- add adapter vmnet5
vnetlib.exe -- add adapter vmnet6
vnetlib.exe -- add adapter vmnet7
vnetlib.exe -- add adapter vmnet9
vnetlib.exe -- add adapter vmnet10
vnetlib.exe -- add adapter vmnet11
vnetlib.exe -- add adapter vmnet12
vnetlib.exe -- add adapter vmnet13
vnetlib.exe -- add adapter vmnet14
vnetlib.exe -- add adapter vmnet15
vnetlib.exe -- add adapter vmnet16
vnetlib.exe -- add adapter vmnet17
vnetlib.exe -- add adapter vmnet18
vnetlib.exe -- add adapter vmnet19
net stop npf
net start npf

GOTO :EOF

:REMOVE

ECHO Removing VMnet interfaces...
vnetlib.exe 2> NUL
if %ERRORLEVEL%==9009 (
   ECHO ERROR: vnetlib.exe does not exist, please install VMware Workstation or Player.
   GOTO :EOF
) 
vnetlib.exe -- remove adapter vmnet2
vnetlib.exe -- remove adapter vmnet3
vnetlib.exe -- remove adapter vmnet4
vnetlib.exe -- remove adapter vmnet5
vnetlib.exe -- remove adapter vmnet6
vnetlib.exe -- remove adapter vmnet7
vnetlib.exe -- remove adapter vmnet9
vnetlib.exe -- remove adapter vmnet10
vnetlib.exe -- remove adapter vmnet11
vnetlib.exe -- remove adapter vmnet12
vnetlib.exe -- remove adapter vmnet13
vnetlib.exe -- remove adapter vmnet14
vnetlib.exe -- remove adapter vmnet15
vnetlib.exe -- remove adapter vmnet16
vnetlib.exe -- remove adapter vmnet17
vnetlib.exe -- remove adapter vmnet18
vnetlib.exe -- remove adapter vmnet19
net stop npf
net start npf

GOTO :EOF


:MENU
ECHO.
ECHO Add or remove VMnet interfaces on %COMPUTERNAME%
ECHO.
ECHO 1^) Add vmnet interfaces 2 to 19 (vmnet8 excluded)
ECHO 2^) Remove vmnet interfaces from 2 to 19 (vmnet8 excluded)
ECHO 3^) Quit
ECHO ?^) This Menu
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
