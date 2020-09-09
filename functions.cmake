#see copyright notice(s) at bottom of file

include(CMakeParseArguments)

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

# tcl script for generating vivado projects
file(GLOB genvivprjscript "${CMAKE_CURRENT_LIST_DIR}/tcl/gen_prj.tcl")

#file used to parse commandline arguments
file(GLOB cmdlinedictprocsscript "${CMAKE_CURRENT_LIST_DIR}/tcl/helper_procs/cmdline_dict.tcl")


## \function genvivprj_func generates a target for generating a vivado project
# \Description intended for simulation.  Will fail if vivado project already
# exists.  
# \param PRJNAME name of vivado project to be created
# \param PARTNAME xilinx part
# \param [VHDLSYNTHFILES] vhdl synthesizable files, must exist at config time
# \param [VHDLSYNTHFILES_GEN] vhdl synthesizable files
# \param [VERILOGSYNTHFILES] verilog files must exist at config time
# \param [VERILOGSYNTHFILES_GEN] verilog files, not checked for existance
# \param [SVSYNTHFILES] system verilog files, must exist at config time
# \param [SVSYNTHFILES_GEN] system verilogfiles, not checked for existance
# \param [VHDLSIMFILES] vhdl sim only files, must exist at config time
# \param [VHDLSIMFILES_GEN] vhdl sim only files, not checked for existance
# \param [VERILOGSIMFILES] verilog sim only files must exist at config time
# \param [VERILOGSIMFILES_GEN] verilog sim onlyfiles, not checked for existance
# \param [SVSIMFILES] system verilog sim only files, must exist at config time
# \param [SVSIMFILES_GEN] system verilog sim onlyfiles, not checked for existance
# \param [UNSCOPEDEARLYXDC] unscoped constraint file, must exist config time
# \param [UNSCOPEDEARLYXDC_GEN] unscoped constraint file
# \param [UNSCOPEDNORMALXDC] unscoped constraint file, must exist config time
# \param [UNSCOPEDNORMALXDC_GEN] unscoped constraint file
# \param [UNSCOPEDLATEXDC] unscoped constraint file, must exist config time
# \param [UNSCOPEDLATEXDC_GEN] unscoped constraint file
# \param [SCOPEDEARLYXDC] scoped to ref of same name constr file, must exist config time
# \param [SCOPEDEARLYXDC_GEN] scoped to ref of same name constr file
# \param [SCOPEDNORMALXDC] scoped to ref of same name constr file, must exist config time
# \param [SCOPEDNORMALXDC_GEN] scoped to ref of same name constr file
# \param [SCOPEDLATEXDC] scoped to ref of same name constr file, must exist config time
# \param [SCOPEDLATEXDC_GEN] scoped to ref of same name constr file
# \param [DATAFILES] nonsource files incl in prj for sim, must exist config time
# \param [DATAFILES_GEN] nonsource files incl in prj for sim
# \param [NOVHDL2008] (option to use old vhdl, if this option is not passed, vhdl2008 will be used)

function(genvivprj_func)
        set(options NOVHDL2008)
        set(args
	  PRJNAME
	  PARTNAME
	  )
	set(file_types
	  VHDLSYNTHFILES
	  VHDLSIMFILES
	  VERILOGSYNTHFILES
	  VERILOGSIMFILES
	  SVSYNTHFILES
	  SVSIMFILES
	  UNSCOPEDEARLYXDC
	  UNSCOPEDNORMALXDC
	  UNSCOPEDLATEXDC
	  SCOPEDEARLYXDC
	  SCOPEDNORMALXDC
	  SCOPEDLATEXDC
	  DATAFILES
	  )
	set(gen_file_types "")
	foreach(file_type ${file_types})
	  list(APPEND gen_file_types ${file_type}_GEN)
	endforeach()
        set(list_args
	  ${file_types}
	  ${gen_file_types}
	  )
        CMAKE_PARSE_ARGUMENTS(
                genviv
                "${options}"
                "${args}"
                "${list_args}"
		"${ARGN}"
                )
        foreach(arg IN LISTS test_UNPARSED_ARGUMENTS)
          message(WARNING "Unparsed argument: ${arg}")
        endforeach()

	if(printFuncParams)
	  foreach(arg ${args})
	    message(STATUS "genvivprj ${arg} ${genviv_${arg}}")
	  endforeach()
	  foreach(arg ${list_args})
	    message(STATUS "genvivprj ${arg} ${genviv_${arg}}")
	  endforeach()
	  message(STATUS "genvivprj NOVHDL2008 ${genviv_NOVHDL2008}")
	endif()

	foreach(file_type ${file_types})
	  foreach(filename ${genviv_${file_type}})
	    if(NOT ${filename} STREQUAL "")
	      if(NOT EXISTS ${filename})
		message(SEND_ERROR "missing file ${filename}")
	      endif()
	    endif()
	  endforeach()
	endforeach()
	
	foreach(file_type ${file_types})
	  set(${file_type} ${genviv_${file_type}} ${genviv_${file_type}_GEN})
	endforeach()

        if (genviv_NOVHDL2008)
          set(vhdlfileopts -vhdlsynthfiles ${VHDLSYNTHFILES} -vhdlsimfiles ${VHDLSIMFILES})
        else()
          set(vhdlfileopts -vhdl08synthfiles ${VHDLSYNTHFILES} -vhdl08simfiles ${VHDLSIMFILES})
        endif()
        
        add_custom_target(${genviv_PRJNAME}_genvivprj
          COMMAND vivado -mode batch -source ${genvivprjscript} -tclargs -prjname ${genviv_PRJNAME} -partname ${genviv_PARTNAME} ${vhdlfileopts} -verilogsynthfiles ${VERILOGSYNTHFILES} -verilogsimfiles ${VERILOGSIMFILES} -systemverilogsynthfiles ${SVSYNTHFILES} -systemverilogsimfiles ${SVSIMFILES}  -unscopedearlyconstraints ${UNSCOPEDEARLYXDC} -unscopednormalconstraints ${UNSCOPEDNORMALXDC} -unscopedlateconstraints ${UNSCOPEDLATEXDC} -scopedearlyconstraints ${SCOPEDEARLYXDC} -scopednormalconstraints ${SCOPEDNORMALXDC} -scopedlateconstraints ${SCOPEDLATEXDC} -datafiles ${DATAFILES} -builddir ${CMAKE_BINARY_DIR}
	  DEPENDS ${VHDLSYNTHFILES} ${VHDLSIMFILES} ${VERILOGSYNTHFILES} ${VERILOGSIMFILES} ${SVSYNTHFILES} ${SVSIMFILES} ${UNSCOPEDEARLYXDC} ${UNSCOPEDNORMALXDC} ${UNSCOPEDLATEXDC} ${SCOPEDEARLYXDC} ${SCOPEDNORMALXDC} ${SCOPEDLATEXDC} ${DATAFILES} ${genvivprjscript} ${cmdlinedictprocsscript}
                )
endfunction()


#default nonproject file scripts
file(GLOB default_synthfile "${CMAKE_CURRENT_LIST_DIR}/tcl/default_scripts/nonprj_synth.tcl")
file(GLOB default_placefile "${CMAKE_CURRENT_LIST_DIR}/tcl/default_scripts/nonprj_place.tcl")
file(GLOB default_routefile "${CMAKE_CURRENT_LIST_DIR}/tcl/default_scripts/nonprj_route.tcl")
file(GLOB default_wrbitfile "${CMAKE_CURRENT_LIST_DIR}/tcl/default_scripts/nonpjr_writebit.tcl")
file(GLOB nonprjbuildscript "${CMAKE_CURRENT_LIST_DIR}/tcl/buildnonprj.tcl")


function(vivnonprjbitgen_func)
        set(options VHDL2008)
        set(args
	  PRJNAME
	  PARTNAME
	  TOPNAME
	  PRESYNTHSCRIPT
	  SYNTHSCRIPT
	  PLACESCRIPT
	  ROUTESCRIPT
	  WRBITSCRIPT
	  )
	set(src_file_types
	  VHDLFILES
	  VERILOGFILES
	  SYSTEMVERILOGFILES
	  UNSCOPEDEARLYXDC
	  UNSCOPEDNORMALXDC
	  UNSCOPEDLATEXDC
	  SCOPEDEARLYXDC
	  SCOPEDNORMALXDC
	  SCOPEDLATEXDC
	  )
	set(gen_file_types "")
	foreach(file_type ${src_file_types})
	  list(APPEND gen_file_types ${file_type}_GEN)
	endforeach()
	  
        set(list_args
	  ${src_file_types}
	  ${gen_file_types}
	  XCIFILES 
	  SCRIPTDEPS 
	  MISCPARAMS
	  )
        CMAKE_PARSE_ARGUMENTS(
                vivnonprj
                "${options}"
                "${args}"
                "${list_args}"
		"${ARGN}"
                )
        foreach(arg IN LISTS vivnonprj_UNPARSED_ARGUMENTS)
                    message(WARNING "Unparsed argument: ${arg}")
        endforeach()

	if(printFuncParams)
	  foreach(arg ${args})
	    message(STATUS "vivnonprjgenbit ${arg} ${vivnonprj_${arg}}")
	  endforeach()
	  foreach(arg ${list_args})
	    message(STATUS "vivnonprjgenbit ${arg} ${vivnonprj_${arg}}")
	  endforeach()
	  message(STATUS "vivnonprjgenbit VHDL2008 ${vivnonprj_VHDL2008}")
	endif()

	foreach(file_type ${src_file_types})
	  foreach(filename ${vivnonprj_${file_type}})
	    if(NOT ${filename} STREQUAL "")
	      if(NOT EXISTS ${filename})
		message(SEND_ERROR "missing file ${filename}")
	      endif()
	    endif()
	  endforeach()
	endforeach()

	foreach(file_type ${src_file_types})
	  set(${file_type} ${vivnonprj_${file_type}} 
						  ${vivnonprj_${file_type}_GEN})
	endforeach()


	        
        set(scriptlist)
        if (NOT ${vivnonprj_PRESYNTHSCRIPT} STREQUAL "")
          set(scriptlist ${scriptlist} ${vivnonprj_PRESYNTHSCRIPT})
        endif()
        if (NOT ${vivnonprj_SYNTHSCRIPT} STREQUAL "")
          set(scriptlist ${scriptlist} ${vivnonprj_SYNTHSCRIPT})
        else()
          set(scriptlist ${scriptlist} ${default_synthfile})
        endif()
        if (NOT ${vivnonprj_PLACESCRIPT} STREQUAL "")
          set(scriptlist ${scriptlist} ${vivnonprj_PLACESCRIPT})
        else()
          set(scriptlist ${scriptlist} ${default_placefile})
        endif()
        if (NOT ${vivnonprj_ROUTESCRIPT} STREQUAL "")
          set(scriptlist ${scriptlist} ${vivnonprj_ROUTESCRIPT})
        else()
          set(scriptlist ${scriptlist} ${default_routefile})
        endif()
        if (NOT ${vivnonprj_WRBITSCRIPT} STREQUAL "")
          set(scriptlist ${scriptlist} ${vivnonprj_WRBITSCRIPT})
        else()
          set(scriptlist ${scriptlist} ${default_wrbitfile})
        endif()
        
        if (vivnonprj_VHDL2008)
          set(vhdl2008option --vhdl2008)
        endif()

	if (vivnonprj_MISCPARAMS STREQUAL "")
	  set(miscparamkey "")
	  set(miscparamstring "")
	else()
	  #braces forces join, but allows nested dictionary with args as spacer
	  set(miscparamkey "-miscparams")
	  set(miscparamstring "arg ${vivnonprj_MISCPARAMS}")
	  string(REPLACE ";" " " miscparamstring "${miscparamstring}")
	endif()

        add_custom_command(OUTPUT vivnonprj_${vivnonprj_PRJNAME}/${vivnonprj_PRJNAME}.bit
                          COMMAND vivado -mode batch -source ${nonprjbuildscript} -tclargs -prjname ${vivnonprj_PRJNAME} -partname ${vivnonprj_PARTNAME} -topname ${vivnonprj_TOPNAME} -vhdlsynthfiles ${VHDLFILES} -verilogsynthfiles ${VERILOGFILES} -svsynthfiles ${SYSTEMVERILOGFILES} -xcifiles ${vivnonprj_XCIFILES} -unscopedearlyconstraints ${UNSCOPEDEARLYXDC} -unscopednormalconstraints ${UNSCOPEDNORMALXDC} -unscopedlateconstraints ${UNSCOPEDLATEXDC} -scopedearlyconstraints ${SCOPEDEARLYXDC} -scopednormalconstraints ${SCOPEDNORMALXDC} -scopedlateconstraints ${SCOPEDLATEXDC} ${miscparamkey} ${miscparamstring} -buildscripts ${scriptlist} ${vhdl2008option} -builddir ${CMAKE_BINARY_DIR}
                          DEPENDS ${nonprjbuildscript} ${VHDLFILES} ${VERILOGFILES} ${SYSTEMVERILOGFILES} ${vivnonprj_XCIFILES} ${UNSCOPEDEARLYXDC} ${UNSCOPEDNORMALXDC} ${UNSCOPEDLATEXDC} ${SCOPEDEARLYXDC} ${SCOPEDNORMALXDC} ${SCOPEDLATEXDC} ${scriptlist} ${cmdlinedictprocsscript} ${vivnonprj_SCRIPTDEPS}
                          )
endfunction()

file(GLOB genipscript "${CMAKE_CURRENT_LIST_DIR}/tcl/gen_xactip.tcl")
file(GLOB vivprjprocsscript "${CMAKE_CURRENT_LIST_DIR}/tcl/helper_proces/vivprj.tcl")

function(genip_func)
        set(options NODELETE)
        set(args IPNAME PARTNAME TOPNAME LIBNAME)
        set(list_args
	  VHDLFILES
	  VERILOGFILES 
          SYSTEMVERILOGFILES 
          PREIPXSCRIPTS  #run before ipx generated
          POSTIPXSCRIPTS #run after ipx generated
          SCRIPTDEPS #not passed to tcl, is deps
          MISCPARAMS #used for preipx and postipx
          )
        CMAKE_PARSE_ARGUMENTS(
                genip
                "${options}"
                "${args}"
                "${list_args}"
		"${ARGN}"
                )
        foreach(arg IN LISTS test_UNPARSED_ARGUMENTS)
                    message(WARNING "Unparsed argument: ${arg}")
        endforeach()

        message(STATUS "genip IPNAME ${genip_IPNAME}")
        message(STATUS "genip PARTNAME ${genip_PARTNAME}")
        message(STATUS "genip VHDLFILES ${genip_VHDLFILES}")
        message(STATUS "genip VERILOGFILES ${genip_VERILOGFILES}")
        message(STATUS "genip SYSTEMVERILOGFILES ${genip_SYSTEMVERILOGFILES}")
        message(STATUS "genip TOPNAME ${genip_TOPNAME}")
        message(STATUS "genip LIBNAME ${genip_LIBNAME}")
        message(STATUS "genip PREIPXSCRIPTS ${genip_PREIPXSCRIPTS}")
        message(STATUS "genip POSTIPXSCRIPTS ${genip_POSTIPXSCRIPTS}")
        message(STATUS "genip MISCPARAMS ${genip_MISCPARAMS}")
        message(STATUS "genip SCRIPTDEPS ${genip_SCRIPTDEPS}")
        
        set(ipdir ${CMAKE_BINARY_DIR}/${genip_PARTNAME}/ip_repo/${genip_LIBNAME}/${genip_IPNAME})
        set(laststring "")
        if (genip_NODELETE)
          set(laststring "--nodelete")
        endif()
        
        set(newvhdlfiles "")
        set(newverilogfiles "")
        set(newsvfiles "")
        foreach(filename IN LISTS genip_VHDLFILES)
          get_filename_component(name ${filename} NAME)
          list(APPEND newvhdlfiles ${ipdir}/hdl/${name})
          add_custom_command(OUTPUT ${ipdir}/hdl/${name}
            COMMAND ${CMAKE_COMMAND} -E make_directory ${ipdir}/hdl
            COMMAND ${CMAKE_COMMAND} -E remove ${ipdir}/hdl/${name}
            COMMAND ${CMAKE_COMMAND} -E create_symlink ${filename} ${ipdir}/hdl/${name}
            DEPENDS ${filename}) 
        endforeach()
        foreach(filename IN LISTS genip_VERILOGFILES)
          get_filename_component(name ${filename} NAME)
          list(APPEND newverilogfiles ${ipdir}/hdl/${name})
          add_custom_command(OUTPUT ${ipdir}/hdl/${name}
            COMMAND ${CMAKE_COMMAND} -E make_directory ${ipdir}/hdl
            COMMAND ${CMAKE_COMMAND} -E remove ${ipdir}/hdl/${name}
            COMMAND ${CMAKE_COMMAND} -E create_symlink ${filename} ${ipdir}/hdl/${name}
            DEPENDS ${filename}) 
        endforeach()
        foreach(filename IN LISTS genip_SYSTEMVERILOGFILES)
          get_filename_component(name ${filename} NAME)
          list(APPEND newsvfiles ${ipdir}/hdl/${name})
          add_custom_command(OUTPUT ${ipdir}/hdl/${name}
            COMMAND ${CMAKE_COMMAND} -E make_directory ${ipdir}/hdl
            COMMAND ${CMAKE_COMMAND} -E remove ${ipdir}/hdl/${name}
            COMMAND ${CMAKE_COMMAND} -E create_symlink ${filename} ${ipdir}/hdl/${name}
            DEPENDS ${filename}) 
        endforeach()

	if (vivnonprj_MISCPARAMS STREQUAL "")
	  set(miscparamkey "")
	  set(miscparamstring "")
	else()
	  #braces forces join, but allows nested dictionary with args as spacer
	  set(miscparamkey "-miscparams")
	  set(miscparamstring "arg ${vivnonprj_MISCPARAMS}")
	  string(REPLACE ";" " " miscparamstring "${miscparamstring}")
	endif()

        add_custom_command(OUTPUT ${ipdir}/component.xml ${ipdir}/xgui
          COMMAND vivado -mode batch -source ${genipscript} -tclargs -ipname ${genip_IPNAME} -partname ${genip_PARTNAME} -vhdlsynthfiles ${newvhdlfiles} -verilogsynthfiles ${newverilogfiles} -svsynthfiles ${newsvfiles} -topname ${genip_TOPNAME} -ipdir ${ipdir} -preipxscripts ${genip_PREIPXSCRIPTS} -postipxscripts ${genip_POSTIPXSCRIPTS} ${miscparamkey} {${miscparamstring}} ${laststring}
          DEPENDS ${newvhdlfiles} ${newverilogfiles} ${newsvfiles} ${genipscript} ${vivprjprocsscript} ${cmdlinedictprocsscript} ${genip_SCRIPTDEPS} ${genip_PREIPXSCRIPTS} ${genip_POSTIPXSCRIPTS}
          )

        list(APPEND ipxact_${genip_PARTNAME}_${genip_LIBNAME}_targets ${ipdir}/component.xml)
        set(ipxact_${genip_PARTNAME}_${genip_LIBNAME}_targets ${ipxact_${genip_PARTNAME}_${genip_LIBNAME}_targets} PARENT_SCOPE)
endfunction()

file(GLOB genxciscript ${CMAKE_CURRENT_LIST_DIR}/tcl/gen_xci.tcl)
function(genxci_func)
        set(options VERILOG)
        set(args
	  XCINAME
	  PARTNAME
	  XCIGENSCRIPT
	  )
        set(list_args )
        CMAKE_PARSE_ARGUMENTS(
                genxci
                "${options}"
                "${args}"
                "${list_args}"
		"${ARGN}"
                )
        foreach(arg IN LISTS test_UNPARSED_ARGUMENTS)
                    message(WARNING "Unparsed argument: ${arg}")
        endforeach()

        message(STATUS "genxci XCINAME ${genxci_XCINAME}")
        message(STATUS "genxci PARTNAME ${genxci_PARTNAME}")
	message(STATUS "gensci XCIGENSCRIPT ${gensci_XCIGENSCRIPT}")
	message(STATUS "gensci VERILOG ${genxci_VERILOG}")


	set(xcidir ${CMAKE_BINARY_DIR}/${genxci_PARTNAME}/xcidir)

	if (genxci_VERILOG)
	  set(targetlangstr -target_language Verilog)
	else()
	  set(targetlangstr "")
	endif()

	 add_custom_command(OUTPUT ${xcidir}/${genxci_XCINAME}/${genxci_XCINAME}.xci
             COMMAND ${CMAKE_COMMAND} -E make_directory ${xcidir}
             COMMAND ${CMAKE_COMMAND} -E remove ${xcidir}/${genxci_XCINAME}
	     COMMAND vivado -mode batch -source ${genxciscript} -tclargs -xciname ${genxci_XCINAME} -partname ${genxci_PARTNAME} -gendir ${xcidir} -xcigenscript ${genxci_XCIGENSCRIPT} ${targetlangstr}
	     DEPENDS ${gensciscript} ${cmdlinedictprocsscript}
	     )
endfunction()

###############################################################################
# MIT LICENSE
###############################################################################
# Copyright 2020 Trip Richert

# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
