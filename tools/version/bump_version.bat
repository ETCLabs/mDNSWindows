echo off
cmake -DNEW_VERSION_NUMBER=%1 -P bump_version.cmake