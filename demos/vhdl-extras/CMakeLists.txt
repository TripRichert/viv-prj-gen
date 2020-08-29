cmake_minimum_required(VERSION 3.10)
project(project)

include(../../functions.cmake)

file(GLOB hdlfiles vhdl-extras/rtl/extras/*.vhdl)

file(GLOB simfiles vhdl-extras/rtl/test/*.vhdl)

set(partname "XC7Z020-1CLG484")


genvivprj_func(
  PRJNAME extras
  VHDLSYNTHFILES ${hdlfiles}
  VHDLSIMFILES ${simfiles}
  PARTNAME ${partname}
  )
