route_design
write_checkpoint -force post_route
report_timing_summary -file post_route_timing_summary.rpt
report_timing -sort_by group -max_paths 100 -path_type summary -file post_route_timing.rpt
report_clock_utilization -file chock_util.rpt
report_power -file post_route_power.rpt
report_drc -file post_imp_drc.rpt
write_verilog -force impl_netlist.v
write_xdc -no_fixed_only -force prj_impl.xdc
