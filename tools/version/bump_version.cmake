if(NOT NEW_VERSION_NUMBER)
  message(FATAL_ERROR "You must pass a version number!")
endif()

set(MDNSWINDOWS_VERSION ${NEW_VERSION_NUMBER})
string(REPLACE "." "," MDNSWINDOWS_VERSION_COMMA_SEP ${MDNSWINDOWS_VERSION})

get_filename_component(VERSION_DIR ${CMAKE_SCRIPT_MODE_FILE} DIRECTORY)
configure_file(${VERSION_DIR}/vars.wxi.in ${VERSION_DIR}/../install/vars.wxi)
configure_file(${VERSION_DIR}/WinVersRes.h.in ${VERSION_DIR}/../../mDNSWindows/WinVersRes.h)