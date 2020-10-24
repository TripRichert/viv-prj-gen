#vivado's version of cmake is 3.3
cmake_minimum_required(VERSION 3.3)
project(project)
#do not allow in source build
set(CMAKE_DISABLE_SOURCE_CHANGES ON)
set(CMAKE_DISABLE_IN_SOURCE_BUILD ON)
include(CTest)
enable_testing()


include(../file_functions.cmake)
get_filename_component(compare_tcl compare.tcl REALPATH)

include(test1/test1.cmake)
include(test2/test2.cmake)
include(test3/test3.cmake)
include(test4/test4.cmake)
include(test5/test5.cmake)
