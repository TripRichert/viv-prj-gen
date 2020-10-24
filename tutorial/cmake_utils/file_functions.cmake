include(${CMAKE_CURRENT_LIST_DIR}/helper_functions.cmake)

## watch forces cmake to rerun when the passed file(s) is/are modified
# \param filename(s) to monitor for modification
function(watch)
  set_property( DIRECTORY APPEND PROPERTY CMAKE_CONFIGURE_DEPENDS ${ARGV} )
endfunction()  

## read_filelist_no_substitution converts newline separated entries of filenames in
# the passed fullPathToFile to a list and stores in filelist
# \param filelist the filename to store the list in
# \param fullPathToFile the filename of the file to be read
# any time the passed file is modified, cmake will rerun
function(read_filelist_no_substitution filelist fullPathToFile)
  if(NOT EXISTS ${fullPathToFile})
    message(FATAL_ERROR "File ${fullPathToFile} does not exist")
  endif()
  file(READ ${fullPathToFile} rootNames)
  parse_filelist(${filelist} ${rootNames})
  watch(${fullPathToFile})
  set(${filelist} ${${filelist}} PARENT_SCOPE)
endfunction()


## read_filelist converts newline separated entries of
# filenames in the passed fullPathToFile to a list and stores in filelist
# cmake variable names can be part of path
# nesting of variable names is not allowed (don't make me recurse)
# \param filelist the filename to store the list in
# \param fullPathToFile the filename of the file to be read
# any time the passed file is modified, cmake will rerun
function(read_filelist filelist fullPathToFile)
  if(NOT EXISTS ${fullPathToFile})
    message(FATAL_ERROR "File ${fullPathToFile} does not exist")
  endif()
  file(READ ${fullPathToFile} rootNames)
  parse_filelist_with_substitution(${filelist} ${rootNames})
  watch(${fullPathToFile})
  set(${filelist} ${${filelist}} PARENT_SCOPE)
endfunction()

## add_dependency_tree_file stores set of lists from file
# \param headfile_list name of variable to store list of fullpath filenames used as heads of lists
# \param fullPathToFile full path of filename containing lists
# \description stores set of lists of file dependencies from file with new line separated entries of the format
# head_filename <= filename1 filename2
# where each filename is a relative path to the fullPathToFile or an absolute path.
# By dependency, I mean in the sense of using in compilation, not recipe to generate file
# the list for each head_filename is stored at the deps_file_${hash_head_filename} where
# hash_head_filename is the MD5 hash of the full path to the head_filename
# cmake variables can be referenced in the dependency file by bracketing with @ symbols, like in .in files
# the full paths to to the filenames are stored in ${${headfile_list}}
function(add_dependency_tree_file headfile_list fullPathToFile)
  if(NOT EXISTS ${fullPathToFile})
    message(FATAL_ERROR "File ${fullPathToFile} does not exist")
  endif()
  get_filename_component(directory ${fullPathToFile} DIRECTORY)
  
  file(READ ${fullPathToFile} rootNames)
  STRING(REGEX REPLACE "\n\r?" ";" rootNames "${rootNames}")
  
  set(missing_delimiter false)
  foreach(line ${rootNames})
    string(FIND ${line} "<=" delimIndex)
    if(${delimIndex} EQUAL -1)
      message(SEND_ERROR "line ${line} of ${fullPathToFile} does not contain <= delimitor")
      set(missing_delimiter true)
    endif()
  endforeach()
  if (missing_delimiter)
    message(FATAL_ERROR "missing delimiters listed in prior errors")
  endif()
  
  foreach(line ${rootNames})
    string(FIND ${line} "<=" delimIndex)
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
    list(APPEND ${headfile_list} ${filepath})
  endforeach()
  watch(${fullPathToFile})
  
  set(${headfile_list} ${${headfile_list}} PARENT_SCOPE)
endfunction()

## get_list_from_dependency_tree recursively expands lists created by add_dependency_tree_file to get all "dependencies" of filename
# \param filelist_varname variablename to append list generated from expanding dependency lists
# \param filename fullpath name of file head to get list of
# \description recursively generates a list of all dependencies of filename, as described in files added with add_dependency_tree_file
# list will include filename
function(get_list_from_dependency_tree filelist_varname filename)
  if (${filelist_varname} STREQUAL "filelist_varname")
    message(FATAL_ERROR "name conflict at function scope, cannot use filelist_varname")
  endif()
  if (${filelist_varname} STREQUAL "filename")
    message(FATAL_ERROR "name conflict at function scope, cannot use filename for filelist_varname")
  endif()
  if (NOT DEFINED ${filelist_varname})
    set(${filelist_varname} "")
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
