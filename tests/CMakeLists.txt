cmake_minimum_required(VERSION 3.3)
project(project)
enable_testing()

file(GLOB dict_tcl test_cmdlinedict.tcl)
file(GLOB file_tcl test_addfiles.tcl)
add_test(NAME dictiontest
  COMMAND tclsh ${dict_tcl}
  )

add_test(NAME filestest
  COMMAND vivado -mode batch -source ${file_tcl}
  )
