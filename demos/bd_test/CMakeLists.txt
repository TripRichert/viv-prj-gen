#vivado's version of cmake is 3.3
cmake_minimum_required(VERSION 3.3)
#do not allow in source build
set(CMAKE_DISABLE_SOURCE_CHANGES ON)
set(CMAKE_DISABLE_IN_SOURCE_BUILD ON)

project(project)
set(partname "XC7Z020-1CLG484")
set(boardname "em.avnet.com:zed:part0:1.4")

include(../../vivgen_functions.cmake)
include(../../cmake_utils/util_functions.cmake)
file(GLOB hdlfilelistname ipxact_files/myip/filelist.txt)
read_filelist(hdlfiles ${hdlfilelistname})

add_vivado_xact_ip(
  IPNAME myip
  PARTNAME ${partname}
  LIBNAME test
  VHDLFILES ${hdlfiles}
  TOPNAME myip_v1_0
  IP_STAMPOUTPUT ipxact_target
  )
      
add_custom_target(test_ip ALL
  DEPENDS ${ipxact_target}
  )

file(GLOB bdscript scripts/*_bd.tcl)
add_vivado_bd_hdf(
  PRJNAME test
  PARTNAME ${partname}
  BDSCRIPT ${bdscript}
  BOARDNAME ${boardname}
  HDFFILE_OUTPUT hdf_target
  DEPENDS ${ipxact_target}
  )

add_custom_target(the_hdf
  DEPENDS ${hdf_target}
  )

###############################################################################
# MIT LICENSE
###############################################################################
#Copyright 2020 Trip Richert

#Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

#The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

#THE SOFTWARE IS PROVIDED AS IS, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
