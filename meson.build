project('vivprjgen')
subdir('tcl')
subdir('hdl')
subdir('constraints')
vivprog = find_program('vivado')
partname = 'XC7Z020-1CLG484'

outTarget = run_target('GenVivPrj',
  command : [vivprog, '-mode', 'batch', '-source', genfile,  '-tclargs', '-prjname', 'testprj',
             '-partname', partname, '-vhdl08synthfiles', hdlfiles, '-unscopedlateconstraints', unscopedLateConstrFiles, '-builddir', meson.current_build_dir()]
  )
