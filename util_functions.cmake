## watch forces cmake to rerun when the passed file(s) is/are modified
# \param filename(s) to monitor for modification
function(watch)
  set_property( DIRECTORY APPEND PROPERTY CMAKE_CONFIGURE_DEPENDS ${ARGV} )
endfunction()

## readFilelist converts newline separated entries of filenames in
# the passed fullPathToFile to a list and stores in filelist
# \param filelist the filename to store the list in
# \param fullPathToFile the filename of the file to be read
# any time the passed file is modified, cmake will rerun
function(readFilelist filelist fullPathToFile)
  if(NOT EXISTS ${fullPathToFile})
    message(FATAL_ERROR "File ${fullPathToFile} does not exist")
  endif()
  file(READ ${fullPathToFile} rootNames)
  STRING(REGEX REPLACE "\n" ";" rootNames "${rootNames}")
  set(${${filelist}} "")
  get_filename_component(pathname ${fullPathToFile} DIRECTORY)
  foreach(filename ${rootNames})
    if(NOT IS_ABSOLUTE ${filename})
      set(fullname "${pathname}/${filename}")
    else()
      set(fullname ${filename})
    endif()
    list(APPEND ${filelist} ${fullname})
  endforeach()
  watch(${fullPathToFile})
  set(${filelist} ${${filelist}} PARENT_SCOPE)
endfunction()

###############################################################################
# MIT LICENSE
###############################################################################
# Copyright 2020 Trip Richert

# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
