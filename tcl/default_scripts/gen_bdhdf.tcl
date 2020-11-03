
diction::requireKey hdfout {*}$argv

update_ip_catalog -rebuild -scan_changes
export_ip_user_files -of_objects [get_ips *] -no_script -reset -quiet
upgrade_ip [get_ips *] -log ip_upgrade.log
generate_target all [get_files *.bd]
export_ip_user_files -of_objects [get_files *.bd]
report_ip_status -name ip_status
update_ip_catalog -rebuild -scan_changes


reset_run synth_1
launch_runs impl_1 -to_step write_bitstream -jobs 4
wait_on_run impl_1
set dirext .runs
file copy -force [glob $prjname$dirext/impl_1/*.sysdef] [diction::getDef hdfout {*}$argv]

