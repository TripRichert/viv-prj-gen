function(get_filename_realpath filename_ref stub directory)
  if(NOT IS_ABSOLUTE ${stub})
    get_filename_component(fullname ${directory}/${stub} REALPATH)
  else()
    get_filename_component(fullname ${stub} REALPATH)
  endif()
  set(${filename_ref} ${fullname} PARENT_SCOPE)
endfunction()

## substitute_variables_cmake substitutes the contents of cmake variables of string
# when variable name is contained in string by ${}
# \param result_varname the variable name to store the resulting string in
# \param input_string the string to do substitution on
function(substitute_variables result_varname input_string)
  set(loopcontinue true)
  while(loopcontinue)
    STRING(REGEX MATCH "@[^@]*@" matchstring ${input_string})
    if(NOT matchstring STREQUAL "")
      STRING(REGEX REPLACE "@" "" matchstring ${matchstring})
      STRING(REGEX REPLACE "@" "" matchstring ${matchstring})
      if (DEFINED ${matchstring})
	STRING(REGEX REPLACE "@${matchstring}@" ${${matchstring}} input_string ${input_string})
      else()
        message(FATAL_ERROR "variable ${matchstring} not found")
      endif()
    else()
      set(loopcontinue false)
    endif()
  endwhile()
  set(${result_varname} ${input_string} PARENT_SCOPE)
endfunction()

## substitute_variables_cmake substitutes the contents of cmake variables of string
# when variable name is contained in string by ${}
# \param result_varname the variable name to store the resulting string in
# \param input_string the string to do substitution on
function(substitute_variables_cmake result_varname input_string)
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

function(parse_filelist filelist rootNames)
  STRING(REGEX REPLACE "\n" ";" rootNames "${rootNames}")
  set(${${filelist}} "")
  get_filename_component(pathname ${fullPathToFile} DIRECTORY)
  foreach(filename ${rootNames})
    get_filename_realpath(fullname ${filename} ${pathname})
    list(APPEND ${filelist} ${fullname})
  endforeach()
  set(${filelist} ${${filelist}} PARENT_SCOPE)
endfunction()

function(parse_filelist_with_substitution filelist rootNames)
  STRING(REGEX REPLACE "\n" ";" rootNames "${rootNames}")
  foreach(filename ${rootNames})
    substitute_variables(filename ${filename})
    list(APPEND filenames ${filename})
  endforeach()
  set(${${filelist}} "")
  
  get_filename_component(pathname ${fullPathToFile} DIRECTORY)
  foreach(filename ${filenames})
    get_filename_realpath(fullname ${filename} ${pathname})
    list(APPEND ${filelist} ${fullname})
  endforeach()
  set(${filelist} ${${filelist}} PARENT_SCOPE)
endfunction()


###############################################################################
# MIT LICENSE
###############################################################################
# Copyright 2020 Trip Richert

# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
