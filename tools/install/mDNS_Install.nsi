# mDNS_Install.nsi
#
# Do not edit mDNS_Install.nsi, edit mDNS_Install.nsi.in
#
# Create the Windows installer for mDNS
#
# Usage: "C:\Program Files (x86)\NSIS\makensis.exe" mDNS_Install.nsi

!include "WinVer.nsh"
!include "WordFunc.nsh"
!include "Registry.nsh"

# ; MUI 1.67 compatible ------
!include "MUI.nsh"

# ; MUI Settings
!define MUI_ABORTWARNING
!define MUI_ICON "ETCIconDark_NSIS.ico"
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH
!insertmacro MUI_LANGUAGE "English"
# MUI end ------

!ifndef ARTIFACT_TYPE
  !define ARTIFACT_TYPE 86
!endif

!define PRODUCT_NAME "ETC DNS-SD Service x${ARTIFACT_TYPE}"
!define UNINSTALL_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall{8A23B836-C37F-4EB7-9EA9-4CAD5E5EAABF}"

# this value is written when .gitlab-ci.yml runs the command
# - etcdevtool version --from-ci --step update-files . ($NEW_VERSION + ".1")
!define PRODUCT_VERSION "1.3.4"

# the name of the installer
Outfile "ETC_mDNS_Install_x${ARTIFACT_TYPE}.exe"

# Show install details
ShowInstDetails show

# Request application privileges for Windows Vista
RequestExecutionLevel admin

# define the friendly name displayed in the installer pages
Name "${PRODUCT_NAME} ${PRODUCT_VERSION}"

Function .onInit
  # read the registry for the existing installed version of SLP (might be empty string)
  ReadRegStr $R0 "HKLM" "${UNINSTALL_KEY}" "DisplayVersion"
  ClearErrors
  ${If} $R0 != ''
    # a copy of SLP is already installed on this machine

    # run NSIS 'VersionCompare' function
    ${VersionCompare} $R0 ${PRODUCT_VERSION} $R1
    
    # Result:
    #    $R1=0  Versions are equal
    #    $R1=1  $R0 (existing) is newer
    #    $R1=2  $PRODUCT_VERSION (installer) is newer
    ${If} $R1 != '2'
      # the installer version is not newer, do not overwrite
      # silently quit
      Abort
    ${EndIf}
  
  ${EndIf}
FunctionEnd

# default section
Section "Application"
  # this will affect all users
  SetShellVarContext all

  # Running the unstaller using the 'ExecWait' command doesn't work
  # because ExecWait returns when the command prompt is 're-displayed'
  # even though the uninstaller itself is still running.
  #
  # Instead, run the individual unstall steps needed to remove the
  # previous version of DNS-SD. (duplicating code from the uninstaller)
  DetailPrint "Stopping ETC DNS-SD Service"
  DetailPrint "$SYSDIR\sc.exe stop ETC DNS-SD Service"
  ExecWait '$SYSDIR\sc.exe stop "ETC DNS-SD Service"'

  # Do not delete the DNS-SD service

  Delete "$PROGRAMFILES\ETC\DNS-SD\mDNSResponder.exe"

  SetOutPath "$PROGRAMFILES\ETC\DNS-SD"

  # copy mDNSResponder.exe, and the uninstaller
  File "..\..\build_x${ARTIFACT_TYPE}\install\bin\mDNSResponder.exe"
  File mDNS_Uninstall.exe

  # install mDNSResponder service
  DetailPrint "$PROGRAMFILES\ETC\DNS-SD\mDNSResponder.exe -passiveinstall"
  ExecWait '"$PROGRAMFILES\ETC\DNS-SD\mDNSResponder.exe" -passiveinstall'

  # create firewall exceptions
  DetailPrint "netsh advfirewall firewall add rule name=ETC DNS-SD Service (TCP-in) dir=in action=allow program=$PROGRAMFILES\ETC\DNS-SD\mDNSResponder.exe enable=yes profile=domain,public,private protocol=TCP"
  ExecWait 'netsh advfirewall firewall add rule name="ETC DNS-SD Service (TCP-in)" dir=in action=allow program="$PROGRAMFILES\ETC\DNS-SD\mDNSResponder.exe" enable=yes profile=domain,public,private protocol=TCP'
  DetailPrint "netsh advfirewall firewall add rule name=ETC DNS-SD Service (UDP-in) dir=in action=allow program=$PROGRAMFILES\ETC\DNS-SD\mDNSResponder.exe enable=yes profile=domain,public,private protocol=UDP"
  ExecWait 'netsh advfirewall firewall add rule name="ETC DNS-SD Service (UDP-in)" dir=in action=allow program="$PROGRAMFILES\ETC\DNS-SD\mDNSResponder.exe" enable=yes profile=domain,public,private protocol=UDP'

  # start mDNSResponder service
  DetailPrint "$SYSDIR\sc.exe start ${PRODUCT_NAME}"
  ExecWait '$SYSDIR\sc.exe start "${PRODUCT_NAME}"'

  # information for Control Panel "Add / Remove Programs"
  WriteRegStr "HKLM" "${UNINSTALL_KEY}" "DisplayName" "${PRODUCT_NAME}"
  WriteRegStr "HKLM" "${UNINSTALL_KEY}" "InstallLocation" "$PROGRAMFILES\ETC\DNS-SD"
  WriteRegStr "HKLM" "${UNINSTALL_KEY}" "UninstallString" "$PROGRAMFILES\ETC\DNS-SD\mDNS_Uninstall.exe"
  WriteRegStr "HKLM" "${UNINSTALL_KEY}" "DisplayVersion" "${PRODUCT_VERSION}"
  WriteRegStr "HKLM" "${UNINSTALL_KEY}" "URLInfoAbout" "http://www.etcconnect.com"
  WriteRegStr "HKLM" "${UNINSTALL_KEY}" "Publisher" "ETC"
SectionEnd
