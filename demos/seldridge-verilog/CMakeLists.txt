cmake_minimum_required(VERSION 3.10)
project(project)

include(../../functions.cmake)

file(GLOB vfiles verilog/src/*.v)

file(GLOB simfiles verilog/sim/*.v)


set(partname "XC7Z020-1CLG484")


genvivprj_func(
  PRJNAME verilog
  VERILOGSYNTHFILES ${vfiles}
  VERILOGSIMFILES ${simfiles}
  PARTNAME ${partname}
  )
