cmake_minimum_required(VERSION 3.3)
project(project)

#cmake_utils file_functions.cmake provides the functions
#add_dependency_tree_file and get_list_from_dependency_tree
include(../cmake_utils/file_functions.cmake)

#we need the full paths to the dependency tree files
get_filename_component(hdldepfile hdl/deptree.txt REALPATH)
get_filename_component(tbdepfile tb/deptree.txt REALPATH)

#placeholder1 and placeholder2 store the filepaths that are the heads of lists
add_dependency_tree_file(placeholder1 ${hdldepfile})
add_dependency_tree_file(placeholder2 ${tbdepfile})

#the value of topsynth is also in placeholder1
get_filename_component(topsynth hdl/blinky_zedboard_z7.v REALPATH)
#the value of topsim is also in placeholder2
get_filename_component(topsim tb/blinky_tb.v REALPATH)
get_list_from_dependency_tree(synthfiles ${topsynth})
get_list_from_dependency_tree(simfiles ${topsim})

message(STATUS "synth files ${synthfiles}")
message(STATUS "sim files ${simfiles}")
  

###############################################################################
# MIT LICENSE
###############################################################################

#Copyright 2020 Trip Richert

#Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

#The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

#THE SOFTWARE IS PROVIDED AS IS, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. 
