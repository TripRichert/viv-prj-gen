cmake_minimum_required(VERSION 3.3)
project(helloworld)

#force out of tree build
set(CMAKE_DISABLE_SOURCE_CHANGES ON)
set(CMAKE_DISABLE_IN_SOURCE_BUILD ON)

#defines variable mymessage
set(mymessage "Hello World!")

#prints message to console
message(STATUS ${mymessage})
