#see copyright notice(s) at bottom of file

include(CMakeParseArguments)

# tcl script for generating vivado projects
file(GLOB genvivprjscript "${CMAKE_CURRENT_LIST_DIR}/tcl/gen_prj.tcl")

#file used to parse commandline arguments
file(GLOB cmdlinedictprocsscript "${CMAKE_CURRENT_LIST_DIR}/tcl/helper_procs/cmdline_dict.tcl")

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
          message(STATUS "genvivprj NOVHDL2008? ${genviv_NOVHDL2008}")
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

file(GLOB cpyxciscript ${CMAKE_CURRENT_LIST_DIR}/tcl/cpy_xci.tcl)
function(cpyxci_func)
        set(options VERILOG)
        set(args
             XCIPATH
             PARTNAME
             DESTDIR
            )
        set(list_args )
        CMAKE_PARSE_ARGUMENTS(
                cpyxci
                "${options}"
                "${args}"
                "${list_args}"
                "${ARGN}"
                )
        foreach(arg IN LISTS test_UNPARSED_ARGUMENTS)
                    message(WARNING "Unparsed argument: ${arg}")
        endforeach()
        if(printFuncParams)
          message(STATUS "cpyxci XCIPATH ${cpyxci_XCIPATH}")
          message(STATUS "cpyxci PARTNAME ${cpyxci_PARTNAME}")
          message(STATUS "cpyxci DESTDIR ${cpyxci_DESTDIR}")
          message(STATUS "cpyxci VERILOG ${cpyxci_VERILOG}")
	endif()

        if (genxci_VERILOG)
          set(targetlangstr -target_language Verilog)
        else()
          set(targetlangstr "")
        endif()

	get_filename_component(xciname ${cpyxci_XCIPATH} NAME_WE)
	
        add_custom_command(OUTPUT ${cpyxci_DESTDIR}/${xciname}/${xciname}.xci ${cpyxci_DESTDIR}/${xciname}/${xciname}.stamp
             COMMAND ${CMAKE_COMMAND} -E remove ${cpyxci_DESTDIR}/${xciname}
             COMMAND vivado -mode batch -source ${cpyxciscript} -tclargs -xcipath ${cpyxci_XCIPATH} -partname ${cpyxci_PARTNAME} -gendir ${cpyxci_DESTDIR} ${targetlangstr}
	     COMMAND ${CMAKE_COMMAND} -E touch ${cpyxci_DESTDIR}/${xciname}/${xciname}.stamp
             DEPENDS ${cpyxciscript} ${cmdlinedictprocsscript} ${cpyxci_XCIPATH}
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
          message(STATUS "vivnonprjgenbit VHDL2008? ${vivnonprj_VHDL2008}")
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
        set(src_file_types
          VHDLFILES
          VERILOGFILES
          SYSTEMVERILOGFILES
          )
        set(gen_file_types "")
        foreach(file_type ${src_file_types})
          list(APPEND gen_file_types ${file_type}_GEN)
        endforeach()
        set(list_args
          ${src_file_types}
          ${gen_file_types}
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

        if(printFuncParams)
          foreach(arg ${args})
            message(STATUS "genip ${arg} ${genip_${arg}}")
          endforeach()
          foreach(arg ${list_args})
            message(STATUS "genip ${arg} ${genip_${arg}}")
          endforeach()
          message(STATUS "genip NODELETE? ${genip_NODELETE}")
        endif()

        foreach(file_type ${src_file_types})
          foreach(filename ${genip_${file_type}})
            if(NOT ${filename} STREQUAL "")
              if(NOT EXISTS ${filename})
                message(SEND_ERROR "missing file ${filename}")
              endif()
            endif()
          endforeach()
        endforeach()

        foreach(file_type ${src_file_types})
          set(${file_type} ${genip_${file_type}} ${genip_${file_type}_GEN})
        endforeach()
        
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

        if(printFuncParams)
                message(STATUS "genxci XCINAME ${genxci_XCINAME}")
                message(STATUS "genxci PARTNAME ${genxci_PARTNAME}")
                message(STATUS "genxci XCIGENSCRIPT ${genxci_XCIGENSCRIPT}")
                message(STATUS "genxci VERILOG ${genxci_VERILOG}")
	endif()

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

        list(APPEND xci_${genxci_PARTNAME}_targets ${xcidir}/${genxci_XCINAME}/${genxci_XCINAME}.xci)
        set(xci_${genxci_PARTNAME}_targets ${xci_${genxci_PARTNAME}_targets} PARENT_SCOPE)
endfunction()


###############################################################################
# MIT LICENSE
###############################################################################
# Copyright 2020 Trip Richert

# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
