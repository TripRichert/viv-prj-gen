project('vivprjgen')
subdir('tcl')
subdir('hdl')
vivprog = find_program('vivado')
partname = 'XC7Z020-1CLG484'

outTarget = run_target('GenVivPrj',
  command : [vivprog, '-mode', 'batch', '-source', genfile,  '-tclargs', '-prjname', 'testprj','-partname', partname, '-vhdl08synthfiles', hdlfiles]
  )
