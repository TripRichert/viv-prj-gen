cmake_minimum_required(VERSION 3.3)
project(project)

include(../../vivgen_functions.cmake)
include(../../cmake_utils/util_functions.cmake)

get_filename_component(hdldepfile hdl/deptree.txt REALPATH)
get_filename_component(tbdepfile tb/deptree.txt REALPATH)
get_filename_component(xdclistfile constraints/filelist.txt REALPATH)

add_dependency_tree_file(placeholder1 ${hdldepfile})
add_dependency_tree_file(placeholder2 ${tbdepfile})

read_filelist(xdcfiles ${xdclistfile})

get_filename_component(topsynth hdl/blinky_zedboard_z7.v REALPATH)
get_filename_component(topsim tb/blinky_tb.v REALPATH)
get_list_from_dependency_tree(synthfiles ${topsynth})
get_list_from_dependency_tree(simfiles ${topsim})

set(partname "XC7Z020-1CLG484")

add_vivado_devel_project(
  PRJNAME blinky
  VERILOGSYNTHFILES ${synthfiles}
  VERILOGSIMFILES ${simfiles}
  PARTNAME ${partname}
  UNSCOPEDLATEXDC ${xdcfiles}
  )

add_vivado_nonprj_bitfile(
  PRJNAME blinky
  TOPNAME blinky_zedboard_z7
  PARTNAME ${partname}
  VERILOGFILES ${synthfiles}
  UNSCOPEDLATEXDC ${xdcfiles}
  BITFILE_OUTPUT blinky_bitfile
  )

add_custom_target(blinky_nonprj
  DEPENDS ${blinky_bitfile}
  )

get_filename_component(edabuildscript build.py REALPATH)

add_custom_command(OUTPUT ${CMAKE_BINARY_DIR}/${partname}/edalize/synth/blinky/blinky.bit
  COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_BINARY_DIR}/${partname}/edalize/synth
  COMMAND ${CMAKE_COMMAND} -E remove_directory ${CMAKE_BINARY_DIR}/${partname}/edalize/synth/blinky
  COMMAND python3 ${edabuildscript} -name blinky -topname blinky_zedboard_z7 -verilogsynthfiles ${synthfiles} -xdcfiles ${xdcfiles} -partname ${partname} -outdir ${CMAKE_BINARY_DIR}/${partname}/edalize/synth/blinky
  DEPENDS ${edabuildscript} ${hdlfiles} ${xdcfiles}
  )

add_custom_target(eda_blinky_bitfile
  DEPENDS ${CMAKE_BINARY_DIR}/${partname}/edalize/synth/blinky/blinky.bit
  )

get_filename_component(edasimscript sim.py REALPATH)


set(innerstring "int 1000")

set(miscparamstring "-clk_freq_hz ${innerstring}")
set(miscparamstring "arg ${miscparamstring}")
string(REPLACE ";" " " miscparamstring "${miscparamstring}")


add_custom_target(eda_blinky_sim
  COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_BINARY_DIR}/${partname}/edalize/sim
  COMMAND ${CMAKE_COMMAND} -E remove_directory ${CMAKE_BINARY_DIR}/${partname}/edalize/sim/blinky
  COMMAND python3 ${edasimscript} -name blinky -topname blinky_tb -verilogfiles ${simfiles} -outdir ${CMAKE_BINARY_DIR}/${partname}/edalize/sim/blinky -parameters ${miscparamstring}
  DEPENDS ${edabuildscript} ${simfiles} ${xdcfiles}
  )
  

###############################################################################
# MIT LICENSE
###############################################################################

#Copyright 2020 Trip Richert

#Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

#The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

#THE SOFTWARE IS PROVIDED AS IS, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. 
