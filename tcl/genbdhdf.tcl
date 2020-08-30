puts "executing $argv0"
puts "argv is:$argv"

source [file join [file dirname [info script]] "cmdline_dict_procs.tcl"]
source [file join [file dirname [info script]] "viv_prj_procs.tcl"]

if { $argc == 0 } {
    puts "No arguments!"
    puts "execution suspended of $argv0"
    exit 2
}
if {[hasDuplicates [getKeys $argv]]} {
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
    requireKey $requiredKey $argv
}
set unrecognizedKeys []
foreach key [getKeys $argv] {
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


if {[getDef builddir $argv] != ""} {
    cd [getDef builddir $argv]
} else {
    puts "builddir failed"
    exit 7
}
set prjname [getDef prjname $argv]
set prjname "bdprj_$prjname"
file mkdir $prjname
cd $prjname

create_project $prjname

set partname [getDef partname $argv]
set_property "part" "$partname" [current_project]

if {[checkForKey boardname $argv]} {
    if {[getDef boardname $argv] != ""} {
	set_property "board_part" [getDef boardname $argv] [current_project]
    }
}

if {[checkForKey target_language $argv]} {
    if {[getDef target_language $argv] != ""} {
	set_property target_language [getDef target_language $argv] [current_project]
    } else {
	set_property target_language VHDL [current_project]
    }
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

if {[checkForKey ip_repo_dirs $argv]} {
    if {[getDef ip_repo_dirs $argv] != ""} {
	set_property ip_repo_paths [getDef ip_repo_dirs $argv]
    }
}
update_ip_catalog -rebuild

if {[checkForKey scopedearlyconstraints $argv]} {
    if {[getDef scopedearlyconstraints $argv] != ""} {
	add_const_files_to_set true early [getDef scopedearlyconstraints $argv]
    }
}
if {[checkForKey scopednormalconstraints $argv]} {
    if {[getDef scopednormalconstraints $argv] != ""} {
	add_const_files_to_set true normal [getDef scopednormalconstraints $argv]
    }
}
if {[checkForKey scopedlateconstraints $argv]} {
    if {[getDef scopedlateconstraints $argv] != ""} {
	add_const_files_to_set true late [getDef scopedlateconstraints $argv]
    }
}
if {[checkForKey unscopedearlyconstraints $argv]} {
    if {[getDef unscopedearlyconstraints $argv] != ""} {
	add_const_files_to_set false early [getDef unscopedearlyconstraints $argv]
    }
}
if {[checkForKey unscopednormalconstraints $argv]} {
    if {[getDef unscopednormalconstraints $argv] != ""} {
	add_const_files_to_set false normal [getDef unscopednormalconstraints $argv]
    }
}
if {[checkForKey unscopedlateconstraints $argv]} {
    if {[getDef unscopedlateconstraints $argv] != ""} {
	add_const_files_to_set false late [getDef unscopedlateconstraints $argv]
    }
}

source $bdscript

if {[checkForKey vhdlbdwrapper $argv] and ([getDef vhdlbdwrapper $argv] != "")} {
    add_files_to_set sources_1 VHDL [getDef vhdlbdwrapper $argv]
} elseif {[checkForKey verilogbdwrapper $argv] and ([getDef verilogbdwrapper $argv] != "")} {
    add_files_to_set sources_1 Verilog [getDef verilogbdwrapper $argv]
} else {
    set dirext .srcs
    make_wrapper -files [get_files *.bd] -top
    add_files -norecurse $prjname$dirext/sources_1/bd/*/hdl/*.vhd
}

report_ip_status -name ip_status
open_bd_design [get_files *.bd]
update_ip_catalog -rebuild -scan_changes
export_ip_user_files -of_objects pget_ips *] -no_script -reset -quiet
upgrade_ip [get_ips *] -log ip_upgrade.log
generate_target all [get_files *.bd]
export_ip_user_files -of_objects [get_files *.bd]
report_ip_status -name ip_status
update_ip_catalog -rebuild -scan_changes
reset_run synth_1
launch_runs impl_1 -to_step write_bitstream -jobs 4
wait_on_run impl_1
set dirext .runs
file copy -force $prjname$dirext/impl_1/*.sysdef [getDef hdfout $argv]


puts "Completed Execution of $argv0"
