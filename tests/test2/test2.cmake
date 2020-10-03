get_filename_component(test2_input_file test2/input.txt REALPATH)
read_filelist_no_substitution(test2_output ${test2_input_file})
file(WRITE ${CMAKE_BINARY_DIR}/test2.result "${test2_output}\n")
get_filename_component(test2_expected_file test2/expected.txt.in REALPATH)
configure_file(${test2_expected_file} test2.expected)

add_test(NAME test2
  COMMAND tclsh ${compare_tcl} ${CMAKE_BINARY_DIR}/test2.expected ${CMAKE_BINARY_DIR}/test2.result
  )
