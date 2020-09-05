include(CMakeParseArguments)
file(GLOB genvivprjscript "${CMAKE_CURRENT_LIST_DIR}/tcl/gen_prj.tcl")

function(genvivprj_func)
        set(options NOVHDL2008)
        set(args PRJNAME PARTNAME )
        set(list_args VHDLSYNTHFILES VHDLSIMFILES VERILOGSYNTHFILES VERILOGSIMFILES SVSYNTHFILES SVSIMFILES UNSCOPEDEARLYXDC UNSCOPEDNORMALXDC UNSCOPEDLATEXDC SCOPEDEARLYXDC SCOPEDNORMALXDC SCOPEDLATEXDC DATAFILES)
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

        message(STATUS "genvivprj PRJNAME ${genviv_PRJNAME}")
        message(STATUS "genvivprj PARTNAME ${genviv_PARTNAME}")
        message(STATUS "genvivprj VHDLSYNTHFILES ${genviv_VHDLSYNTHFILES}")
        message(STATUS "genvivprj VHDLSIMFILES ${genviv_VHDLSIMFILES}")
        message(STATUS "genvivprj VERILOGSYNTHFILES ${genviv_VERILOGSYNTHFILES}")
        message(STATUS "genvivprj VERILOGSIMFILES ${genviv_VERILOGSIMFILES}")
        message(STATUS "genvivprj SVSYNTHFILES ${genviv_SVSYNTHFILES}")
        message(STATUS "genvivprj SVSIMFILES ${genviv_SVSIMFILES}")
        message(STATUS "genvivprj UNSCOPEDEARLYXDC ${genviv_UNSCOPEDEARLYXDC}")
        message(STATUS "genvivprj UNSCOPEDNORMALXDC ${genviv_UNSCOPEDNORMALXDC}")
        message(STATUS "genvivprj UNSCOPEDLATEXDC ${genviv_UNSCOPEDLATEXDC}")
        message(STATUS "genvivprj SCOPEDEARLYXDC ${genviv_SCOPEDEARLYXDC}")
        message(STATUS "genvivprj SCOPEDNORMALXDC ${genviv_SCOPEDNORMALXDC}")
        message(STATUS "genvivprj SCOPEDLATEXDC ${genviv_SCOPEDLATEXDC}")
        message(STATUS "genvivprj DATAFILES ${genviv_DATAFILES}")
	message(STATUS "genvivprj NOVHDL2008 ${genviv_NOVHDL2008}")

        if (genviv_NOVHDL2008)
          set(vhdlfileopts -vhdlsynthfiles ${genviv_VHDLSYNTHFILES} -vhdlsimfiles ${genviv_VHDLSIMFILES})
        else()
          set(vhdlfileopts -vhdl08synthfiles ${genviv_VHDLSYNTHFILES} -vhdl08simfiles ${genviv_VHDLSIMFILES})
        endif()
        
        add_custom_target(${genviv_PRJNAME}_genvivprj
                COMMAND vivado -mode batch -source ${genvivprjscript} -tclargs -prjname ${genviv_PRJNAME} -partname ${genviv_PARTNAME} ${vhdlfileopts} -verilogsynthfiles ${genviv_VERILOGSYNTHFILES} -verilogsimfiles ${genviv_VERILOGSIMFILES} -systemverilogsynthfiles ${genviv_SVSYNTHFILES} -systemverilogsimfiles ${genviv_SVSIMFILES}  -unscopedearlyconstraints ${genviv_UNSCOPEDEARLYXDC} -unscopednormalconstraints ${genviv_UNSCOPEDNORMALXDC} -unscopedlateconstraints ${genviv_UNSCOPEDLATEXDC} -scopedearlyconstraints ${genviv_SCOPEDEARLYXDC} -scopednormalconstraints ${genviv_SCOPEDNORMALXDC} -scopedlateconstraints ${genviv_SCOPEDLATEXDC} -datafiles ${genviv_DATAFILES} -builddir ${CMAKE_BINARY_DIR}
                )
endfunction()


file(GLOB default_synthfile "${CMAKE_CURRENT_LIST_DIR}/tcl/default_scripts/nonprj_synth.tcl")
file(GLOB default_placefile "${CMAKE_CURRENT_LIST_DIR}/tcl/default_scripts/nonprj_place.tcl")
file(GLOB default_routefile "${CMAKE_CURRENT_LIST_DIR}/tcl/default_scripts/nonprj_route.tcl")
file(GLOB default_wrbitfile "${CMAKE_CURRENT_LIST_DIR}/tcl/default_scripts/nonpjr_writebit.tcl")
file(GLOB nonprjbuildscript "${CMAKE_CURRENT_LIST_DIR}/tcl/buildnonprj.tcl")
file(GLOB cmdlinedictprocsscript "${CMAKE_CURRENT_LIST_DIR}/tcl/helper_procs/cmdline_dict.tcl")


function(vivnonprjbitgen_func)
        set(options VHDL2008)
        set(args PRJNAME PARTNAME TOPNAME PRESYNTHSCRIPT SYNTHSCRIPT PLACESCRIPT ROUTESCRIPT WRBITSCRIPT)
        set(list_args 
	    VHDLFILES VERILOGFILES SYSTEMVERILOGFILES XCIFILES
	    UNSCOPEDEARLYXDC UNSCOPEDNORMALXDC UNSCOPEDLATEXDC
	    SCOPEDEARLYXDC SCOPEDNORMALXDC SCOPEDLATEXDC 
	    SCRIPTDEPS 
	    MISCPARAMS)
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

        message(STATUS "vivnonprjgenbit PRJNAME ${vivnonprj_PRJNAME}")
        message(STATUS "vivnonprjgenbit PARTNAME ${vivnonprj_PARTNAME}")
        message(STATUS "vivnonprjgenbit TOPNAME ${vivnonprj_TOPNAME}")
        message(STATUS "vivnonprjgenbit VHDLFILES ${vivnonprj_VHDLFILES}")
        message(STATUS "vivnonprjgenbit VERILOGFILES ${vivnonprj_VERILOGFILES}")
        message(STATUS "vivnonprjgenbit SYSTEMVERILOGFILES ${vivnonprj_SYSTEMVERILOGFILES}")
	message(STATUS "vivnonprjgenbit XCIFILES ${vivnonprj_XCIFILES}")
        message(STATUS "vivnonprjgenbit UNSCOPEDEARLYXDC ${vivnonprj_UNSCOPEDEARLYXDC}")
        message(STATUS "vivnonprjgenbit UNSCOPEDNORMALXDC ${vivnonprj_UNSCOPEDNORMALXDC}")
        message(STATUS "vivnonprjgenbit UNSCOPEDLATEXDC ${vivnonprj_UNSCOPEDLATEXDC}")
        message(STATUS "vivnonprjgenbit SCOPEDEARLYXDC ${vivnonprj_SCOPEDEARLYXDC}")
        message(STATUS "vivnonprjgenbit SCOPEDNORMALXDC ${vivnonprj_SCOPEDNORMALXDC}")
        message(STATUS "vivnonprjgenbit SCOPEDLATEXDC ${vivnonprj_SCOPEDLATEXDC}")
        message(STATUS "vivnonprjgenbit PRESYNTHSCRIPT ${vivnonprj_PRESYNTHSCRIPT}")
        message(STATUS "vivnonprjgenbit SYNTHSCRIPT ${vivnonprj_SYNTHSCRIPT}")
        message(STATUS "vivnonprjgenbit PLACESCRIPT ${vivnonprj_PLACESCRIPT}")
        message(STATUS "vivnonprjgenbit ROUTESCRIPT ${vivnonprj_ROUTESCRIPT}")
        message(STATUS "vivnonprjgenbit WRBITSCRIPT ${vivnonprj_WRBITSCRIPT}")
        message(STATUS "vivnonprjgenbit MISCPARAMS ${vivnonprj_MISCPARAMS}")
        message(STATUS "vivnonprjgenbit SCRIPTDEPS ${vivnonprj_SCRIPTDEPS}")
	

        
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
                          COMMAND vivado -mode batch -source ${nonprjbuildscript} -tclargs -prjname ${vivnonprj_PRJNAME} -partname ${vivnonprj_PARTNAME} -topname ${vivnonprj_TOPNAME} -vhdlsynthfiles ${vivnonprj_VHDLFILES} -verilogsynthfiles ${vivnonprj_VERILOGFILES} -svsynthfiles ${vivnonprj_SYSTEMVERILOGFILES} -xcifiles ${vivnonprj_XCIFILES} -unscopedearlyconstraints ${vivnonprj_UNSCOPEDEARLYXDC} -unscopednormalconstraints ${vivnonprj_UNSCOPEDNORMALXDC} -unscopedlateconstraints ${vivnonprj_UNSCOPEDLATEXDC} -scopedearlyconstraints ${vivnonprj_SCOPEDEARLYXDC} -scopednormalconstraints ${vivnonprj_SCOPEDNORMALXDC} -scopedlateconstraints ${vivnonprj_SCOPEDLATEXDC} ${miscparamkey} ${miscparamstring} -buildscripts ${scriptlist} ${vhdl2008option} -builddir ${CMAKE_BINARY_DIR}
                          DEPENDS ${nonprjbuildscript} ${vivnonprj_VHDLFILES} ${vivnonprj_VERILOGFILES} ${vivnonprj_SYSTEMVERILOGFILES} ${vivnonprj_XCIFILES} ${vivnonprj_UNSCOPEDEARLYXDC} ${vivnonprj_UNSCOPEDNORMALXDC} ${vivnonprj_UNSCOPEDLATEXDC} ${vivnonprj_SCOPEDEARLYXDC} ${vivnonprj_SCOPEDNORMALXDC} ${vivnonprj_SCOPEDLATEXDC} ${scriptlist} ${cmdlinedictprocsscript} ${vivnonprj_SCRIPTDEPS}
                          )
endfunction()

file(GLOB genipscript "${CMAKE_CURRENT_LIST_DIR}/tcl/gen_xactip.tcl")
file(GLOB vivprjprocsscript "${CMAKE_CURRENT_LIST_DIR}/tcl/helper_proces/vivprj.tcl")

function(genip_func)
        set(options NODELETE)
        set(args IPNAME PARTNAME TOPNAME LIBNAME)
        set(list_args  VHDLFILES  VERILOGFILES 
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
        set(args XCINAME PARTNAME XCIGENSCRIPT)
        set(list_args )
        CMAKE_PARSE_ARGUMENTS(
                PARSE_ARGV 0
                genxci
                "${options}"
                "${args}"
                "${list_args}"
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
	  
	
