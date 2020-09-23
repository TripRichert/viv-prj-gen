#vivado's version of cmake is 3.3
cmake_minimum_required(VERSION 3.3)
#do not allow in source build
set(CMAKE_DISABLE_SOURCE_CHANGES ON)
set(CMAKE_DISABLE_IN_SOURCE_BUILD ON)

project(project)
set(partname "XC7Z020-1CLG484")

include(../../vivgen_functions.cmake)
include(../../util_functions.cmake)

file(GLOB hdlfilelistname hdl/filelist.txt)
readFilelist_withSubstitution(hdlfiles ${hdlfilelistname})
file(GLOB unscopedLateConstrFileListName constraints/unscopedlate/filelist.txt)
readFileList(unscopedLateConstrFiles ${unscopedLateConstrFileListName})

genvivprj_func(
  PRJNAME testprj
  PARTNAME ${partname}
  VHDLSYNTHFILES ${hdlfiles}
  UNSCOPEDLATEXDC ${unscopedLateConstrFiles}
  )

set(nonprjname "nonprjdemo")

vivnonprjbitgen_func(
  PRJNAME ${nonprjname}
  TOPNAME demo_top
  PARTNAME ${partname}
  VHDLFILES ${hdlfiles}
  UNSCOPEDLATEXDC ${unscopedLateConstrFiles}
  BITFILE_OUTPUT ${nonprjname}_bitfile
  )

add_custom_target(nonprj
  DEPENDS ${${nonprjname}_bitfile}
  )

genip_func(
  IPNAME genff
  PARTNAME ${partname}
  LIBNAME test
  VHDLFILES ${hdlfiles}
  TOPNAME GenericDFlipFlop
  IP_STAMPOUTPUT ipxact_target
  )
      
add_custom_target(test_ip ALL
  DEPENDS ${ipxact_target}
  )

###############################################################################
# MIT LICENSE
###############################################################################
#Copyright 2020 Trip Richert

#Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

#The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

#THE SOFTWARE IS PROVIDED AS IS, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
