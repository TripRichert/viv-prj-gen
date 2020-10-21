create_bd_design "system"

update_compile_order -fileset sources_1

create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 processing_system7_0
set_property -dict [list CONFIG.preset {ZedBoard}] [get_bd_cells processing_system7_0]
set_property -dict [list CONFIG.PCW_QSPI_GRP_SINGLE_SS_ENABLE {1} CONFIG.PCW_TTC0_PERIPHERAL_ENABLE {0}] [get_bd_cells processing_system7_0]
apply_bd_automation -rule xilinx.com:bd_rule:processing_system7 -config {make_external "FIXED_IO, DDR" apply_board_preset "1" Master "Disable" Slave "Disable" }  [get_bd_cells processing_system7_0]

set_property -dict [list CONFIG.PCW_QSPI_GRP_SINGLE_SS_ENABLE {1} CONFIG.PCW_USB0_PERIPHERAL_ENABLE {0}] [get_bd_cells processing_system7_0]

connect_bd_net [get_bd_pins processing_system7_0/FCLK_CLK0] [get_bd_pins processing_system7_0/M_AXI_GP0_ACLK]

validate_bd_design
