# CMakeList.txt : CMake project created by ETC to build the Windows mDNS DLL
#

set(HEADERS
  ${CMAKE_CURRENT_LIST_DIR}/../../mDNSShared/CommonServices.h
  ${CMAKE_CURRENT_LIST_DIR}/../../mDNSShared/DebugServices.h
  ${CMAKE_CURRENT_LIST_DIR}/../../mDNSShared/dns_sd.h
  ${CMAKE_CURRENT_LIST_DIR}/../../mDNSShared/dnssd_ipc.h
  ${CMAKE_CURRENT_LIST_DIR}/../../mDNSShared/GenLinkedList.h
  ${CMAKE_CURRENT_LIST_DIR}/resource.h
)

set(RESOURCES dll.rc)

set(SOURCES
  ${CMAKE_CURRENT_LIST_DIR}/../../mDNSShared/DebugServices.c
  ${CMAKE_CURRENT_LIST_DIR}/dllmain.c
  ${CMAKE_CURRENT_LIST_DIR}/dnssd.def
  ${CMAKE_CURRENT_LIST_DIR}/../../mDNSShared/dnssd_clientlib.c
  ${CMAKE_CURRENT_LIST_DIR}/../../mDNSShared/dnssd_clientstub.c
  ${CMAKE_CURRENT_LIST_DIR}/../../mDNSShared/dnssd_ipc.c
  ${CMAKE_CURRENT_LIST_DIR}/../../mDNSShared/GenLinkedList.c
)

add_library (dnssd SHARED ${HEADERS} ${RESOURCES} ${SOURCES})

# We want to make the IDE source groups, project name, and project properties similar to the original MSVC project.
set_target_properties(dnssd PROPERTIES PROJECT_LABEL DLL)

# These lines are in order, as the last match takes precedence
source_group("Header Files" FILES ${HEADERS})
source_group("Resource Files" FILES ${RESOURCES})
source_group("Source Files" FILES ${SOURCES})

target_compile_definitions(dnssd PRIVATE
  UNICODE
  _UNICODE
  _USRDLL
  MDNS_DEBUGMSGS=0
  WIN32_LEAN_AND_MEAN
  USE_TCP_LOOPBACK
  _CRT_SECURE_NO_DEPRECATE
  _WINSOCK_DEPRECATED_NO_WARNINGS
  _CRT_SECURE_CPP_OVERLOAD_STANDARD_NAMES=1
  NOT_HAVE_SA_LEN
)
target_include_directories(dnssd PRIVATE
  ${CMAKE_CURRENT_LIST_DIR}/../../mDNSCore
  ${CMAKE_CURRENT_LIST_DIR}/../../mDNSShared
  ${CMAKE_CURRENT_LIST_DIR}/..
)
target_link_libraries(dnssd PRIVATE ws2_32 iphlpapi)
