if(NOT NEW_VERSION_NUMBER)
  message(FATAL_ERROR "You must pass a version number!")
endif()

# Build the variables we will need to configure the versioned files
set(MDNSWINDOWS_VERSION ${NEW_VERSION_NUMBER})
string(REPLACE "." "," MDNSWINDOWS_VERSION_COMMA_SEP ${MDNSWINDOWS_VERSION})

# Configure the various versioned files
get_filename_component(VERSION_DIR ${CMAKE_SCRIPT_MODE_FILE} DIRECTORY)
configure_file(${VERSION_DIR}/templates/vars.wxi.in ${VERSION_DIR}/../install/vars.wxi)
configure_file(${VERSION_DIR}/templates/WinVersRes.h.in ${VERSION_DIR}/../../mDNSWindows/WinVersRes.h)
configure_file(${VERSION_DIR}/templates/current_version.txt.in ${VERSION_DIR}/current_version.txt)

# Stage the changed files
execute_process(COMMAND
  git add current_version.txt
  WORKING_DIRECTORY ${VERSION_DIR}
)
execute_process(COMMAND
  git add install/vars.wxi
  WORKING_DIRECTORY ${VERSION_DIR}/..
)
execute_process(COMMAND
  git add mDNSWindows/WinVersRes.h
  WORKING_DIRECTORY ${VERSION_DIR}/../..
)
configure_file(${VERSION_DIR}/templates/commit_msg.txt.in ${VERSION_DIR}/tmp_commit_msg.txt)

message(STATUS "Versioned files updated. Now commit and push your changes to do the build, e.g.:")
message(STATUS "    git commit -F tmp_commit_msg.txt")
message(STATUS "    git push origin")
