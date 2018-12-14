# CMakeList.txt : CMake project created by ETC to build the Windows mDNS DLL Stub library.
# This lib is used for loading the dll.
#

set(HEADERS ${CMAKE_CURRENT_LIST_DIR}/DLLStub.h)

set(SOURCES ${CMAKE_CURRENT_LIST_DIR}/DLLStub.cpp)

add_library (dnssdStatic STATIC ${HEADERS} ${SOURCES})

# We want to make the IDE source groups, project name, and project properties similar to the original MSVC project.
set_target_properties(dnssdStatic PROPERTIES
  PROJECT_LABEL DLLStub
  OUTPUT_NAME dnssd
)

# These lines are in order, as the last match takes precedence
source_group("Header Files" FILES ${HEADERS})
source_group("Source Files" FILES ${SOURCES})

target_compile_definitions(dnssdStatic PRIVATE
  UNICODE
  _UNICODE
  _LIB
  WIN32_LEAN_AND_MEAN
  _CRT_SECURE_NO_DEPRECATE
  _CRT_SECURE_CPP_OVERLOAD_STANDARD_NAMES=1
)
target_include_directories(dnssdStatic
  PUBLIC
  ${CMAKE_CURRENT_LIST_DIR}/../../mDNSShared
  PRIVATE
  ${CMAKE_CURRENT_LIST_DIR}/../../mDNSWindows
  ${CMAKE_CURRENT_LIST_DIR}/..
)

install(TARGETS dnssdStatic
  ARCHIVE DESTINATION lib
)
