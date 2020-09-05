cmake_minimum_required(VERSION 3.3)
project(project)

include(../../functions.cmake)

file(GLOB hdlfiles "hdl/*.vhdl")
set(partname "XC7Z020-1CLG484")
file(GLOB unscopedLateConstrFiles "constraints/unscopedlate/*.xdc")

genvivprj_func(
  PRJNAME testprj
  PARTNAME ${partname}
  VHDLSYNTHFILES ${hdlfiles}
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
  TOPNAME demo_top
  PARTNAME ${partname}
  VHDLFILES ${hdlfiles}
  UNSCOPEDLATEXDC ${unscopedLateConstrFiles}
  )

add_custom_target(nonprj
	DEPENDS vivnonprj_${nonprjname}/${nonprjname}.bit
	)

genip_func(
  IPNAME genff
  PARTNAME ${partname}
  LIBNAME test
  VHDLFILES ${hdlfiles}
  TOPNAME GenericDFlipFlop
  )
      
add_custom_target(test_ip ALL
	DEPENDS ${ipxact_${partname}_test_targets}
	)
