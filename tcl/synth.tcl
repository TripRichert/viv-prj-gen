synth_design -top $topname -part $partname
write_checkpoint -force post_synth
report_timing_summary -file post_synth_timing_summary.rpt
report_power -file post_synth_power.rpt

