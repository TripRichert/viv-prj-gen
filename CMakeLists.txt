cmake_minimum_required(VERSION 3.12)
project(project)
include(CMakeParseArguments)

function(genvivprj_func)
	set(options)
	set(args PRJNAME PARTNAME )
	set(list_args VHDLFILES UNSCOPEDEARLYXDC UNSCOPEDNORMALXDC UNSCOPEDLATEXDC SCOPEDEARLYXDC SCOPEDNORMALXDC SCOPEDLATEXDC)
	CMAKE_PARSE_ARGUMENTS(
		PARSE_ARGV 0
		genviv
		"${options}"
		"${args}"
		"${list_args}"
		)
	foreach(arg IN LISTS test_UNPARSED_ARGUMENTS)
		    message(WARNING "Unparsed argument: ${arg}")
	endforeach()

	message(STATUS "genvivprj PRJNAME ${genviv_PRJNAME}")
	message(STATUS "genvivprj PARTNAME ${genviv_PARTNAME}")
	message(STATUS "genvivprj VHDLFILES ${genviv_VHDLFILES}")
	message(STATUS "genvivprj UNSCOPEDEARLYXDC ${genviv_UNSCOPEDEARLYXDC}")
        message(STATUS "genvivprj UNSCOPEDNORMALXDC ${genviv_UNSCOPEDNORMALXDC}")
        message(STATUS "genvivprj UNSCOPEDLATEXDC ${genviv_UNSCOPEDLATEXDC}")
        message(STATUS "genvivprj SCOPEDEARLYXDC ${genviv_SCOPEDEARLYXDC}")
        message(STATUS "genvivprj SCOPEDNORMALXDC ${genviv_SCOPEDNORMALXDC}")
        message(STATUS "genvivprj SCOPEDLATEXDC ${genviv_SCOPEDLATEXDC}")

	file(GLOB genvivprjscript "tcl/gensimprj.tcl")
	
	add_custom_target(${genviv_PRJNAME}_genvivprj
		COMMAND vivado -mode batch -source ${genvivprjscript} -tclargs -prjname ${genviv_PRJNAME} -partname ${genviv_PARTNAME} -vhdl08synthfiles ${genviv_VHDLFILES} -unscopedearlyconstraints ${genviv_UNSCOPEDEARLYXDC} -unscopednormalconstraints ${genviv_UNSCOPEDNORMALXDC} -unscopedlateconstraints ${genviv_UNSCOPEDLATEXDC} -scopedearlyconstraints ${genviv_SCOPEDEARLYXDC} -scopednormalconstraints ${genviv_SCOPEDNORMALXDC} -scopedlateconstraints ${genviv_SCOPEDLATEXDC} -builddir ${CMAKE_BINARY_DIR}
		)
endfunction()

function(vivnonprjbitgen_func)
	set(options)
	set(args PRJNAME PARTNAME TOPNAME PRESYNTHSCRIPT SYNTHSCRIPT PLACESCRIPT ROUTESCRIPT WRBITSCRIPT)
	set(list_args VHDLFILES UNSCOPEDEARLYXDC UNSCOPEDNORMALXDC UNSCOPEDLATEXDC SCOPEDEARLYXDC SCOPEDNORMALXDC SCOPEDLATEXDC)
	CMAKE_PARSE_ARGUMENTS(
		PARSE_ARGV 0
		vivnonprj
		"${options}"
		"${args}"
		"${list_args}"
		)
	foreach(arg IN LISTS vivnonprj_UNPARSED_ARGUMENTS)
		    message(WARNING "Unparsed argument: ${arg}")
	endforeach()

	message(STATUS "vivnonprjgenbit PRJNAME ${vivnonprj_PRJNAME}")
	message(STATUS "vivnonprjgenbit PARTNAME ${vivnonprj_PARTNAME}")
	message(STATUS "vivnonprjgenbit TOPNAME ${vivnonprj_PARTNAME}")
	message(STATUS "vivnonprjgenbit VHDLFILES ${vivnonprj_VHDLFILES}")
	message(STATUS "vivnonprjgenbit UNSCOPEDEARLYXDC ${vivnonprj_UNSCOPEDEARLYXDC}")
        message(STATUS "vivnonprjgenbit UNSCOPEDNORMALXDC ${vivnonprj_UNSCOPEDNORMALXDC}")
        message(STATUS "vivnonprjgenbit UNSCOPEDLATEXDC ${vivnonprj_UNSCOPEDLATEXDC}")
        message(STATUS "vivnonprjgenbit SCOPEDEARLYXDC ${vivnonprj_SCOPEDEARLYXDC}")
        message(STATUS "vivnonprjgenbit SCOPEDNORMALXDC ${vivnonprj_SCOPEDNORMALXDC}")
        message(STATUS "vivnonprjgenbit SCOPEDLATEXDC ${vivnonprj_SCOPEDLATEXDC}")
        message(STATUS "vivnonprjgenbit SCOPEDLATEXDC ${vivnonprj_SCOPEDLATEXDC}")
        message(STATUS "vivnonprjgenbit SCOPEDLATEXDC ${vivnonprj_SCOPEDLATEXDC}")
	message(STATUS "vivnonprjgenbit PRESYNTHSCRIPT ${vivnonprj_PRESYNTHSCRIPT}")
	message(STATUS "vivnonprjgenbit SYNTHSCRIPT ${vivnonprj_SYNTHSCRIPT}")
	message(STATUS "vivnonprjgenbit PLACESCRIPT ${vivnonprj_PLACESCRIPT}")
	message(STATUS "vivnonprjgenbit ROUTESCRIPT ${vivnonprj_ROUTESCRIPT}")
	message(STATUS "vivnonprjgenbit WRBITSCRIPT ${vivnonprj_WRBITSCRIPT}")

	file(GLOB default_synthfile "tcl/synth.tcl")
	file(GLOB default_placefile "tcl/place.tcl")
	file(GLOB default_routefile "tcl/route.tcl")
	file(GLOB default_wrbitfile "tcl/writebit.tcl")
	file(GLOB nonprjbuildscript "tcl/buildnonprj.tcl")
	
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
	


	add_custom_command(OUTPUT ${vivnonprj_PRJNAME}/${vivnonprj_PRJNAME}.bit
			  COMMAND vivado -mode batch -source ${nonprjbuildscript} -tclargs -prjname ${vivnonprj_PRJNAME} -partname ${vivnonprj_PARTNAME} -topname demo_top -vhdlsynthfiles ${vivnonprj_VHDLFILES} -unscopedearlyconstraints ${vivnonprj_UNSCOPEDEARLYXDC} -unscopednormalconstraints ${vivnonprj_UNSCOPEDNORMALXDC} -unscopedlateconstraints ${vivnonprj_UNSCOPEDLATEXDC} -scopedearlyconstraints ${vivnonprj_SCOPEDEARLYXDC} -scopednormalconstraints ${vivnonprj_SCOPEDNORMALXDC} -scopedlateconstraints ${vivnonprj_SCOPEDLATEXDC} -buildscripts ${scriptlist} -builddir ${CMAKE_BINARY_DIR}
			  DEPENDS ${nonprjbuildscript} ${vivnonprj_VHDLFILES} ${vivnonprj_UNSCOPEDEARLYXDC} ${vivnonprj_UNSCOPEDNORMALXDC} ${vivnonprj_UNSCOPEDLATEXDC} ${vivnonprj_SCOPEDEARLYXDC} ${vivnonprj_SCOPEDNORMALXDC} ${vivnonprj_SCOPEDLATEXDC} ${scriptlist}
			  )


endfunction()
	    

file(GLOB hdlfiles "hdl/*.vhdl")
set(partname "XC7Z020-1CLG484")
file(GLOB unscopedLateConstrFiles "constraints/unscopedlate/*.xdc")
#file(GLOB genfile "tcl/gensimprj.tcl")
genvivprj_func(
  PRJNAME testprj
  PARTNAME ${partname}
  VHDLFILES ${hdlfiles}
  UNSCOPEDLATEXDC ${unscopedLateConstrFiles}
  )


set(nonprjscripts ${nonprjscripts}
		  "tcl/synth.tcl"
		  "tcl/place.tcl"
		  "tcl/route.tcl"
		  "tcl/writebit.tcl"
		  )

set(nonprjname "nonprjdemo")
file(GLOB synthfile "tcl/synth.tcl")
file(GLOB placefile "tcl/place.tcl")
file(GLOB routefile "tcl/route.tcl")
file(GLOB writebitfile "tcl/writebit.tcl")

vivnonprjbitgen_func(
  PRJNAME ${nonprjname}
  PARTNAME ${partname}
  VHDLFILES ${hdlfiles}
  UNSCOPEDLATEXDC ${unscopedLateConstrFiles}
  )


#add_custom_command(OUTPUT ${nonprjname}/${nonprjname}.bit
#			  COMMAND vivado -mode batch -source ${nonprjbuildscript} -tclargs -prjname ${nonprjname} -partname ${partname} -topname demo_top -vhdlsynthfiles ${hdlfiles} -unscopedlateconstraints ${unscopedLateConstrFiles} -buildscripts ${synthfile} ${placefile} ${routefile} ${writebitfile} -builddir ${CMAKE_BINARY_DIR}
#			  DEPENDS ${nonprjbuildscript} ${hdlfiles} ${unscopedLateConstrFiles} ${nonprjscripts}
#			  )
add_custom_target(nonprj
	DEPENDS ${nonprjname}/${nonprjname}.bit
	)

