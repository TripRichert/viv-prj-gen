puts "executing $argv0"
puts "argv is:$argv"

source [file join [file dirname [info script]] "helper_procs/cmdline_dict.tcl"]
source [file join [file dirname [info script]] "helper_procs/vivprj.tcl"]

if { $argc == 0 } {
    puts "No arguments!"
    puts "execution suspended of $argv0"
    exit 2
}
if {[diction::hasDuplicates [diction::getKeys $argv]]} {
    puts "error! Duplicate keys!"
    puts "execution suspended of $argv0"
    exit 3
}

set requiredKeys [list builddir prjname partname bdscript hdfout]
set allowedKeys [list boardname target_language vhdlbdwrapper\
		     verilogbdwrapper \
		     ip_repo_dirs\
		     scopedearlyconstraints scopednormalconstraints \
		     scopedlateconstraints unscopedearlyconstraints \
		     unscopednormalconstraints unscopedlateconstraints
                   ]

foreach key $requiredKeys {
    lappend allowedKeys $key
}

foreach requiredKey $requiredKeys {
    diction::requireKey $requiredKey {*}$argv
}
set unrecognizedKeys []
foreach key [diction::getKeys {*}$argv] {
    if {[lsearch $allowedKeys $key] == -1} {
        lappend unrecognizedKeys $key
    }
}
if {[llength $unrecognizedKeys]} {
    puts "did not recognize keys $unrecognizedKeys"
	puts "allowed keys are: $allowedKeys"
	puts "execution suspended of $argv0"
	exit 5
}


if {[diction::getDef builddir {*}$argv] != ""} {
    cd [diction::getDef builddir {*}$argv]
} else {
    puts "builddir failed"
    exit 7
}
set prjname [diction::getDef prjname {*}$argv]
set prjname "bdprj_$prjname"
file mkdir $prjname
cd $prjname

create_project $prjname

set partname [diction::getDef partname {*}$argv]
set_property "part" "$partname" [current_project]

if {[diction::checkForKeyPair boardname {*}$argv]} {
    set_property "board_part" [diction::getDef boardname {*}$argv] [current_project]
}

if {[diction::checkForKeyPair target_language {*}$argv]} {
    set_property target_language [diction::getDef target_language {*}$argv] [current_project]
} else {
    set_property target_language VHDL [current_project]
}

set_property default_lib xil_defaultlib [current_project]
set_property generate_ip_upgrade_log "0" [current_project]
set_property "sim.ip.auto_export_scripts" "1" [current_project]
set_property simulator_language "Mixed" [current_project]

if {[string equal [get_filesets -quiet sources_1] ""]} {
    create_fileset -srcset sources_1
}

if {[diction::checkForKeyPair ip_repo_dirs {*}$argv]} {
    set_property ip_repo_paths [diction::getDef ip_repo_dirs {*}$argv] [current_project]
}
update_ip_catalog -rebuild

if {[diction::checkForKeyPair scopedearlyconstraints {*}$argv]} {
    add_const_files_to_set true early [diction::getDef scopedearlyconstraints {*}$argv]
}
if {[diction::checkForKeyPair scopednormalconstraints {*}$argv]} {
    add_const_files_to_set true normal [diction::getDef scopednormalconstraints {*}$argv]
}
if {[diction::checkForKeyPair scopedlateconstraints {*}$argv]} {
    add_const_files_to_set true late [diction::getDef scopedlateconstraints {*}$argv]
}
if {[diction::checkForKeyPair unscopedearlyconstraints {*}$argv]} {
    add_const_files_to_set false early [diction::getDef unscopedearlyconstraints {*}$argv]
}
if {[diction::checkForKeyPair unscopednormalconstraints {*}$argv]} {
    add_const_files_to_set false normal [diction::getDef unscopednormalconstraints {*}$argv]
}
if {[diction::checkForKeyPair unscopedlateconstraints {*}$argv]} {
    add_const_files_to_set false late [diction::getDef unscopedlateconstraints {*}$argv]
}

source [diction::getDef bdscript {*}$argv]

if {[diction::checkForKeyPair vhdlbdwrapper {*}$argv]} {
    add_files_to_set sources_1 VHDL [diction::getDef vhdlbdwrapper {*}$argv]
} elseif {[diction::checkForKeyPair verilogbdwrapper {*}$argv]} {
    add_files_to_set sources_1 Verilog [diction::getDef verilogbdwrapper {*}$argv]
} else {
    set dirext .srcs
    make_wrapper -files [get_files *.bd] -top
    add_files -norecurse [file normalize [glob $prjname$dirext/sources_1/bd/*/hdl/*.v*]]
}

report_ip_status -name ip_status
open_bd_design [get_files *.bd]
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
if {[file exists [glob $prjname$dirext/impl_1/*.bit]]} {
    file copy -force [glob $prjname$dirext/impl_1/*.bit] [diction::getDef hdfout {*}$argv]
} else {
    file copy -force [glob $prjname$dirext/impl_1/*.sysdef] [diction::getDef hdfout {*}$argv]
}

puts "Completed Execution of $argv0"
