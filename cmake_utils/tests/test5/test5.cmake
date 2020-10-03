
get_filename_component(test5_input_file test5/input_deps.txt REALPATH)
add_dependency_tree_file(test5_files ${test5_input_file})
get_list_from_dependency_tree(test5_output ${CMAKE_SOURCE_DIR}/test5/Register_tb.v)
file(WRITE ${CMAKE_BINARY_DIR}/test5.result "${test5_output}\n")
get_filename_component(test5_expected_file test5/expected.txt.in REALPATH)
configure_file(${test5_expected_file} test5.expected)

add_test(NAME test5
  COMMAND tclsh ${compare_tcl} ${CMAKE_BINARY_DIR}/test5.expected ${CMAKE_BINARY_DIR}/test5.result
  )
