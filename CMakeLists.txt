cmake_minimum_required(VERSION 3.3)

file(GLOB hdlfiles "hdl/*.vhdl")
set(partname "XC7Z020-1CLG484")
file(GLOB unscopedLateConstrFiles "constraints/unscopedlate/*.xdc")
file(GLOB genfile "tcl/gensimprj.tcl")

add_custom_target(genvivprj
	COMMAND vivado -mode batch -source ${genfile} -tclargs -prjname testprj -partname ${partname} -vhdl08synthfiles ${hdlfiles} -unscopedlateconstraints ${unscopedLateConstrFiles} -builddir ${CMAKE_BINARY_DIR}
	)


