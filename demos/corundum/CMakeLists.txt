cmake_minimum_required(VERSION 3.3)
project(project)

set(webpack_parts XCKU035 XCKU3P XCU50 XCU280)
#*  Exablaze ExaNIC X10 (Xilinx Kintex UltraScale XCKU035)
#*  Exablaze ExaNIC X25 (Xilinx Kintex UltraScale+ XCKU3P)
#*  Xilinx Alveo U50 (Xilinx Virtex UltraScale+ XCU50)
#*  Xilinx Alveo U280 (Xilinx Virtex UltraScale+ XCU280)



include(../../functions.cmake)

#file(GLOB commonverilog corundum/fpga/common/rtl/*.v)
#file(GLOB axiverilog corundum/fpga/lib/axi/rtl/*.v)
#file(GLOB ethverilog corundum/fpga/lib/eth/rtl/*.v)
#file(GLOB pcieverilog corundum/fpga/lib/pcie/rtl/*.v)
#file(GLOB axisverilog corundum/fpga/lib/eth/lib/axis/rtl/*.v)
set(partname xcku035-fbva676-2-e)
set(hdlfilenames  corundum/fpga/mqnic/ExaNIC_X10/fpga/rtl/fpga.v
  corundum/fpga/mqnic/ExaNIC_X10/fpga/rtl/fpga_core.v
  corundum/fpga/mqnic/ExaNIC_X10/fpga/rtl/debounce_switch.v
  corundum/fpga/mqnic/ExaNIC_X10/fpga/rtl/sync_signal.v
  corundum/fpga/mqnic/ExaNIC_X10/fpga/rtl/common/interface.v
  corundum/fpga/mqnic/ExaNIC_X10/fpga/rtl/common/port.v
  corundum/fpga/mqnic/ExaNIC_X10/fpga/rtl/common/cpl_write.v
  corundum/fpga/mqnic/ExaNIC_X10/fpga/rtl/common/cpl_op_mux.v
  corundum/fpga/mqnic/ExaNIC_X10/fpga/rtl/common/desc_fetch.v
  corundum/fpga/mqnic/ExaNIC_X10/fpga/rtl/common/desc_op_mux.v
  corundum/fpga/mqnic/ExaNIC_X10/fpga/rtl/common/queue_manager.v
  corundum/fpga/mqnic/ExaNIC_X10/fpga/rtl/common/cpl_queue_manager.v
  corundum/fpga/mqnic/ExaNIC_X10/fpga/rtl/common/event_mux.v
  corundum/fpga/mqnic/ExaNIC_X10/fpga/rtl/common/tx_scheduler_rr.v
  corundum/fpga/mqnic/ExaNIC_X10/fpga/rtl/common/tdma_scheduler.v
  corundum/fpga/mqnic/ExaNIC_X10/fpga/rtl/common/tx_engine.v
  corundum/fpga/mqnic/ExaNIC_X10/fpga/rtl/common/rx_engine.v
  corundum/fpga/mqnic/ExaNIC_X10/fpga/rtl/common/tx_checksum.v
  corundum/fpga/mqnic/ExaNIC_X10/fpga/rtl/common/rx_hash.v
  corundum/fpga/mqnic/ExaNIC_X10/fpga/rtl/common/rx_checksum.v
  corundum/fpga/mqnic/ExaNIC_X10/fpga/lib/eth/rtl/eth_mac_10g.v
  corundum/fpga/mqnic/ExaNIC_X10/fpga/lib/eth/rtl/eth_mac_10g_fifo.v
  corundum/fpga/mqnic/ExaNIC_X10/fpga/lib/eth/rtl/axis_xgmii_rx_64.v
  corundum/fpga/mqnic/ExaNIC_X10/fpga/lib/eth/rtl/axis_xgmii_tx_64.v
  corundum/fpga/mqnic/ExaNIC_X10/fpga/lib/eth/rtl/eth_phy_10g.v
  corundum/fpga/mqnic/ExaNIC_X10/fpga/lib/eth/rtl/eth_phy_10g_rx.v
  corundum/fpga/mqnic/ExaNIC_X10/fpga/lib/eth/rtl/eth_phy_10g_rx_if.v
  corundum/fpga/mqnic/ExaNIC_X10/fpga/lib/eth/rtl/eth_phy_10g_rx_frame_sync.v
  corundum/fpga/mqnic/ExaNIC_X10/fpga/lib/eth/rtl/eth_phy_10g_rx_ber_mon.v
  corundum/fpga/mqnic/ExaNIC_X10/fpga/lib/eth/rtl/eth_phy_10g_tx.v
  corundum/fpga/mqnic/ExaNIC_X10/fpga/lib/eth/rtl/eth_phy_10g_tx_if.v
  corundum/fpga/mqnic/ExaNIC_X10/fpga/lib/eth/rtl/xgmii_baser_dec_64.v
  corundum/fpga/mqnic/ExaNIC_X10/fpga/lib/eth/rtl/xgmii_baser_enc_64.v
  corundum/fpga/mqnic/ExaNIC_X10/fpga/lib/eth/rtl/lfsr.v
  corundum/fpga/mqnic/ExaNIC_X10/fpga/lib/eth/rtl/ptp_clock.v
  corundum/fpga/mqnic/ExaNIC_X10/fpga/lib/eth/rtl/ptp_clock_cdc.v
  corundum/fpga/mqnic/ExaNIC_X10/fpga/lib/eth/rtl/ptp_perout.v
  corundum/fpga/mqnic/ExaNIC_X10/fpga/lib/eth/rtl/ptp_ts_extract.v
  corundum/fpga/mqnic/ExaNIC_X10/fpga/lib/axi/rtl/axil_interconnect.v
  corundum/fpga/mqnic/ExaNIC_X10/fpga/lib/axi/rtl/arbiter.v
  corundum/fpga/mqnic/ExaNIC_X10/fpga/lib/axi/rtl/priority_encoder.v
  corundum/fpga/mqnic/ExaNIC_X10/fpga/lib/axis/rtl/axis_adapter.v
  corundum/fpga/mqnic/ExaNIC_X10/fpga/lib/axis/rtl/axis_async_fifo.v
  corundum/fpga/mqnic/ExaNIC_X10/fpga/lib/axis/rtl/axis_async_fifo_adapter.v
  corundum/fpga/mqnic/ExaNIC_X10/fpga/lib/axis/rtl/axis_arb_mux.v
  corundum/fpga/mqnic/ExaNIC_X10/fpga/lib/axis/rtl/axis_fifo.v
  corundum/fpga/mqnic/ExaNIC_X10/fpga/lib/axis/rtl/axis_register.v
  corundum/fpga/mqnic/ExaNIC_X10/fpga/lib/axis/rtl/sync_reset.v
  corundum/fpga/mqnic/ExaNIC_X10/fpga/lib/pcie/rtl/pcie_us_axil_master.v
  corundum/fpga/mqnic/ExaNIC_X10/fpga/lib/pcie/rtl/dma_if_pcie_us.v
  corundum/fpga/mqnic/ExaNIC_X10/fpga/lib/pcie/rtl/dma_if_pcie_us_rd.v
  corundum/fpga/mqnic/ExaNIC_X10/fpga/lib/pcie/rtl/dma_if_pcie_us_wr.v
  corundum/fpga/mqnic/ExaNIC_X10/fpga/lib/pcie/rtl/dma_if_mux.v
  corundum/fpga/mqnic/ExaNIC_X10/fpga/lib/pcie/rtl/dma_if_mux_rd.v
  corundum/fpga/mqnic/ExaNIC_X10/fpga/lib/pcie/rtl/dma_if_mux_wr.v
  corundum/fpga/mqnic/ExaNIC_X10/fpga/lib/pcie/rtl/dma_psdpram.v
  corundum/fpga/mqnic/ExaNIC_X10/fpga/lib/pcie/rtl/dma_client_axis_sink.v
  corundum/fpga/mqnic/ExaNIC_X10/fpga/lib/pcie/rtl/dma_client_axis_source.v
  corundum/fpga/mqnic/ExaNIC_X10/fpga/lib/pcie/rtl/pcie_us_cfg.v
  corundum/fpga/mqnic/ExaNIC_X10/fpga/lib/pcie/rtl/pcie_us_msi.v
  corundum/fpga/mqnic/ExaNIC_X10/fpga/lib/pcie/rtl/pcie_tag_manager.v
  corundum/fpga/mqnic/ExaNIC_X10/fpga/lib/pcie/rtl/pulse_merge.v
  )

set(hdlfiles "")
foreach(filename ${hdlfilenames})
  file(GLOB tmpfilename ${filename})
  list(APPEND hdlfiles ${tmpfilename})
endforeach()


file(GLOB constrfiles corundum/fpga/mqnic/ExaNIC_X10/fpga/fpga.xdc)
file(GLOB xcigenfiles corundum/fpga/mqnic/ExaNIC_X10/fpga/ip/*.tcl)

set(xcilist "")

foreach(filename ${xcigenfiles})
  get_filename_component(xciname ${filename} NAME_WE)
  genxci_func(
    XCINAME ${xciname}
    PARTNAME ${partname}
    XCIGENSCRIPT ${filename}
    VERILOG true
    )
   add_custom_target(${xciname}_xci ALL
     DEPENDS ${CMAKE_BINARY_DIR}/${partname}/xcidir/${xciname}/${xciname}.xci
     )
   list(APPEND xcilist ${CMAKE_BINARY_DIR}/${partname}/xcidir/${xciname}/${xciname}.xci)
endforeach()


file(GLOB postsynthtcl
  corundum/fpga/lib/axis/syn/axis_async_fifo.tcl
  corundum/fpga/lib/axis/syn/sync_reset.tcl
  corundum/fpga/lib/eth/syn/ptp_clock_cdc.tcl
)


# genvivprj_func(
#   PRJNAME corundum
#   VERILOGSYNTHFILES ${hdlfiles}
#   PARTNAME ${partname}
#   NOVHDL2008
#   )

file(GLOB synthscript tcl/synth.tcl)
file(GLOB basesynthscript ../../tcl/default_scripts/nonprj_synth.tcl)
message(STATUS "basesynth "${basesynthscript})
set(nonprjname nic_x10)
set(miscparam -synthbasescript ${basesynthscript})
vivnonprjbitgen_func(
  PRJNAME ${nonprjname}
  PARTNAME ${partname}
  TOPNAME fpga
  VERILOGFILES ${hdlfiles}
  XCIFILES ${xcilist}
  UNSCOPEDNORMALXDC ${constrfiles}
  SYNTHSCRIPT ${synthscript}
  SCRIPTDEPS ${basesynthscript}
  MISCPARAMS ${miscparam}
  )

add_custom_target(nonprj
	DEPENDS vivnonprj_${nonprjname}/${nonprjname}.bit
	)

###############################################################################
# MIT LICENSE
###############################################################################
#Copyright 2020 Trip Richert

#Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

#The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

#THE SOFTWARE IS PROVIDED AS IS, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
