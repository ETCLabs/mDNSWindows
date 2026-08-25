echo OFF

REM Build the mDNSWindows installer

REM Arguments: none
REM Requires:
REM - python
REM - %ProgramFiles(x86)%\NSIS\makensis.exe
REM
REM TODO: add requirements for signing
REM
REM Assumptions:
REM Previous pipeline stage has created
REM   C:/git/mdnswindows/build_x86/install/bin/mDNSResponder.exe
REM
REM     and
REM
REM   C:/git/mdnswindows/build_x64/install/bin/mDNSResponder.exe
REM
REM Example:
REM   C:\git>cd mdnswindows\tools\ci
REM   C:\git\mdnswindows\tools\ci>build_mdns_installer.bat

cd ..\..

REM sign x86 mDMSResponder.exe
REM cd build_x86\install\bin
REM sign mDNSResponder.exe

REM cd ..\..\..

REM sign 64-bit mDMSResponder.exe
REM cd build_x64\install\bin
REM sign mDNSResponder.exe

REM cd ..\..\..

ECHO cd tools\install
cd tools\install

echo Build the mDNSWindows installers

REM During "normal" use NSIS 3.10 does not allow the uninstaller to be signed. It creates the uninstaller
REM in a temporary directory, adds it to the installer, and delete the uninstaller. The next few steps involve
REM two separate NSIS script. The first script generates the uninstaller, wrapped in a "fake" installer. The
REM fake installer only contains the uninstaller, and installs it in the same directory as the installer.
REM
REM The fake installer is run, and then deleted. The uninstaller is then signed and is available for the
REM second NSIS script which generates the "real" SLP installer.

REM create a fake x86 installer SLP_Fake_Install.exe
echo "%ProgramFiles(x86)%\NSIS\makensis.exe" /DARTIFACT_TYPE=86 mDNS_Uninstall.nsi
"%ProgramFiles(x86)%\NSIS\makensis.exe" /DARTIFACT_TYPE=86 mDNS_Uninstall.nsi
if %ERRORLEVEL% NEQ 0 ( EXIT /B %ERRORLEVEL% )

REM wait a few seconds for the fake installer to become available
echo ping 127.0.0.1 -n 6 >nul
ping 127.0.0.1 -n 6 >nul

REM run the fake x86 installer in silent mode to "install" the uninstaller
echo call mDNS_Fake_Install.exe /S
call mDNS_Fake_Install.exe /S

REM the fake x86 installer does not get checked in to Git
echo del mDNS_Fake_Install.exe
del mDNS_Fake_Install.exe

REM wait a few seconds for the x86 uninstaller to become available
echo ping 127.0.0.1 -n 6 >nul
ping 127.0.0.1 -n 6 >nul

if %ERRORLEVEL% NEQ 0 ( EXIT /B %ERRORLEVEL% )

REM TODO: sign mDNS_Uninstall.exe

REM create the x86 installer
echo "%ProgramFiles(x86)%\NSIS\makensis.exe" /DARTIFACT_TYPE=86 mDNS_Install.nsi
"%ProgramFiles(x86)%\NSIS\makensis.exe" /DARTIFACT_TYPE=86 mDNS_Install.nsi
if %ERRORLEVEL% NEQ 0 ( EXIT /B %ERRORLEVEL% )

REM sign the x86 installer
REM ETC_mDNS_Install_x86.exe
REM if %ERRORLEVEL% NEQ 0 ( EXIT /B %ERRORLEVEL% )

REM delete the x86 uninstaller
echo del mDNS_Uninstall.exe
del mDNS_Uninstall.exe

REM ---

REM create a fake 64-bit installer SLP_Fake_Install.exe
echo "%ProgramFiles(x86)%\NSIS\makensis.exe" /DARTIFACT_TYPE=64 mDNS_Uninstall.nsi
"%ProgramFiles(x86)%\NSIS\makensis.exe" /DARTIFACT_TYPE=64 mDNS_Uninstall.nsi
if %ERRORLEVEL% NEQ 0 ( EXIT /B %ERRORLEVEL% )

REM wait a few seconds for the fake installer to become available
echo ping 127.0.0.1 -n 6 >nul
ping 127.0.0.1 -n 6 >nul

REM run the fake 64-bit installer in silent mode to "install" the uninstaller
echo call mDNS_Fake_Install.exe /S
call mDNS_Fake_Install.exe /S

REM the fake 64-bit installer does not get checked in to Git
echo del mDNS_Fake_Install.exe
del mDNS_Fake_Install.exe

REM wait a few seconds for the 64-bit uninstaller to become available
echo ping 127.0.0.1 -n 6 >nul
ping 127.0.0.1 -n 6 >nul

if %ERRORLEVEL% NEQ 0 ( EXIT /B %ERRORLEVEL% )

REM TODO: sign mDNS_Uninstall.exe

REM create the 64-bit installer
echo "%ProgramFiles(x86)%\NSIS\makensis.exe" /DARTIFACT_TYPE=64 mDNS_Install.nsi
"%ProgramFiles(x86)%\NSIS\makensis.exe" /DARTIFACT_TYPE=64 mDNS_Install.nsi
if %ERRORLEVEL% NEQ 0 ( EXIT /B %ERRORLEVEL% )

REM sign the 64-bit installer
REM ETC_mDNS_Install_x64.exe
REM if %ERRORLEVEL% NEQ 0 ( EXIT /B %ERRORLEVEL% )

REM delete the 64-bit uninstaller
echo del mDNS_Uninstall.exe
del mDNS_Uninstall.exe

cd ..\ci

