cmake_minimum_required(VERSION 3.3)
project(filelists)

#force out of tree build
set(CMAKE_DISABLE_SOURCE_CHANGES ON)
set(CMAKE_DISABLE_IN_SOURCE_BUILD ON)

include(../cmake_utils/file_functions.cmake)

get_filename_component(hdllistfile hdl/filelist.txt REALPATH)

read_filelist(hdlfiles ${hdllistfile})

message(STATUS "hdlfiles ${hdlfiles}")
