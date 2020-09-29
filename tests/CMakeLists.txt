#vivado's version of cmake is 3.3
cmake_minimum_required(VERSION 3.3)
#do not allow in source build
set(CMAKE_DISABLE_SOURCE_CHANGES ON)
set(CMAKE_DISABLE_IN_SOURCE_BUILD ON)

project(project)

include(../util_functions.cmake)
