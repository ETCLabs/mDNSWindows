# CMakeList.txt : CMake project created by ETC to build the Windows mDNSResponder service 
#

set(HEADERS
  ${CMAKE_CURRENT_LIST_DIR}/../../mDNSShared/CommonServices.h
  ${CMAKE_CURRENT_LIST_DIR}/../../mDNSShared/DebugServices.h
  ${CMAKE_CURRENT_LIST_DIR}/../../mDNSCore/DNSCommon.h
  ${CMAKE_CURRENT_LIST_DIR}/../../mDNSShared/dnssd_ipc.h
  ${CMAKE_CURRENT_LIST_DIR}/../../mDNSShared/GenLinkedList.h
  ${CMAKE_CURRENT_LIST_DIR}/../../mDNSCore/mDNSDebug.h
  ${CMAKE_CURRENT_LIST_DIR}/../../mDNSCore/mDNSEmbeddedAPI.h
  ${CMAKE_CURRENT_LIST_DIR}/../mDNSWin32.h
  ${CMAKE_CURRENT_LIST_DIR}/../Poll.h
  ${CMAKE_CURRENT_LIST_DIR}/Resource.h
  ${CMAKE_CURRENT_LIST_DIR}/../Secret.h
  ${CMAKE_CURRENT_LIST_DIR}/Service.h
  ${CMAKE_CURRENT_LIST_DIR}/../../mDNSCore/uDNS.h
  ${CMAKE_CURRENT_LIST_DIR}/../../mDNSShared/uds_daemon.h
  ${CMAKE_CURRENT_LIST_DIR}/../../mDNSCore/anonymous.h
  ${CMAKE_CURRENT_LIST_DIR}/../../mDNSCore/CryptoAlg.h
)

set(RESOURCES
  ${CMAKE_CURRENT_LIST_DIR}/Service.rc
  ${CMAKE_CURRENT_LIST_DIR}/res/mDNSResponder.manifest
)

set(SOURCES
  ${CMAKE_CURRENT_LIST_DIR}/../../mDNSShared/DebugServices.c
  ${CMAKE_CURRENT_LIST_DIR}/../../mDNSCore/DNSCommon.c
  ${CMAKE_CURRENT_LIST_DIR}/../../mDNSCore/DNSDigest.c
  ${CMAKE_CURRENT_LIST_DIR}/../../mDNSShared/dnssd_ipc.c
  ${CMAKE_CURRENT_LIST_DIR}/EventLog.mc
  ${CMAKE_CURRENT_LIST_DIR}/Firewall.cpp
  ${CMAKE_CURRENT_LIST_DIR}/../../mDNSShared/GenLinkedList.c
  ${CMAKE_CURRENT_LIST_DIR}/../../mDNSMacOSX/LegacyNATTraversal.c
  ${CMAKE_CURRENT_LIST_DIR}/main.c
  ${CMAKE_CURRENT_LIST_DIR}/../../mDNSCore/mDNS.c
  ${CMAKE_CURRENT_LIST_DIR}/../../mDNSShared/mDNSDebug.c
  ${CMAKE_CURRENT_LIST_DIR}/../mDNSWin32.c
  ${CMAKE_CURRENT_LIST_DIR}/../Poll.c
  ${CMAKE_CURRENT_LIST_DIR}/../Secret.c
  ${CMAKE_CURRENT_LIST_DIR}/Service.c
  ${CMAKE_CURRENT_LIST_DIR}/../../mDNSCore/uDNS.c
  ${CMAKE_CURRENT_LIST_DIR}/../../mDNSShared/uds_daemon.c
  ${CMAKE_CURRENT_LIST_DIR}/../../mDNSCore/anonymous.c
  ${CMAKE_CURRENT_LIST_DIR}/../../mDNSCore/CryptoAlg.c
)

add_executable(mDNSResponder ${HEADERS} ${RESOURCES} ${SOURCES})

# Handle the Message Compiler file EventLog.mc, which generates the header file EventLog.h
add_custom_command(
  OUTPUT EventLog.rc EventLog.h
  COMMAND mc.exe EventLog.mc
  MAIN_DEPENDENCY EventLog.mc
  WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}
  COMMENT "Compiling Message Resource"
)

# We want to make the IDE source groups, project name, and project properties similar to the original MSVC project.
set_target_properties(mDNSResponder PROPERTIES PROJECT_LABEL mDNSResponder)
source_group("Header Files" FILES ${HEADERS})
source_group("Resource Files" FILES ${RESOURCES})
source_group("Source Files" FILES ${SOURCES})

target_compile_definitions(mDNSResponder PRIVATE
  _CONSOLE
  UNICODE
  _UNICODE
  MDNS_DEBUGMSGS=0
  TARGET_OS_WIN32
  WIN32_LEAN_AND_MEAN
  USE_TCP_LOOPBACK
  PLATFORM_NO_STRSEP
  PLATFORM_NO_EPIPE
  PLATFORM_NO_RLIMIT
  PID_FILE="" 
  _CRT_SECURE_NO_DEPRECATE
  _WINSOCK_DEPRECATED_NO_WARNINGS
  _CRT_SECURE_CPP_OVERLOAD_STANDARD_NAMES=1
  PLATFORM_HAVE_INET_PTON
  _LEGACY_NAT_TRAVERSAL_
)
target_include_directories(mDNSResponder PRIVATE
  ${CMAKE_CURRENT_LIST_DIR}/../../mDNSCore
  ${CMAKE_CURRENT_LIST_DIR}/../../mDNSShared
  ${CMAKE_CURRENT_LIST_DIR}/.
  ${CMAKE_CURRENT_LIST_DIR}/..
)
set_target_properties(mDNSResponder PROPERTIES
  LINK_FLAGS "/level='requireAdministrator' /uiAccess='false'"
)
target_link_libraries(mDNSResponder PRIVATE
  ws2_32
  iphlpapi
  crypt32
  netapi32
  powrprof
)

install(TARGETS mDNSResponder
  RUNTIME DESTINATION bin
)