cmake_minimum_required(VERSION 3.10)
project(project)

set(webpack_parts XCKU035 XCKU3P XCU50 XCU280)
#*  Exablaze ExaNIC X10 (Xilinx Kintex UltraScale XCKU035)
#*  Exablaze ExaNIC X25 (Xilinx Kintex UltraScale+ XCKU3P)
#*  Xilinx Alveo U50 (Xilinx Virtex UltraScale+ XCU50)
#*  Xilinx Alveo U280 (Xilinx Virtex UltraScale+ XCU280)



include(../../functions.cmake)

file(GLOB commonverilog corundum/fpga/common/rtl/*.v)
file(GLOB axiverilog corundum/fpga/lib/axi/rtl/*.v)
file(GLOB ethverilog corundum/fpga/lib/eth/rtl/*.v)
file(GLOB pcieverilog corundum/fpga/lib/pcie/rtl/*.v)
file(GLOB axisverilog corundum/fpga/lib/eth/lib/axis/rtl/*.v)
set(partname xcku035-fbva676-2-e)
file(GLOB boardfiles corundum/fpga/mqnic/ExaNIC_X10/fpga/rtl/*.v)
file(GLOB constrfiles corundum/fpga/mqnic/ExaNIC_X10/fpga/*.xdc)
file(GLOB xcigenfiles corundum/fpga/mqnic/ExaNIC_X10/fpga/ip/*.tcl)

set(hdlfiles ${commonverilog} ${axisverilog} ${ethverilog} ${pcieverilog} ${axisverilog} ${boardfiles})

foreach(filename ${xcigenfiles})
  get_filename_component(xciname ${filename} NAME_WE)
  genxci_func(
    XCINAME ${xciname}
    PARTNAME ${partname}
    XCIGENSCRIPT ${filename}
    VERILOG true
    )
   add_custom_target(${xciname}_xci ALL
     DEPENDS ${CMAKE_BINARY_DIR}/${partname}/xcidir/${xciname}/created.stamp
     )
endforeach()


file(GLOB postsynthtcl corundum/fpga/lib/eth/syn/mii_phy_if.tcl 
  corundum/fpga/lib/eth/syn/eth_mac_1g_rgmii.tcl 
  corundum/fpga/lib/eth/syn/eth_mac_fifo.tcl 
  corundum/fpga/lib/eth/syn/rgmii_phy_if.tcl 
  corundum/fpga/lib/eth/syn/eth_mac_1g_gmii.tcl 
  corundum/fpga/lib/eth/syn/ptp_clock_cdc.tcl 
  corundum/fpga/lib/eth/syn/gmii_phy_if.tcl 
  corundum/fpga/lib/eth/lib/axis/syn/axis_async_fifo.tcl 
  corundum/fpga/lib/eth/lib/axis/syn/sync_reset.tcl 
  corundum/fpga/lib/axi/syn/axil_cdc.tcl
  corundum/fpga/common/syn/tdma_ber_ch.tcl)


# genvivprj_func(
#   PRJNAME corundum
#   VERILOGSYNTHFILES ${hdlfiles}
#   PARTNAME ${partname}
#   NOVHDL2008
#   )

# file(GLOB synthscript tcl/synth.tcl)
# file(GLOB basesynthscript ../../tcl/synth.tcl)
# message(STATUS "basesynth "${basesynthscript})
# set(nonprjname nic_x10)
# set(miscparam -synthbasescript ${basesynthscript})
# vivnonprjbitgen_func(
#   PRJNAME ${nonprjname}
#   PARTNAME ${partname}
#   TOPNAME fpga
#   VERILOGFILES ${hdlfiles}
#   UNSCOPEDNORMALXDC ${constrfiles}
#   SYNTHSCRIPT ${synthscript}
#   SCRIPTDEPS ${basesynthscript}
#   MISCPARAMS ${miscparam}
#   )

# add_custom_target(nonprj
# 	DEPENDS ${nonprjname}/${nonprjname}.bit
# 	)
