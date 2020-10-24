get_filename_component(test3_input_file test3/input.txt REALPATH)
read_filelist(test3_output ${test3_input_file})
file(WRITE ${CMAKE_BINARY_DIR}/test3.result "${test3_output}\n")
get_filename_component(test3_expected_file test3/expected.txt.in REALPATH)
configure_file(${test3_expected_file} test3.expected)

add_test(NAME test3
  COMMAND tclsh ${compare_tcl} ${CMAKE_BINARY_DIR}/test3.expected ${CMAKE_BINARY_DIR}/test3.result
  )
