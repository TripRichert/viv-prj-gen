cmake_minimum_required(VERSION 3.3)
project(project)
enable_testing()

file(GLOB dict_tcl test_cmdlinedict.tcl)
add_test(NAME mytest
  COMMAND tclsh ${dict_tcl}
  )
