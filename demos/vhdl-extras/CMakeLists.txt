cmake_minimum_required(VERSION 3.3)
project(project)

include(../../functions.cmake)

file(GLOB hdlfiles vhdl-extras/rtl/extras/*.vhdl)

file(GLOB simfiles vhdl-extras/rtl/test/*.vhdl)

file(GLOB hdl08files vhdl-extras/rtl/extras_2008/*.vhdl)

file(GLOB sim08files vhdl-extras/rtl/test_2008/*.vhdl)

set(partname "XC7Z020-1CLG484")


genvivprj_func(
  PRJNAME extras
  VHDLSYNTHFILES ${hdlfiles}
  VHDLSIMFILES ${simfiles}
  PARTNAME ${partname}
  NOVHDL2008
  )

genvivprj_func(
  PRJNAME extras_2008
  VHDLSYNTHFILES ${hdlfiles} ${hdl08files}
  VHDLSIMFILES ${simfiles} ${sim08files}
  PARTNAME ${partname}
  NOVHDL2008
  )
