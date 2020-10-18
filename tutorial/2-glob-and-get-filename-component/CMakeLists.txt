cmake_minimum_required(VERSION 3.3)
project(globfilelists)

#force out of tree build
set(CMAKE_DISABLE_SOURCE_CHANGES ON)
set(CMAKE_DISABLE_IN_SOURCE_BUILD ON)

#get full paths to verilog files in hdl directory and system verilog files in tb
file(GLOB hdlfiles hdl/*.vhdl)
file(GLOB tbfiles tb/*.vhdl)

#print out those full paths
message(STATUS "hdlfiles ${hdlfiles}")
message(STATUS "hdlfiles ${tbfiles}")

set(filenames
  hdl/DFlipFlop.vhdl
  hdl/GenericDFlipFlop.vhdl
  )
foreach(filename ${filenames})
  get_filename_component(hdlfile ${filename} REALPATH)
  message(STATUS "file ${hdlfile}")
endforeach()
