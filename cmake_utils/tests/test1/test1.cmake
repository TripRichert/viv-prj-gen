
get_filename_component(test1_input_file test1/input.txt REALPATH)
read_filelist_no_substitution(test1_output ${test1_input_file})
file(WRITE ${CMAKE_BINARY_DIR}/test1.result "${test1_output}\n")
get_filename_component(test1_expected_file test1/expected.txt.in REALPATH)
configure_file(${test1_expected_file} test1.expected)

add_test(NAME test1
  COMMAND tclsh ${compare_tcl} ${CMAKE_BINARY_DIR}/test1.expected ${CMAKE_BINARY_DIR}/test1.result
  )
