#see copyright notice(s) at bottom of file

include(CMakeParseArguments)

# tcl script for generating vivado projects
file(GLOB genvivprjscript "${CMAKE_CURRENT_LIST_DIR}/tcl/gen_prj.tcl")

#file used to parse commandline arguments
file(GLOB cmdlinedictprocsscript "${CMAKE_CURRENT_LIST_DIR}/tcl/tcl_utils/cmdline_dict.tcl")

function(add_vivado_devel_project)
  set(options NOVHDL2008)
  set(args
    PRJNAME
    PARTNAME
    )
  set(file_types
    VHDLSYNTHFILES
    VHDLSIMFILES
    VERILOGSYNTHFILES
    VERILOGSIMFILES
    SVSYNTHFILES
    SVSIMFILES
    XCIFILES
    UNSCOPEDEARLYXDC
    UNSCOPEDNORMALXDC
    UNSCOPEDLATEXDC
    SCOPEDEARLYXDC
    SCOPEDNORMALXDC
    SCOPEDLATEXDC
    DATAFILES
    )
  set(gen_file_types "")
  foreach(file_type ${file_types})
    list(APPEND gen_file_types ${file_type}_GEN)
  endforeach()
  set(list_args
    ${file_types}
    ${gen_file_types}
    )
  CMAKE_PARSE_ARGUMENTS(
    genviv
    "${options}"
    "${args}"
    "${list_args}"
    "${ARGN}"
    )
  foreach(arg IN LISTS genviv_UNPARSED_ARGUMENTS)
    message(WARNING "Unparsed argument: ${arg}")
  endforeach()

  if(printFuncParams)
    foreach(arg ${args})
      message(STATUS "genvivprj ${arg} ${genviv_${arg}}")
    endforeach()
    foreach(arg ${list_args})
      message(STATUS "genvivprj ${arg} ${genviv_${arg}}")
    endforeach()
    message(STATUS "genvivprj NOVHDL2008? ${genviv_NOVHDL2008}")
  endif()

  foreach(file_type ${file_types})
    foreach(filename ${genviv_${file_type}})
      if(NOT ${filename} STREQUAL "")
        if(NOT EXISTS ${filename})
          message(SEND_ERROR "missing file ${filename}")
        endif()
      endif()
    endforeach()
  endforeach()
  
  foreach(file_type ${file_types})
    set(${file_type} ${genviv_${file_type}} ${genviv_${file_type}_GEN})
    list(LENGTH ${file_type} list_length)
    if (${list_length})
      list(REMOVE_DUPLICATES ${file_type})
    endif()
  endforeach()

  if (genviv_NOVHDL2008)
    set(vhdlfileopts -vhdlsynthfiles ${VHDLSYNTHFILES} -vhdlsimfiles ${VHDLSIMFILES})
  else()
    set(vhdlfileopts -vhdl08synthfiles ${VHDLSYNTHFILES} -vhdl08simfiles ${VHDLSIMFILES})
  endif()

  file(MAKE_DIRECTORY "${CMAKE_BINARY_DIR}/${genviv_PARTNAME}/devel_prjs")
  
  add_custom_target(${genviv_PRJNAME}_genvivprj
    COMMAND vivado -mode batch -source ${genvivprjscript} -tclargs -prjname ${genviv_PRJNAME} -partname ${genviv_PARTNAME} ${vhdlfileopts} -verilogsynthfiles ${VERILOGSYNTHFILES} -verilogsimfiles ${VERILOGSIMFILES} -systemverilogsynthfiles ${SVSYNTHFILES} -systemverilogsimfiles ${SVSIMFILES} -xcifiles ${XCIFILES} -unscopedearlyconstraints ${UNSCOPEDEARLYXDC} -unscopednormalconstraints ${UNSCOPEDNORMALXDC} -unscopedlateconstraints ${UNSCOPEDLATEXDC} -scopedearlyconstraints ${SCOPEDEARLYXDC} -scopednormalconstraints ${SCOPEDNORMALXDC} -scopedlateconstraints ${SCOPEDLATEXDC} -datafiles ${DATAFILES} -builddir "${CMAKE_BINARY_DIR}/${genviv_PARTNAME}/devel_prjs"
    DEPENDS ${VHDLSYNTHFILES} ${VHDLSIMFILES} ${VERILOGSYNTHFILES} ${VERILOGSIMFILES} ${SVSYNTHFILES} ${SVSIMFILES} ${XCIFILES} ${UNSCOPEDEARLYXDC} ${UNSCOPEDNORMALXDC} ${UNSCOPEDLATEXDC} ${SCOPEDEARLYXDC} ${SCOPEDNORMALXDC} ${SCOPEDLATEXDC} ${DATAFILES} ${genvivprjscript} ${cmdlinedictprocsscript}
    )
endfunction()

file(GLOB cpyxciscript ${CMAKE_CURRENT_LIST_DIR}/tcl/cpy_xci.tcl)
function(copy_vivado_xcifile)
  set(options VERILOG)
  set(args
    XCIPATH
    PARTNAME
    DESTDIR
    XCI_OUTPUT
    XCI_STAMPOUTPUT
    )
  set(list_args )
  CMAKE_PARSE_ARGUMENTS(
    cpyxci
    "${options}"
    "${args}"
    "${list_args}"
    "${ARGN}"
    )
  foreach(arg IN LISTS cpyxci_UNPARSED_ARGUMENTS)
    message(WARNING "Unparsed argument: ${arg}")
  endforeach()
  if(printFuncParams)
    message(STATUS "cpyxci XCIPATH ${cpyxci_XCIPATH}")
    message(STATUS "cpyxci PARTNAME ${cpyxci_PARTNAME}")
    message(STATUS "cpyxci DESTDIR ${cpyxci_DESTDIR}")
    message(STATUS "cpyxci VERILOG ${cpyxci_VERILOG}")
    message(STATUS "cpyxci XCI_OUTPUT ${cpyxci_XCI_OUTPUT}")
    message(STATUS "cpyxci XCI_STAMPOUTPUT ${cpyxci_XCI_STAMPOUTPUT}")
  endif()

  if (genxci_VERILOG)
    set(targetlangstr -target_language Verilog)
  else()
    set(targetlangstr "")
  endif()

  get_filename_component(xciname ${cpyxci_XCIPATH} NAME_WE)
  
  add_custom_command(OUTPUT ${cpyxci_DESTDIR}/${xciname}/${xciname}.xci ${cpyxci_DESTDIR}/${xciname}/${xciname}.stamp
    COMMAND ${CMAKE_COMMAND} -E remove_directory ${cpyxci_DESTDIR}/${xciname}
    COMMAND vivado -mode batch -source ${cpyxciscript} -tclargs -xcipath ${cpyxci_XCIPATH} -partname ${cpyxci_PARTNAME} -gendir ${cpyxci_DESTDIR} ${targetlangstr}
    COMMAND ${CMAKE_COMMAND} -E touch ${cpyxci_DESTDIR}/${xciname}/${xciname}.stamp
    DEPENDS ${cpyxciscript} ${cmdlinedictprocsscript} ${cpyxci_XCIPATH}
    )
  if (NOT ${cpyxci_XCI_OUTPUT} STREQUAL "")
    set(${cpyxci_XCI_OUTPUT} ${cpyxci_DESTDIR}/${xciname}/${xciname}.xci PARENT_SCOPE)
  endif()
  if (NOT ${cpyxci_XCI_STAMPOUTPUT} STREQUAL "")
    set(${cpyxci_XCI_STAMPOUTPUT} "${cpyxci_DESTDIR}/${xciname}/${xciname}.stamp" PARENT_SCOPE)
  endif()

  set_property(SOURCE ${cpyxci_DESTDIR}/${xciname}/${xciname}.xci
    PROPERTY OBJECT_OUTPUTS ${cpyxci_DESTDIR}/${xciname}/${xciname}.stamp
    )
  
endfunction()

#default nonproject file scripts
file(GLOB default_synthfile "${CMAKE_CURRENT_LIST_DIR}/tcl/default_scripts/nonprj_synth.tcl")
file(GLOB default_placefile "${CMAKE_CURRENT_LIST_DIR}/tcl/default_scripts/nonprj_place.tcl")
file(GLOB default_routefile "${CMAKE_CURRENT_LIST_DIR}/tcl/default_scripts/nonprj_route.tcl")
file(GLOB default_wrbitfile "${CMAKE_CURRENT_LIST_DIR}/tcl/default_scripts/nonpjr_writebit.tcl")
file(GLOB nonprjbuildscript "${CMAKE_CURRENT_LIST_DIR}/tcl/buildnonprj.tcl")

function(add_vivado_nonprj_bitfile)
  set(options VHDL2008)
  set(args
    PRJNAME
    PARTNAME
    TOPNAME
    PRESYNTHSCRIPT
    SYNTHSCRIPT
    PLACESCRIPT
    ROUTESCRIPT
    WRBITSCRIPT
    BITFILE_OUTPUT
    )
  set(src_file_types
    VHDLFILES
    VERILOGFILES
    SYSTEMVERILOGFILES
    UNSCOPEDEARLYXDC
    UNSCOPEDNORMALXDC
    UNSCOPEDLATEXDC
    SCOPEDEARLYXDC
    SCOPEDNORMALXDC
    SCOPEDLATEXDC
    )
  set(gen_file_types "")
  foreach(file_type ${src_file_types})
    list(APPEND gen_file_types ${file_type}_GEN)
  endforeach()
  
  set(list_args
    ${src_file_types}
    ${gen_file_types}
    XCIFILES_GEN
    DEPENDS 
    MISCPARAMS
    )
  CMAKE_PARSE_ARGUMENTS(
    vivnonprj
    "${options}"
    "${args}"
    "${list_args}"
    "${ARGN}"
    )
  foreach(arg IN LISTS vivnonprj_UNPARSED_ARGUMENTS)
    message(WARNING "Unparsed argument: ${arg}")
  endforeach()

  if(printFuncParams)
    foreach(arg ${args})
      message(STATUS "vivnonprjgenbit ${arg} ${vivnonprj_${arg}}")
    endforeach()
    foreach(arg ${list_args})
      message(STATUS "vivnonprjgenbit ${arg} ${vivnonprj_${arg}}")
    endforeach()
    message(STATUS "vivnonprjgenbit VHDL2008? ${vivnonprj_VHDL2008}")
    message(STATUS "vivnonprjgenbit BITFILE_OUTPUT ${vivnonprj_BITFILE_OUTPUT}")
  endif()

  foreach(file_type ${src_file_types})
    foreach(filename ${vivnonprj_${file_type}})
      if(NOT ${filename} STREQUAL "")
        if(NOT EXISTS ${filename})
          message(SEND_ERROR "missing file ${filename}")
        endif()
      endif()
    endforeach()
  endforeach()

  foreach(file_type ${src_file_types})
    set(${file_type} ${vivnonprj_${file_type}} 
      ${vivnonprj_${file_type}_GEN})
  endforeach()

  if("${VHDLFILES}" STREQUAL "" AND "${VERILOGFILES}" STREQUAL "" AND "${SYSTEMVERILOGFILES}" STREQUAL "")
    message(FATAL_ERROR "no hdl source files used in nonproject")
  endif()

  set(scriptlist)
  if (NOT ${vivnonprj_PRESYNTHSCRIPT} STREQUAL "")
    set(scriptlist ${scriptlist} ${vivnonprj_PRESYNTHSCRIPT})
  endif()
  if (NOT ${vivnonprj_SYNTHSCRIPT} STREQUAL "")
    set(scriptlist ${scriptlist} ${vivnonprj_SYNTHSCRIPT})
  else()
    set(scriptlist ${scriptlist} ${default_synthfile})
  endif()
  if (NOT ${vivnonprj_PLACESCRIPT} STREQUAL "")
    set(scriptlist ${scriptlist} ${vivnonprj_PLACESCRIPT})
  else()
    set(scriptlist ${scriptlist} ${default_placefile})
  endif()
  if (NOT ${vivnonprj_ROUTESCRIPT} STREQUAL "")
    set(scriptlist ${scriptlist} ${vivnonprj_ROUTESCRIPT})
  else()
    set(scriptlist ${scriptlist} ${default_routefile})
  endif()
  if (NOT ${vivnonprj_WRBITSCRIPT} STREQUAL "")
    set(scriptlist ${scriptlist} ${vivnonprj_WRBITSCRIPT})
  else()
    set(scriptlist ${scriptlist} ${default_wrbitfile})
  endif()
  
  if (vivnonprj_VHDL2008)
    set(vhdl2008option --vhdl2008)
  endif()

  if (vivnonprj_MISCPARAMS STREQUAL "")
    set(miscparamkey "")
    set(miscparamstring "")
  else()
    #braces forces join, but allows nested dictionary with args as spacer
    set(miscparamkey "-miscparams")
    set(miscparamstring "arg ${vivnonprj_MISCPARAMS}")
    string(REPLACE ";" " " miscparamstring "${miscparamstring}")
  endif()

  set(xci_depends "")
  foreach(xcifile ${vivnonprj_XCIFILES_GEN})
    if (NOT "${xcifile}" STREQUAL "")
      get_property( xci_dep
        SOURCE ${xcifile}
        PROPERTY OBJECT_OUTPUTS
        )
      if (NOT "${xci_dep}" STREQUAL "")
        list(APPEND xci_depends "${xci_dep}")
      else()
        message(WARNING "generated xci ${xcifile} not associated with object output")
        list(APPEND xci_depends "${xcifile}")
      endif()
    endif()
  endforeach()

  set(bitfile_output "vivnonprj_${vivnonprj_PRJNAME}/${vivnonprj_PRJNAME}.bit")
  add_custom_command(OUTPUT "${bitfile_output}"
    COMMAND vivado -mode batch -source ${nonprjbuildscript} -tclargs -prjname ${vivnonprj_PRJNAME} -partname ${vivnonprj_PARTNAME} -topname ${vivnonprj_TOPNAME} -vhdlsynthfiles ${VHDLFILES} -verilogsynthfiles ${VERILOGFILES} -svsynthfiles ${SYSTEMVERILOGFILES} -xcifiles ${vivnonprj_XCIFILES_GEN} -unscopedearlyconstraints ${UNSCOPEDEARLYXDC} -unscopednormalconstraints ${UNSCOPEDNORMALXDC} -unscopedlateconstraints ${UNSCOPEDLATEXDC} -scopedearlyconstraints ${SCOPEDEARLYXDC} -scopednormalconstraints ${SCOPEDNORMALXDC} -scopedlateconstraints ${SCOPEDLATEXDC} ${miscparamkey} ${miscparamstring} -buildscripts ${scriptlist} ${vhdl2008option} -builddir ${CMAKE_BINARY_DIR}
    DEPENDS ${nonprjbuildscript} ${VHDLFILES} ${VERILOGFILES} ${SYSTEMVERILOGFILES} ${xci_depends} ${UNSCOPEDEARLYXDC} ${UNSCOPEDNORMALXDC} ${UNSCOPEDLATEXDC} ${SCOPEDEARLYXDC} ${SCOPEDNORMALXDC} ${SCOPEDLATEXDC} ${scriptlist} ${cmdlinedictprocsscript} ${vivnonprj_DEPENDS}
    )
  if (NOT ${vivnonprj_BITFILE_OUTPUT} STREQUAL "")
    set(${vivnonprj_BITFILE_OUTPUT} "${bitfile_output}" PARENT_SCOPE)
  endif()
endfunction()

file(GLOB genipscript "${CMAKE_CURRENT_LIST_DIR}/tcl/gen_xactip.tcl")
file(GLOB vivprjprocsscript "${CMAKE_CURRENT_LIST_DIR}/tcl/helper_proces/vivprj.tcl")

function(add_vivado_xact_ip)
  set(options NODELETE)
  set(args
    IPNAME
    PARTNAME
    TOPNAME
    SUBDIRNAME
    IP_STAMPOUTPUT
    )
  set(src_file_types
    VHDLFILES
    VERILOGFILES
    SYSTEMVERILOGFILES
    )
  set(gen_file_types "")
  foreach(file_type ${src_file_types})
    list(APPEND gen_file_types ${file_type}_GEN)
  endforeach()
  set(list_args
    ${src_file_types}
    ${gen_file_types}
    PREIPXSCRIPTS  #run before ipx generated
    POSTIPXSCRIPTS #run after ipx generated
    DEPENDS #not passed to tcl, is deps
    MISCPARAMS #used for preipx and postipx
    )
  CMAKE_PARSE_ARGUMENTS(
    genip
    "${options}"
    "${args}"
    "${list_args}"
    "${ARGN}"
    )
  foreach(arg IN LISTS genip_UNPARSED_ARGUMENTS)
    message(WARNING "Unparsed argument: ${arg}")
  endforeach()

  if(printFuncParams)
    foreach(arg ${args})
      message(STATUS "genip ${arg} ${genip_${arg}}")
    endforeach()
    foreach(arg ${list_args})
      message(STATUS "genip ${arg} ${genip_${arg}}")
    endforeach()
    message(STATUS "genip NODELETE? ${genip_NODELETE}")
    message(STATUS "genip IP_STAMPOUTPUT ${genip_IP_STAMPOUTPUT}")
  endif()

  foreach(file_type ${src_file_types})
    foreach(filename ${genip_${file_type}})
      if(NOT ${filename} STREQUAL "")
        if(NOT EXISTS ${filename})
          message(SEND_ERROR "missing file ${filename}")
        endif()
      endif()
    endforeach()
  endforeach()

  foreach(file_type ${src_file_types})
    set(${file_type} ${genip_${file_type}} ${genip_${file_type}_GEN})
  endforeach()

  if("${VHDLFILES}" STREQUAL "" AND "${VERILOGFILES}" STREQUAL "" AND "${SYSTEMVERILOGFILES}" STREQUAL "")
    message(FATAL_ERROR "no hdl source files used in xact ip")
  endif()

  
  set(ipdir ${CMAKE_BINARY_DIR}/${genip_PARTNAME}/ip_repo/${genip_SUBDIRNAME}/${genip_IPNAME})
  set(laststring "")
  if (genip_NODELETE)
    set(laststring "--nodelete")
  endif()
  
  set(newvhdlfiles "")
  set(newverilogfiles "")
  set(newsvfiles "")
  foreach(filename IN LISTS genip_VHDLFILES)
    get_filename_component(name ${filename} NAME)
    list(APPEND newvhdlfiles ${ipdir}/hdl/${name})
    add_custom_command(OUTPUT ${ipdir}/hdl/${name}
      COMMAND ${CMAKE_COMMAND} -E make_directory ${ipdir}/hdl
      COMMAND ${CMAKE_COMMAND} -E remove_directory ${ipdir}/hdl/${name}
      COMMAND ${CMAKE_COMMAND} -E create_symlink ${filename} ${ipdir}/hdl/${name}
      DEPENDS ${filename}) 
  endforeach()
  foreach(filename IN LISTS genip_VERILOGFILES)
    get_filename_component(name ${filename} NAME)
    list(APPEND newverilogfiles ${ipdir}/hdl/${name})
    add_custom_command(OUTPUT ${ipdir}/hdl/${name}
      COMMAND ${CMAKE_COMMAND} -E make_directory ${ipdir}/hdl
      COMMAND ${CMAKE_COMMAND} -E remove_directory ${ipdir}/hdl/${name}
      COMMAND ${CMAKE_COMMAND} -E create_symlink ${filename} ${ipdir}/hdl/${name}
      DEPENDS ${filename}) 
  endforeach()
  foreach(filename IN LISTS genip_SYSTEMVERILOGFILES)
    get_filename_component(name ${filename} NAME)
    list(APPEND newsvfiles ${ipdir}/hdl/${name})
    add_custom_command(OUTPUT ${ipdir}/hdl/${name}
      COMMAND ${CMAKE_COMMAND} -E make_directory ${ipdir}/hdl
      COMMAND ${CMAKE_COMMAND} -E remove_directory ${ipdir}/hdl/${name}
      COMMAND ${CMAKE_COMMAND} -E create_symlink ${filename} ${ipdir}/hdl/${name}
      DEPENDS ${filename}) 
  endforeach()

  if (vivnonprj_MISCPARAMS STREQUAL "")
    set(miscparamkey "")
    set(miscparamstring "")
  else()
    #braces forces join, but allows nested dictionary with args as spacer
    set(miscparamkey "-miscparams")
    set(miscparamstring "arg ${vivnonprj_MISCPARAMS}")
    string(REPLACE ";" " " miscparamstring "${miscparamstring}")
  endif()

  add_custom_command(OUTPUT ${ipdir}/component.xml ${ipdir}/xgui ${ipdir}/${genip_IPNAME}.stamp
    COMMAND vivado -mode batch -source ${genipscript} -tclargs -ipname ${genip_IPNAME} -partname ${genip_PARTNAME} -vhdlsynthfiles ${newvhdlfiles} -verilogsynthfiles ${newverilogfiles} -svsynthfiles ${newsvfiles} -topname ${genip_TOPNAME} -ipdir ${ipdir} -preipxscripts ${genip_PREIPXSCRIPTS} -postipxscripts ${genip_POSTIPXSCRIPTS} ${miscparamkey} {${miscparamstring}} ${laststring}
    COMMAND ${CMAKE_COMMAND} -E touch ${ipdir}/${genip_IPNAME}.stamp
    DEPENDS ${newvhdlfiles} ${newverilogfiles} ${newsvfiles} ${genipscript} ${vivprjprocsscript} ${cmdlinedictprocsscript} ${genip_DEPENDS} ${genip_PREIPXSCRIPTS} ${genip_POSTIPXSCRIPTS}
    )

  if (NOT ${genip_IP_STAMPOUTPUT} STREQUAL "")
    set(${genip_IP_STAMPOUTPUT} ${ipdir}/${genip_IPNAME}.stamp PARENT_SCOPE)
  endif()

endfunction()

file(GLOB genxciscript ${CMAKE_CURRENT_LIST_DIR}/tcl/gen_xci.tcl)
function(add_vivado_xcifile)
  set(options VERILOG)
  set(args
    XCINAME
    PARTNAME
    XCIGENSCRIPT
    XCI_OUTPUT
    XCI_STAMPOUTPUT
    )
  set(list_args )
  CMAKE_PARSE_ARGUMENTS(
    genxci
    "${options}"
    "${args}"
    "${list_args}"
    "${ARGN}"
    )
  foreach(arg IN LISTS genxci_UNPARSED_ARGUMENTS)
    message(WARNING "Unparsed argument: ${arg}")
  endforeach()

  if(printFuncParams)
    message(STATUS "genxci XCINAME ${genxci_XCINAME}")
    message(STATUS "genxci PARTNAME ${genxci_PARTNAME}")
    message(STATUS "genxci XCIGENSCRIPT ${genxci_XCIGENSCRIPT}")
    message(STATUS "genxci VERILOG ${genxci_VERILOG}")
    message(STATUS "genxci XCI_OUTPUT ${genxci_XCI_OUTPUT}")
    message(STATUS "genxci XCI_STAMPOUTPUT ${genxci_XCI_STAMPOUTPUT}")
  endif()

  set(xcidir ${CMAKE_BINARY_DIR}/${genxci_PARTNAME}/xcidir)

  if (genxci_VERILOG)
    set(targetlangstr -target_language Verilog)
  else()
    set(targetlangstr "")
  endif()

  add_custom_command(OUTPUT ${xcidir}/${genxci_XCINAME}/${genxci_XCINAME}.xci ${xcidir}/${genxci_XCINAME}/${genxci_XCINAME}.stamp
    COMMAND ${CMAKE_COMMAND} -E make_directory ${xcidir}
    COMMAND ${CMAKE_COMMAND} -E remove_directory ${xcidir}/${genxci_XCINAME}
    COMMAND vivado -mode batch -source ${genxciscript} -tclargs -xciname ${genxci_XCINAME} -partname ${genxci_PARTNAME} -gendir ${xcidir} -xcigenscript ${genxci_XCIGENSCRIPT} ${targetlangstr}
    COMMAND ${CMAKE_COMMAND} -E touch ${xcidir}/${genxci_XCINAME}/${genxci_XCINAME}.stamp
    DEPENDS ${gensciscript} ${cmdlinedictprocsscript}
    )

  if (NOT ${genxci_XCI_OUTPUT} STREQUAL "")
    set(${genxci_XCI_OUTPUT} ${xcidir}/${genxci_XCINAME}/${genxci_XCINAME}.xci PARENT_SCOPE)
  endif()
  if (NOT ${genxci_XCI_STAMPOUTPUT} STREQUAL "")
    set(${genxci_XCI_STAMPOUTPUT} "${xcidir}/${genxci_XCINAME}/${genxci_XCINAME}.stamp" PARENT_SCOPE)
  endif()
  set_property(SOURCE "${xcidir}/${genxci_XCINAME}/${genxci_XCINAME}.xci"
    PROPERTY OBJECT_OUTPUTS "${xcidir}/${genxci_XCINAME}/${genxci_XCINAME}.stamp"
    )
endfunction()

file(GLOB genbdhdfscript ${CMAKE_CURRENT_LIST_DIR}/tcl/gen_bdhdf.tcl)
function(add_vivado_bd_hdf)
  set(options VERILOG)
  set(args
    PRJNAME
    PARTNAME
    BDSCRIPT
    BOARDNAME
    HDFFILE_OUTPUT
    )
  set(src_file_types
    UNSCOPEDEARLYXDC
    UNSCOPEDNORMALXDC
    UNSCOPEDLATEXDC
    SCOPEDEARLYXDC
    SCOPEDNORMALXDC
    SCOPEDLATEXDC
    )
  set(gen_file_types "")
  foreach(file_type ${src_file_types})
    list(APPEND gen_file_types ${file_type}_GEN)
  endforeach()
  set(list_args
    ${gen_file_types}
    XCIFILES_GEN
    DEPENDS
    )
  CMAKE_PARSE_ARGUMENTS(
    genhdf
    "${options}"
    "${args}"
    "${list_args}"
    "${ARGN}"
    )
  foreach(arg IN LISTS genhdf_UNPARSED_ARGUMENTS)
    message(WARNING "Unparsed argument: ${arg}")
  endforeach()

  if(printFuncParams)
    foreach(arg ${list_args})
      message(STATUS "genhdf ${arg} ${genhdf_${arg}}")
    endforeach()
    message(STATUS "genhdf PRJNAME ${genhdf_PRJNAME}")
    message(STATUS "genhdf PARTNAME ${genhdf_PARTNAME}")
    message(STATUS "genhdf BDSCRIPT ${genhdf_BDSCRIPT}")
    message(STATUS "genhdf BOARDNAME ${genhdf_BOARDNAME}")    
  endif()

  foreach(file_type ${src_file_types})
    foreach(filename ${genhdf_${file_type}})
      if(NOT ${filename} STREQUAL "")
        if(NOT EXISTS ${filename})
          message(SEND_ERROR "missing file ${filename}")
        endif()
      endif()
    endforeach()
  endforeach()

  foreach(file_type ${src_file_types})
    set(${file_type} ${genhdf_${file_type}} 
      ${genhdf_${file_type}_GEN})
  endforeach()


  set(xci_depends "")
  foreach(xcifile ${genhdf_XCIFILES_GEN})
    if (NOT "${xcifile}" STREQUAL "")
      get_property( xci_dep
        SOURCE ${xcifile}
        PROPERTY OBJECT_OUTPUTS
        )
      if (NOT "${xci_dep}" STREQUAL "")
        list(APPEND xci_depends "${xci_dep}")
      else()
        message(WARNING "generated xci ${xcifile} not associated with object output")
        list(APPEND xci_depends "${xcifile}")
      endif()
    endif()
  endforeach()


  set(hdffile_output ${CMAKE_BINARY_DIR}/${genhdf_PARTNAME}/bin/${genhdf_PRJNAME}.hdf)
  set(prjbuilddir ${CMAKE_BINARY_DIR}/${genhdf_PARTNAME}/genprjs)
  add_custom_command(OUTPUT ${hdffile_output}
    COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_BINARY_DIR}/${genhdf_PARTNAME}/bin
    COMMAND ${CMAKE_COMMAND} -E make_directory ${prjbuilddir}
    COMMAND ${CMAKE_COMMAND} -E remove_directory ${prjbuilddir}/bdprj_${genhdf_PRJNAME}
    COMMAND vivado -mode batch -source ${genbdhdfscript} -tclargs -builddir ${prjbuilddir} -prjname ${genhdf_PRJNAME} -partname ${genhdf_PARTNAME} -bdscript ${genhdf_BDSCRIPT} -hdfout ${CMAKE_BINARY_DIR}/${genhdf_PARTNAME}/bin/${genhdf_PRJNAME}.hdf -ip_repo_dirs ${CMAKE_BINARY_DIR}/${genhdf_PARTNAME}/ip_repo -xcifiles ${genhdf_XCIFILES_GEN} -unscopedearlyconstraints ${UNSCOPEDEARLYXDC} -unscopednormalconstraints ${UNSCOPEDNORMALXDC} -unscopedlateconstraints ${UNSCOPEDLATEXDC} -scopedearlyconstraints ${SCOPEDEARLYXDC} -scopednormalconstraints ${SCOPEDNORMALXDC} -scopedlateconstraints ${SCOPEDLATEXDC}
    DEPENDS ${genbdhdfscript} ${cmdlinedictprocsscript} ${genhdf_DEPENDS} ${xci_depends}
    )

  if (NOT ${genhdf_HDFFILE_OUTPUT} STREQUAL "")
    set(${genhdf_HDFFILE_OUTPUT} ${hdffile_output} PARENT_SCOPE)
  endif()

endfunction()

###############################################################################
# MIT LICENSE
###############################################################################
# Copyright 2020 Trip Richert

# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
