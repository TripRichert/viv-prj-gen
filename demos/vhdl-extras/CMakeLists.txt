cmake_minimum_required(VERSION 3.3)
project(project)

include(../../vivgen_functions.cmake)

file(GLOB hdlfiles vhdl-extras/rtl/extras/*.vhdl)

file(GLOB simfiles vhdl-extras/rtl/test/*.vhdl)

file(GLOB hdl08files vhdl-extras/rtl/extras_2008/*.vhdl)

file(GLOB sim08files vhdl-extras/rtl/test_2008/*.vhdl)

set(partname "XC7Z020-1CLG484")


add_vivado_devel_project(
  PRJNAME extras
  VHDLSYNTHFILES ${hdlfiles}
  VHDLSIMFILES ${simfiles} ${hdlfiles}
  PARTNAME ${partname}
  NOVHDL2008
  )

add_vivado_devel_project(
  PRJNAME extras_2008
  VHDLSYNTHFILES ${hdlfiles} ${hdl08files}
  VHDLSIMFILES ${hdlfiles} ${hdl08files} ${simfiles} ${sim08files}
  PARTNAME ${partname}
  NOVHDL2008
  )

###############################################################################
# MIT LICENSE
###############################################################################

#Copyright 2020 Trip Richert

#Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

#The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

#THE SOFTWARE IS PROVIDED AS IS, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. 
