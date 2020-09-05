cmake_minimum_required(VERSION 3.3)
project(project)

include(../../functions.cmake)

file(GLOB vfiles verilog/src/*.v)

file(GLOB simfiles verilog/sim/*.v)

file(GLOB sqrtfiles verilog/src/pipeline_registers.v verilog/src/sqrt_generic.v)

set(partname "XC7Z020-1CLG484")


genvivprj_func(
  PRJNAME verilog
  VERILOGSYNTHFILES ${vfiles}
  VERILOGSIMFILES ${simfiles}
  PARTNAME ${partname}
  )

genip_func(
  IPNAME sqrt
  PARTNAME ${partname}
  LIBNAME test
  VERILOGFILES ${sqrtfiles}
  TOPNAME sqrt_generic)

add_custom_target(ip ALL
	DEPENDS ${CMAKE_BINARY_DIR}/${partname}/ip_repo/test/sqrt/component.xml
	)

###############################################################################
# MIT LICENSE
###############################################################################

#Copyright 2020 Trip Richert

#Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

#The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

#THE SOFTWARE IS PROVIDED AS IS, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. 
