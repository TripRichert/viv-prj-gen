## watch forces cmake to rerun when the passed file(s) is/are modified
# \param filename(s) to monitor for modification
function(watch)
  set_property( DIRECTORY APPEND PROPERTY CMAKE_CONFIGURE_DEPENDS ${ARGV} )
endfunction()

function(get_filename_realpath filename_ref stub directory)
  if(NOT IS_ABSOLUTE ${stub})
    get_filename_component(fullname ${directory}/${stub} REALPATH)
  else()
    get_filename_component(fullname ${stub} REALPATH)
  endif()
  set(${filename_ref} ${fullname} PARENT_SCOPE)
endfunction()

## read_filelist converts newline separated entries of filenames in
# the passed fullPathToFile to a list and stores in filelist
# \param filelist the filename to store the list in
# \param fullPathToFile the filename of the file to be read
# any time the passed file is modified, cmake will rerun
function(read_filelist filelist fullPathToFile)
  if(NOT EXISTS ${fullPathToFile})
    message(FATAL_ERROR "File ${fullPathToFile} does not exist")
  endif()
  file(READ ${fullPathToFile} rootNames)
  STRING(REGEX REPLACE "\n" ";" rootNames "${rootNames}")
  set(${${filelist}} "")
  get_filename_component(pathname ${fullPathToFile} DIRECTORY)
  foreach(filename ${rootNames})
    get_filename_realpath(fullname ${filename} ${pathname})
    list(APPEND ${filelist} ${fullname})
  endforeach()
  watch(${fullPathToFile})
  set(${filelist} ${${filelist}} PARENT_SCOPE)
endfunction()

## substitute_variables substitutes the contents of cmake variables of string
# when variable name is contained in string by ${}
# \param result_varname the variable name to store the resulting string in
# \param input_string the string to do substitution on
function(substitute_variables result_varname input_string)
  STRING(REGEX MATCH "\\$\{[^\}]*\{" matchstring ${input_string})
  if(NOT matchstring STREQUAL "")
    message(STATUS "matchstring ${matchstring}")
    message(FATAL_ERROR "nested variables not supported")
  endif()
  set(loopcontinue true)
  while(loopcontinue)
    STRING(REGEX MATCH "\\$\{[^\}]*\{" matchstring ${input_string})
    if(NOT matchstring STREQUAL "")
      message(STATUS "matchstring ${matchstring}")
      message(FATAL_ERROR "nested variables not supported")
    endif()
    STRING(REGEX MATCH "\\$\{[^\}]*\}" matchstring ${input_string})
    if(NOT matchstring STREQUAL "")
      STRING(REGEX REPLACE "\\$" "" matchstring ${matchstring})
      STRING(REGEX REPLACE "\{" "" matchstring ${matchstring})
      STRING(REGEX REPLACE "\}" "" matchstring ${matchstring})
      if (DEFINED ${matchstring})
	STRING(REGEX REPLACE "\\$\{${matchstring}\}" ${${matchstring}} input_string ${input_string})
      else()
        message(FATAL_ERROR "variable ${matchstring} not found")
      endif()
    else()
      set(loopcontinue false)
    endif()
  endwhile()

  set(${result_varname} ${input_string} PARENT_SCOPE)

endfunction()

## read_filelist_use_substitution converts newline separated entries of
# filenames in the passed fullPathToFile to a list and stores in filelist
# cmake variable names can be part of path
# nesting of variable names is not allowed (don't make me recurse)
# \param filelist the filename to store the list in
# \param fullPathToFile the filename of the file to be read
# any time the passed file is modified, cmake will rerun
function(read_filelist_use_substitution filelist fullPathToFile)
  if(NOT EXISTS ${fullPathToFile})
    message(FATAL_ERROR "File ${fullPathToFile} does not exist")
  endif()
  file(READ ${fullPathToFile} rootNames)
  STRING(REGEX REPLACE "\n" ";" rootNames "${rootNames}")
  foreach(filename ${rootNames})
    substitute_variables(filename ${filename})
    list(APPEND filenames ${filename})
  endforeach()
  set(${${filelist}} "")
  
  get_filename_component(pathname ${fullPathToFile} DIRECTORY)
  foreach(filename ${filenames})
    get_filename_realpath(fullname ${filename} ${pathname}
    list(APPEND ${filelist} ${fullname})
  endforeach()
  watch(${fullPathToFile})
  set(${filelist} ${${filelist}} PARENT_SCOPE)
endfunction()

function(add_dependency_tree_file filelist fullPathToFile)
  if(NOT EXISTS ${fullPathToFile})
    message(FATAL_ERROR "File ${fullPathToFile} does not exist")
  endif()
  get_filename_component(directory ${fullPathToFile} DIRECTORY)
  
  file(READ ${fullPathToFile} rootNames)
  STRING(REGEX REPLACE "\n\r?" ";" rootNames "${rootNames}")
  foreach(line ${rootNames})
    string(FIND ${line} "<=" delimIndex)
    if(${delimIndex} EQUAL -1)
      message(FATAL_ERROR "line ${line} of ${fullPathToFile} does not contain <= delimitor")
    endif()
    string(SUBSTRING ${line} 0 ${delimIndex} filename)
    string(STRIP ${filename} filename)
    substitute_variables(filename ${filename})
    string(LENGTH ${line} length)
    MATH(EXPR depsIndex "${delimIndex}+2")
    string(SUBSTRING ${line} ${depsIndex} ${length} filedeps)
    string(STRIP ${filedeps} filedeps)
    STRING(REGEX REPLACE "([^\\]) +" "\\1;" filedeps "${filedeps}")
    STRING(REGEX REPLACE "\\\\ " " " filedeps "${filedeps}")
    get_filename_realpath(filepath ${filename} ${directory})
    set(filepath_deps "")
    foreach(depfile ${filedeps})
      substitute_variables(depfile ${depfile})
      get_filename_realpath(filedeppath ${depfile} ${directory})
      list(APPEND filepath_deps ${filedeppath})
    endforeach()
    STRING(MD5 filename_hash ${filepath})
    set(deps_file_${filename_hash} ${filepath_deps} PARENT_SCOPE)
    list(APPEND ${filelist} ${filepath})
  endforeach()
  watch(${fullPathToFile})
  
  set(${filelist} ${${filelist}} PARENT_SCOPE)
endfunction()

function(get_list_from_dependency_tree filelist_varname filename)
  if (${filelist_varname} STREQUAL "filelist_varname")
    message(FATAL_ERROR "name conflict at function scope, cannot use filelist_varname")
  endif()
  if (${filelist_varname} STREQUAL "filename")
    message(FATAL_ERROR "name conflict at function scope, cannot use filename")
  endif()
  if (NOT ${filename} STREQUAL "")
    set(basecond false)
    if (${filelist_varname} STREQUAL "")
      set(basecond false)
    elseif(${filename} IN_LIST ${filelist_varname})
      set(basecond true)
    endif()
    if(NOT ${basecond})
      list(APPEND ${filelist_varname} ${filename})
      string(MD5 filename_hash ${filename})
      if (DEFINED deps_file_${filename_hash})
	foreach(depfilename ${deps_file_${filename_hash}})
          get_list_from_dependency_tree(${filelist_varname} ${depfilename})
	endforeach()
      endif()
      set(${filelist_varname} ${${filelist_varname}} PARENT_SCOPE)
    endif()
  endif()
endfunction()

###############################################################################
# MIT LICENSE
###############################################################################
# Copyright 2020 Trip Richert

# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
