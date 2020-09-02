if {[get_ips] != ""} {
    puts "ips [get_ips]"
    generate_target -force -verbose -quiet {synthesis implementation} [get_ips]
    synth_ip [get_ips]
}
synth_design -top $topname -part $partname
write_checkpoint -force post_synth
report_timing_summary -file post_synth_timing_summary.rpt
report_power -file post_synth_power.rpt

