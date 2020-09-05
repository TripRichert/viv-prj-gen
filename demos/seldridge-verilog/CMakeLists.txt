cmake_minimum_required(VERSION 3.3)
project(project)

include(../../functions.cmake)

file(GLOB vfiles verilog/src/*.v)

file(GLOB simfiles verilog/sim/*.v)

file(GLOB sqrtfiles verilog/src/pipeline_registers.v verilog/src/sqrt_generic.v)

set(partname "XC7Z020-1CLG484")


genvivprj_func(
  PRJNAME verilog
  VERILOGSYNTHFILES ${vfiles}
  VERILOGSIMFILES ${simfiles}
  PARTNAME ${partname}
  )

genip_func(
  IPNAME sqrt
  PARTNAME ${partname}
  LIBNAME test
  VERILOGFILES ${sqrtfiles}
  TOPNAME sqrt_generic)

add_custom_target(ip ALL
	DEPENDS ${CMAKE_BINARY_DIR}/${partname}/ip_repo/test/sqrt/component.xml
	)
