get_filename_component(test4_input_file test4/input_deps.txt REALPATH)
add_dependency_tree_file(test4_files ${test4_input_file})
file(WRITE ${CMAKE_BINARY_DIR}/test4.result "${test4_files}\n")
get_filename_component(test4_expected_file test4/expected.txt.in REALPATH)
configure_file(${test4_expected_file} test4.expected)

add_test(NAME test4
  COMMAND tclsh ${compare_tcl} ${CMAKE_BINARY_DIR}/test4.expected ${CMAKE_BINARY_DIR}/test4.result
  )
