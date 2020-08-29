set_property PACKAGE_PIN Y11  [get_ports {clk}];  # "JA1"
set_property PACKAGE_PIN AA8  [get_ports {myinput}];  # "JA10"
set_property PACKAGE_PIN AA11 [get_ports {myoutput}];  # "JA2"

set_property IOSTANDARD LVCMOS33 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports myinput]
set_property IOSTANDARD LVCMOS33 [get_ports myoutput]

set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets clk_IBUF]
