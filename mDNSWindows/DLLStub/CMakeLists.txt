# CMakeList.txt : CMake project created by ETC to build the Windows mDNS DLL Stub library.
# This lib is used for loading the dll.
#

set(DLL_STUB_HEADERS ${CMAKE_CURRENT_LIST_DIR}/DLLStub.h)
set(DLL_STUB_SOURCES ${CMAKE_CURRENT_LIST_DIR}/DLLStub.cpp)

### The real dnssd static lib.

add_library(dnssdStatic STATIC ${DLL_STUB_HEADERS} ${DLL_STUB_SOURCES})

# We want to make the IDE source groups, project name, and project properties similar to the original MSVC project.
set_target_properties(dnssdStatic PROPERTIES
  PROJECT_LABEL DLLStub
  OUTPUT_NAME dnssd
)

# These lines are in order, as the last match takes precedence
source_group("Header Files" FILES ${DLL_STUB_HEADERS})
source_group("Source Files" FILES ${DLL_STUB_SOURCES})

set(DLL_STUB_COMPILE_DEFS
  UNICODE
  _UNICODE
  _LIB
  WIN32_LEAN_AND_MEAN
  _CRT_SECURE_NO_DEPRECATE
  _CRT_SECURE_CPP_OVERLOAD_STANDARD_NAMES=1
)
target_compile_definitions(dnssdStatic PRIVATE ${DLL_STUB_COMPILE_DEFS})

set(DLL_STUB_INCLUDE_DIRECTORIES
  PUBLIC
  ${CMAKE_CURRENT_LIST_DIR}/../../mDNSShared
  PRIVATE
  ${CMAKE_CURRENT_LIST_DIR}/../../mDNSWindows
  ${CMAKE_CURRENT_LIST_DIR}/..
)
target_include_directories(dnssdStatic ${DLL_STUB_INCLUDE_DIRECTORIES})

install(TARGETS dnssdStatic
  ARCHIVE DESTINATION lib
)

### A dnssd static lib with the daemon-connecting symbols missing, for mocking.

add_library(dnssdStaticMock STATIC ${DLL_STUB_HEADERS} ${DLL_STUB_SOURCES})
set_target_properties(dnssdStaticMock PROPERTIES
  PROJECT_LABEL DLLStubMock
  OUTPUT_NAME dnssd_mock
)
target_compile_definitions(dnssdStaticMock PRIVATE
  ${DLL_STUB_COMPILE_DEFS}
  DNSSD_BUILD_MOCK_LIB
)
target_include_directories(dnssdStaticMock ${DLL_STUB_INCLUDE_DIRECTORIES})

install(TARGETS dnssdStaticMock
  ARCHIVE DESTINATION lib
)