cmake_minimum_required(VERSION 3.3)

file(GLOB hdlfiles "hdl/*.vhdl")
set(partname "XC7Z020-1CLG484")
file(GLOB unscopedLateConstrFiles "constraints/unscopedlate/*.xdc")
file(GLOB genfile "tcl/gensimprj.tcl")

add_custom_target(genvivprj
	COMMAND vivado -mode batch -source ${genfile} -tclargs -prjname testprj -partname ${partname} -vhdl08synthfiles ${hdlfiles} -unscopedlateconstraints ${unscopedLateConstrFiles} -builddir ${CMAKE_BINARY_DIR}
	)


set(nonprjscripts ${nonprjscripts}
		  "tcl/synth.tcl"
		  "tcl/place.tcl"
		  "tcl/route.tcl"
		  "tcl/writebit.tcl"
		  )

set(nonprjname "nonprjdemo")
file(GLOB nonprjbuildscript "tcl/buildnonprj.tcl")
file(GLOB synthfile "tcl/synth.tcl")
file(GLOB placefile "tcl/place.tcl")
file(GLOB routefile "tcl/route.tcl")
file(GLOB writebitfile "tcl/writebit.tcl")

add_custom_command(OUTPUT ${nonprjname}/${nonprjname}.bit
			  COMMAND vivado -mode batch -source ${nonprjbuildscript} -tclargs -prjname ${nonprjname} -partname ${partname} -topname demo_top -vhdlsynthfiles ${hdlfiles} -unscopedlateconstraints ${unscopedLateConstrFiles} -buildscripts ${synthfile} ${placefile} ${routefile} ${writebitfile} -builddir ${CMAKE_BINARY_DIR}
			  DEPENDS ${nonprjbuildscript} ${hdlfiles} ${unscopedLateConstrFiles} ${nonprjscripts}
			  )
add_custom_target(nonprj
	DEPENDS ${nonprjname}/${nonprjname}.bit
	)

