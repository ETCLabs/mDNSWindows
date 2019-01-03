# CMakeList.txt : CMake project created by ETC to build the Windows mDNS DLL
#
# The approach here is to create two libraries - one that communicates with the
# mDNSResponder service built by this repository, and one that is compatible with
# Apple's Bonjour service. An interface library is created that contains all of
# the shared settings between the two libraries.

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

add_library(dnssd_core INTERFACE)

# These lines are in order, as the last match takes precedence
source_group("Header Files" FILES ${HEADERS})
source_group("Resource Files" FILES ${RESOURCES})
source_group("Source Files" FILES ${SOURCES})

target_compile_definitions(dnssd_core INTERFACE
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
target_include_directories(dnssd_core INTERFACE
  ${CMAKE_CURRENT_LIST_DIR}/../../mDNSCore
  ${CMAKE_CURRENT_LIST_DIR}/../../mDNSShared
  ${CMAKE_CURRENT_LIST_DIR}/..
)
target_link_libraries(dnssd_core INTERFACE ws2_32 iphlpapi)

install(FILES
  ${CMAKE_CURRENT_LIST_DIR}/../../mDNSShared/dns_sd.h
  DESTINATION include
)

# The DLL that communicates with our mDNSResponder

add_library(dnssd_etc SHARED ${HEADERS} ${RESOURCES} ${SOURCES})
target_link_libraries(dnssd_etc PRIVATE dnssd_core)

# We want to make the IDE source groups, project name, and project properties
# similar to the original MSVC project.
set_target_properties(dnssd_etc PROPERTIES
  PROJECT_LABEL DLL
  OUTPUT_NAME dnssd
  ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/etc_dll
  RUNTIME_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/etc_dll
)

install(TARGETS dnssd_etc
  RUNTIME DESTINATION dll
)

# The DLL that communicates with an already-installed Bonjour

add_library(dnssd_bonjour SHARED ${HEADERS} ${RESOURCES} ${SOURCES})
target_compile_definitions(dnssd_bonjour PRIVATE TCP_LOOPBACK_BONJOUR_COMPAT)
target_link_libraries(dnssd_bonjour PRIVATE dnssd_core)

# We want to make the IDE source groups, project name, and project properties
# similar to the original MSVC project.
set_target_properties(dnssd_bonjour PROPERTIES
  PROJECT_LABEL BONJOUR_DLL
  OUTPUT_NAME dnssd
  ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/bonjour_dll
  RUNTIME_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/bonjour_dll
)

install(TARGETS dnssd_bonjour
  RUNTIME DESTINATION bonjour_dll
)
